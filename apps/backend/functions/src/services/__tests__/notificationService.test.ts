import * as admin from 'firebase-admin';
import { NotificationService } from '../notificationService';

// Mock firebase-admin
jest.mock('firebase-admin', () => {
  const mockFirestore = {
    collection: jest.fn().mockReturnThis(),
    doc: jest.fn().mockReturnThis(),
    get: jest.fn(),
    where: jest.fn().mockReturnThis(),
  };

  const mockMessaging = {
    send: jest.fn().mockResolvedValue('mock-message-id'),
    sendEachForMulticast: jest.fn().mockResolvedValue({
      successCount: 1,
      failureCount: 0,
    }),
  };

  return {
    firestore: Object.assign(() => mockFirestore, {
      FieldPath: {
        documentId: () => 'documentId',
      },
    }),
    messaging: () => mockMessaging,
  };
});

describe('NotificationService', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should skip sending if user doc does not exist', async () => {
    const firestoreMock = admin.firestore() as any;
    firestoreMock.get.mockResolvedValue({ exists: false });

    await NotificationService.sendNotificationToUser('user1', 'Title', 'Body');

    expect(firestoreMock.collection).toHaveBeenCalledWith('users');
    expect(firestoreMock.doc).toHaveBeenCalledWith('user1');
    expect(admin.messaging().send).not.toHaveBeenCalled();
  });

  it('should skip sending if user doc has no fcmToken', async () => {
    const firestoreMock = admin.firestore() as any;
    firestoreMock.get.mockResolvedValue({
      exists: true,
      data: () => ({ name: 'Test User' }),
    });

    await NotificationService.sendNotificationToUser('user2', 'Title', 'Body');

    expect(admin.messaging().send).not.toHaveBeenCalled();
  });

  it('should send FCM notification if fcmToken is present', async () => {
    const firestoreMock = admin.firestore() as any;
    firestoreMock.get.mockResolvedValue({
      exists: true,
      data: () => ({ fcmToken: 'test-token' }),
    });

    await NotificationService.sendNotificationToUser('user3', 'Title', 'Body');

    expect(admin.messaging().send).toHaveBeenCalledWith(
      expect.objectContaining({
        token: 'test-token',
        notification: {
          title: 'Title',
          body: 'Body',
        },
      })
    );
  });
});
