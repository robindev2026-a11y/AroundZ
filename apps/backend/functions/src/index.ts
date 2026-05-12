import * as admin from 'firebase-admin';
import { onRequest } from 'firebase-functions/v2/https';

admin.initializeApp();

export const healthCheck = onRequest((_req, res) => {
  res.status(200).json({
    ok: true,
    service: 'CoffeeCall Functions',
  });
});
