const admin = require('../config/firebaseAdmin');
const { query } = require('../config/database');

/**
 * Send push notification to a specific user
 */
async function sendPushNotification(userId, title, message, data = {}) {
  try {
    // Get user's FCM token
    const result = await query(
      'SELECT fcm_token FROM user_fcm_tokens WHERE user_id = $1 AND fcm_token IS NOT NULL',
      [userId]
    );

    if (result.rows.length === 0) {
      console.log('No FCM token found for user:', userId);
      return false;
    }

    // Send to all tokens (user might have multiple devices)
    const promises = result.rows.map(async (row) => {
      const token = row.fcm_token;

      const payload = {
        notification: {
          title,
          body: message,
        },
        data: {
          type: data.type || 'notification',
          ...data,
        },
        android: {
          notification: {
            channelId: 'poker_club_channel',
            imageUrl: data.image_url || null,
            sound: 'default',
          },
        },
        apns: {
          payload: {
            aps: {
              badge: 1,
              sound: 'default',
            },
          },
        },
      };

      try {
        await admin.messaging().send({
          token,
          payload,
        });
        return true;
      } catch (error) {
        console.error('Error sending push notification:', error);
        // If token is invalid, remove it
        if (error.code === 'messaging/invalid-registration-token' ||
            error.code === 'messaging/registration-token-not-registered') {
          await query(
            'DELETE FROM user_fcm_tokens WHERE fcm_token = $1',
            [token]
          );
        }
        return false;
      }
    });

    await Promise.all(promises);
    return true;
  } catch (error) {
    console.error('Error in sendPushNotification:', error);
    return false;
  }
}

/**
 * Send push notification to multiple users
 */
async function sendPushNotificationToMany(userIds, title, message, data = {}) {
  const promises = userIds.map(userId =>
    sendPushNotification(userId, title, message, data)
  );
  await Promise.all(promises);
}

/**
 * Send notification when user registers for tournament
 */
async function sendTournamentRegisteredNotification(adminUserId, playerUserId, tournamentName) {
  return sendPushNotification(playerUserId, 'Регистрация на турнир', `Админ подтвердил вашу регистрацию на "${tournamentName}"`, {
    type: 'tournament_registered',
    tournament_name: tournamentName,
  });
}

/**
 * Send notification when new news is published
 */
async function sendNewsPublishedNotification(userIds, title, message) {
  return sendPushNotificationToMany(userIds, title, message, {
    type: 'news_published',
  });
}

/**
 * Send notification when tournament is starting soon
 */
async function sendTournamentStartingNotification(userIds, tournamentName, startTime) {
  return sendPushNotificationToMany(userIds, 'Турнир скоро начнется!', `${tournamentName} начнется в ${startTime}`, {
    type: 'tournament_starting',
    tournament_name: tournamentName,
  });
}

module.exports = {
  sendPushNotification,
  sendPushNotificationToMany,
  sendTournamentRegisteredNotification,
  sendNewsPublishedNotification,
  sendTournamentStartingNotification,
};
