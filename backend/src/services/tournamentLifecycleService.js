const { query } = require('../config/database');

const reminderKeys = new Set();
let lifecycleInterval = null;

function resolveTournamentStatus(tournament) {
  const now = new Date();
  const startDate = new Date(tournament.start_date);
  const endDate = new Date(tournament.end_date);

  if (tournament.status === 'cancelled') {
    return 'cancelled';
  }

  if (tournament.status === 'completed') {
    return 'completed';
  }

  if (now < startDate) {
    return 'upcoming';
  }

  if (now >= startDate && now < endDate) {
    return 'inProgress';
  }

  return 'completed';
}

async function getTournamentPlayerIds(tournamentId) {
  const result = await query(
    `SELECT user_id FROM tournament_players WHERE tournament_id = $1`,
    [tournamentId]
  );

  return result.rows
    .map((row) => row.user_id)
    .filter(Boolean);
}

async function notifyPlayers(tournamentId, title, message, extraData = {}) {
  try {
    const { sendPushNotificationToMany } = require('./notificationService');
    const userIds = await getTournamentPlayerIds(tournamentId);

    if (!userIds.length) {
      return { sent: 0 };
    }

    await sendPushNotificationToMany(userIds, title, message, {
      type: 'tournament_lifecycle',
      tournament_id: tournamentId,
      ...extraData,
    });

    return { sent: userIds.length };
  } catch (error) {
    console.error('Tournament lifecycle notification failed:', error.message);
    return { sent: 0, error: error.message };
  }
}

async function processTournamentLifecycle() {
  const result = await query(
    `SELECT * FROM tournaments ORDER BY start_date ASC`
  );

  const now = Date.now();
  let processed = 0;
  let started = 0;
  let finished = 0;
  let reminders = 0;
  let lateRegistrationCloses = 0;

  for (const tournament of result.rows) {
    const previousStatus = tournament.status || 'upcoming';
    const nextStatus = resolveTournamentStatus(tournament);

    if (previousStatus !== nextStatus) {
      await query(
        `UPDATE tournaments SET status = $1 WHERE id = $2`,
        [nextStatus, tournament.id]
      );
      processed += 1;

      if (nextStatus === 'inProgress') {
        started += 1;
        await notifyPlayers(
          tournament.id,
          'Турнир стартовал',
          `${tournament.name} начался. Приятной игры!`,
          { tournament_name: tournament.name }
        );
      }

      if (nextStatus === 'completed') {
        finished += 1;
        await notifyPlayers(
          tournament.id,
          'Турнир завершён',
          `Турнир "${tournament.name}" завершён. Посмотрите результаты.`,
          { tournament_name: tournament.name }
        );
      }
    }

    const startDate = new Date(tournament.start_date).getTime();
    const lateRegistrationMinutes = Number(tournament.late_registration_minutes || 0);
    const lateDeadline = startDate + (lateRegistrationMinutes * 60 * 1000);
    const startReminderKey = `start:${tournament.id}`;
    const lateCloseKey = `late_close:${tournament.id}`;

    if (
      previousStatus === 'upcoming' &&
      startDate > now &&
      (startDate - now) <= 30 * 60 * 1000 &&
      !reminderKeys.has(startReminderKey)
    ) {
      reminderKeys.add(startReminderKey);
      reminders += 1;
      await notifyPlayers(
        tournament.id,
        'Напоминание о старте турнира',
        `${tournament.name} начнётся через 30 минут.`,
        { tournament_name: tournament.name }
      );
    }

    if (
      previousStatus === 'upcoming' &&
      now >= lateDeadline &&
      now < startDate &&
      !reminderKeys.has(lateCloseKey)
    ) {
      reminderKeys.add(lateCloseKey);
      lateRegistrationCloses += 1;
      await notifyPlayers(
        tournament.id,
        'Поздняя регистрация закрыта',
        `Регистрация на "${tournament.name}" закрыта. Турнир уже стартует скоро.`,
        { tournament_name: tournament.name }
      );
    }
  }

  return {
    processed,
    started,
    finished,
    reminders,
    lateRegistrationCloses,
  };
}

function startTournamentLifecycleScheduler(intervalMs = 60 * 1000) {
  if (lifecycleInterval) {
    return lifecycleInterval;
  }

  lifecycleInterval = setInterval(() => {
    processTournamentLifecycle().catch((error) => {
      console.error('Tournament lifecycle cron failed:', error);
    });
  }, intervalMs);

  processTournamentLifecycle().catch((error) => {
    console.error('Initial tournament lifecycle sync failed:', error);
  });

  return lifecycleInterval;
}

function stopTournamentLifecycleScheduler() {
  if (!lifecycleInterval) {
    return;
  }

  clearInterval(lifecycleInterval);
  lifecycleInterval = null;
}

module.exports = {
  processTournamentLifecycle,
  startTournamentLifecycleScheduler,
  stopTournamentLifecycleScheduler,
  resolveTournamentStatus,
};
