import * as admin from 'firebase-admin';
import { onRequest } from 'firebase-functions/v2/https';

admin.initializeApp();

// Export triggers
export { onDriftCreated } from './triggers/driftTriggers';
export { onAcceptanceCreated, onAcceptanceUpdated } from './triggers/acceptanceTriggers';
export { onMessageSent } from './triggers/messageTriggers';

// HTTP healthcheck
export const healthCheck = onRequest((_req, res) => {
  res.status(200).json({
    ok: true,
    service: 'CoffeeCall Functions',
  });
});
