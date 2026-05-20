import { onDocumentCreated, onDocumentUpdated } from 'firebase-functions/v2/firestore';
import * as admin from 'firebase-admin';
import { NotificationService } from '../services/notificationService';

/**
 * Triggered when a new join request (acceptance doc) is created.
 */
export const onAcceptanceCreated = onDocumentCreated('acceptances/{acceptanceId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;

  const requestData = snapshot.data();
  const postId = requestData.postId;
  const acceptorId = requestData.acceptorId;
  const acceptorName = requestData.acceptorName || 'Someone';

  console.log(`Join request created by ${acceptorId} for post ${postId}`);

  try {
    const postDoc = await admin.firestore().collection('posts').doc(postId).get();
    if (!postDoc.exists) {
      console.warn(`Drift post ${postId} not found`);
      return;
    }

    const postData = postDoc.data()!;
    const hostId = postData.creatorId;
    const postTitle = postData.title || 'your Drift';

    // Notify the host
    await NotificationService.sendNotificationToUser(
      hostId,
      'New Join Request',
      `${acceptorName} requested to join "${postTitle}"`,
      {
        postId,
        acceptanceId: snapshot.id,
        type: 'JOIN_REQUEST',
      }
    );
  } catch (error) {
    console.error('Error in onAcceptanceCreated trigger:', error);
  }
});

/**
 * Triggered when a join request status changes.
 */
export const onAcceptanceUpdated = onDocumentUpdated('acceptances/{acceptanceId}', async (event) => {
  const snapshotBefore = event.data?.before;
  const snapshotAfter = event.data?.after;
  if (!snapshotBefore || !snapshotAfter) return;

  const dataBefore = snapshotBefore.data();
  const dataAfter = snapshotAfter.data();

  const statusBefore = dataBefore.status;
  const statusAfter = dataAfter.status;

  const postId = dataAfter.postId;
  const acceptorId = dataAfter.acceptorId;
  const acceptorName = dataAfter.acceptorName || 'Someone';
  const acceptorInitials = dataAfter.acceptorInitials || '';

  // Only handle transition to "accepted"
  if (statusBefore !== 'accepted' && statusAfter === 'accepted') {
    console.log(`Join request ${snapshotAfter.id} accepted for post ${postId}`);

    try {
      const db = admin.firestore();

      // 1. Fetch parent Drift Post
      const postRef = db.collection('posts').doc(postId);
      const postDoc = await postRef.get();
      if (!postDoc.exists) {
        console.warn(`Drift post ${postId} not found`);
        return;
      }

      const postData = postDoc.data()!;
      const hostId = postData.creatorId;
      const postTitle = postData.title || 'your Drift';

      // 2. Fetch host profile details to get creatorName
      const hostDoc = await db.collection('users').doc(hostId).get();
      const hostName = hostDoc.exists ? (hostDoc.data()?.name || 'The host') : 'The host';

      // 3. Update parent Drift participant count & spots left
      await db.runTransaction(async (transaction) => {
        const freshPostDoc = await transaction.get(postRef);
        if (!freshPostDoc.exists) return;

        const freshPostData = freshPostDoc.data()!;
        const currentCount = freshPostData.participantCount || 1;
        const currentCapacity = freshPostData.capacity || 5;
        const currentInitials: string[] = freshPostData.participantInitials || [];

        const newInitials = [...currentInitials];
        if (acceptorInitials && !newInitials.includes(acceptorInitials)) {
          newInitials.push(acceptorInitials);
        }

        transaction.update(postRef, {
          participantCount: currentCount + 1,
          spotsLeft: Math.max(0, currentCapacity - (currentCount + 1)),
          participantInitials: newInitials,
        });
      });

      // 4. Enroll participant in the message thread
      const threadRef = db.collection('messageThreads').doc(postId);
      const threadDoc = await threadRef.get();

      if (!threadDoc.exists) {
        // Initialize message thread with host and joiner
        await threadRef.set({
          postId,
          participants: [hostId, acceptorId],
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else {
        // Append participant to existing thread
        await threadRef.update({
          participants: admin.firestore.FieldValue.arrayUnion(acceptorId),
        });
      }

      // 5. Add a system message in the thread
      await threadRef.collection('messages').add({
        senderId: 'system',
        senderName: 'System',
        text: `${acceptorName} joined the Drift!`,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        type: 'system',
      });

      // 6. Notify the acceptor
      await NotificationService.sendNotificationToUser(
        acceptorId,
        'Request Approved! 🎉',
        `${hostName} accepted your request to join "${postTitle}"`,
        {
          postId,
          type: 'REQUEST_ACCEPTED',
        }
      );
    } catch (error) {
      console.error('Error in onAcceptanceUpdated trigger:', error);
    }
  }
});
