import * as admin from 'firebase-admin';

export class NotificationService {
  /**
   * Send a push notification to a single user.
   */
  static async sendNotificationToUser(
    userId: string,
    title: string,
    body: string,
    data?: Record<string, string>
  ): Promise<void> {
    try {
      const userDoc = await admin.firestore().collection('users').doc(userId).get();
      if (!userDoc.exists) {
        console.warn(`User document not found for notifications: ${userId}`);
        return;
      }

      const fcmToken = userDoc.data()?.fcmToken;
      if (!fcmToken) {
        console.log(`No FCM Token registered for user: ${userId}`);
        return;
      }

      const message: admin.messaging.Message = {
        token: fcmToken,
        notification: {
          title,
          body,
        },
        data: data || {},
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      const response = await admin.messaging().send(message);
      console.log(`Successfully sent message to user ${userId}:`, response);
    } catch (error) {
      console.error(`Error sending notification to user ${userId}:`, error);
    }
  }

  /**
   * Send a push notification to multiple users.
   */
  static async sendNotificationToMultipleUsers(
    userIds: string[],
    title: string,
    body: string,
    data?: Record<string, string>
  ): Promise<void> {
    if (userIds.length === 0) return;

    try {
      const tokens: string[] = [];
      const userChunks = this.chunkArray(userIds, 100);

      for (const chunk of userChunks) {
        const usersSnapshot = await admin
          .firestore()
          .collection('users')
          .where(admin.firestore.FieldPath.documentId(), 'in', chunk)
          .get();

        usersSnapshot.forEach((doc) => {
          const token = doc.data()?.fcmToken;
          if (token) {
            tokens.push(token);
          }
        });
      }

      if (tokens.length === 0) {
        console.log('No registered FCM tokens found for target users.');
        return;
      }

      const message: admin.messaging.MulticastMessage = {
        tokens,
        notification: {
          title,
          body,
        },
        data: data || {},
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      const response = await admin.messaging().sendEachForMulticast(message);
      console.log(`Multicast sent: ${response.successCount} success, ${response.failureCount} failed.`);
    } catch (error) {
      console.error('Error sending multicast notification:', error);
    }
  }

  private static chunkArray<T>(array: T[], size: number): T[][] {
    const results: T[][] = [];
    for (let i = 0; i < array.length; i += size) {
      results.push(array.slice(i, i + size));
    }
    return results;
  }
}
