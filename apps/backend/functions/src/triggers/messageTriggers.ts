import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import * as admin from 'firebase-admin';
import { NotificationService } from '../services/notificationService';

export const onMessageSent = onDocumentCreated('messageThreads/{threadId}/messages/{messageId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;

  const threadId = event.params.threadId;
  const messageData = snapshot.data();
  const senderId = messageData.senderId;
  const senderName = messageData.senderName || 'Someone';
  const type = messageData.type || 'text';
  let text = messageData.text || '';

  // Skip system messages
  if (senderId === 'system') {
    return;
  }

  // Format message text preview if it's media or location
  if (type === 'image') {
    text = 'sent an image 📸';
  } else if (type === 'location') {
    text = 'shared a location 📍';
  }

  console.log(`New message sent in thread ${threadId} by ${senderId}`);

  try {
    const db = admin.firestore();

    // 1. Fetch parent message thread
    const threadDoc = await db.collection('messageThreads').doc(threadId).get();
    if (!threadDoc.exists) {
      console.warn(`Message thread ${threadId} not found`);
      return;
    }

    const threadData = threadDoc.data()!;
    const participants: string[] = threadData.participants || [];

    // Filter out the sender
    const recipientIds = participants.filter((uid) => uid !== senderId);
    if (recipientIds.length === 0) {
      console.log('No other participants in the thread to notify.');
      return;
    }

    // 2. Fetch Drift/Post details for context title
    const postDoc = await db.collection('posts').doc(threadId).get();
    const driftTitle = postDoc.exists ? (postDoc.data()?.title || 'Drift chat') : 'Drift chat';

    // 3. Update the thread's lastMessage metadata for the chats list preview
    await db.collection('messageThreads').doc(threadId).update({
      lastMessage: {
        text: type === 'text' ? text : `${senderName} ${text}`,
        senderId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      },
    });

    // 4. Send notifications to all recipients
    const notificationTitle = `Message in "${driftTitle}"`;
    const notificationBody = type === 'text' ? `${senderName}: ${text}` : `${senderName} ${text}`;

    for (const recipientId of recipientIds) {
      await NotificationService.sendNotificationToUser(
        recipientId,
        notificationTitle,
        notificationBody,
        {
          postId: threadId,
          type: 'CHAT_MESSAGE',
        }
      );
    }
  } catch (error) {
    console.error('Error in onMessageSent trigger workflow:', error);
  }
});
