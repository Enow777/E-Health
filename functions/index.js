const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

// The custom Firestore database used by this project.
const DB = 'ehealthdatabase';

/**
 * Fires whenever a new document is written to the notifications collection.
 * Reads the recipient's FCM token from userTokens/{uid} and sends a push.
 */
exports.sendPushNotification = onDocumentCreated(
  {
    document: 'notifications/{notificationId}',
    database: DB,
  },
  async (event) => {
    const data = event.data?.data();
    if (!data) return null;

    const recipientUid = data.patientId; // field holds the recipient UID for both roles
    if (!recipientUid) return null;

    const db = getFirestore(DB);

    // Look up the FCM token saved by the Flutter app on login.
    const tokenSnap = await db.collection('userTokens').doc(recipientUid).get();
    const token = tokenSnap.data()?.token;
    if (!token) {
      console.log(`No FCM token found for uid: ${recipientUid}`);
      return null;
    }

    const category = data.category ?? 'general';

    const message = {
      token,
      notification: {
        title: data.title ?? 'Nkap Health',
        body: data.message ?? '',
      },
      // Passed through to the notification tap handler in the Flutter app.
      data: { category },
      android: {
        notification: {
          channelId: 'nkap_health',
          priority: 'high',
          sound: 'default',
        },
      },
      apns: {
        payload: {
          aps: { sound: 'default' },
        },
      },
    };

    try {
      const response = await getMessaging().send(message);
      console.log(`Push sent to ${recipientUid}: ${response}`);
    } catch (err) {
      // Token stale or invalid — remove it so we don't retry.
      if (
        err.code === 'messaging/registration-token-not-registered' ||
        err.code === 'messaging/invalid-registration-token'
      ) {
        await db.collection('userTokens').doc(recipientUid).delete();
        console.log(`Removed stale token for uid: ${recipientUid}`);
      } else {
        console.error('FCM send error:', err);
      }
    }

    return null;
  }
);
