import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import * as admin from 'firebase-admin';
import { NotificationService } from '../services/notificationService';

export const onDriftCreated = onDocumentCreated('posts/{postId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    console.log('No data associated with the event');
    return;
  }

  const driftData = snapshot.data();
  const creatorId = driftData.creatorId;
  const category = driftData.category;
  const title = driftData.title || 'New Drift forming!';
  const hook = driftData.hook;
  const driftGeoHash = driftData.locationGeoHash;

  console.log(`New Drift created: ${snapshot.id} by creator ${creatorId}`);

  if (!driftGeoHash) {
    console.log('No geohash found on new Drift, skipping notification broadcast.');
    return;
  }

  // Define geohash query range for proximity (prefix length 4 covers ~20-30km radius box)
  const prefix = driftGeoHash.substring(0, 4);
  const start = prefix;
  const end = prefix + '\uf8ff';

  // Find users within the same region updated in the last 24 hours
  const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
  
  try {
    const querySnapshot = await admin.firestore()
      .collection('users')
      .where('lastLocationGeoHash', '>=', start)
      .where('lastLocationGeoHash', '<=', end)
      .where('lastLocationUpdate', '>=', admin.firestore.Timestamp.fromDate(oneDayAgo))
      .get();

    const targetUserIds: string[] = [];

    querySnapshot.forEach((doc) => {
      const userId = doc.id;
      const userData = doc.data();

      // Skip the creator
      if (userId === creatorId) return;

      // Filter by interests (category matches user interestTags if present)
      const interestTags: string[] = userData.interestTags || [];
      const lowerCategory = category ? category.toLowerCase() : '';
      const matchesInterest = interestTags.some(tag => 
        tag.toLowerCase() === lowerCategory || 
        (lowerCategory === 'walk' && tag.toLowerCase() === 'walks') ||
        (lowerCategory === 'movie' && tag.toLowerCase() === 'movies')
      );

      if (interestTags.length === 0 || matchesInterest) {
        targetUserIds.push(userId);
      }
    });

    if (targetUserIds.length === 0) {
      console.log('No matching nearby users found to notify.');
      return;
    }

    console.log(`Broadcasting notifications to ${targetUserIds.length} nearby users.`);
    const notificationTitle = `Nearby Drift: ${title}`;
    const notificationBody = hook 
      ? `Interest matches! Details: "${hook}"` 
      : `Someone is hosting a new ${category} Drift near you.`;

    await NotificationService.sendNotificationToMultipleUsers(
      targetUserIds,
      notificationTitle,
      notificationBody,
      {
        postId: snapshot.id,
        type: 'DRIFT_CREATED',
      }
    );
  } catch (error) {
    console.error('Error in onDriftCreated notification workflow:', error);
  }
});
