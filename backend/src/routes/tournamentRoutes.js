const express = require('express');
const { query } = require('../config/database');
const { requireAuth, requireAdmin } = require('../middleware/authMiddleware');
const { processTournamentLifecycle } = require('../services/tournamentLifecycleService');

const router = express.Router();

function sanitizeTournament(row) {
  return {
    id: row.id,
    name: row.name,
    description: row.description,
    start_date: row.start_date,
    end_date: row.end_date,
    max_players: Number(row.max_players),
    buy_in: Number(row.buy_in),
    format: row.format,
    status: row.status,
    is_manual_status: !!row.is_manual_status,
    late_registration_minutes: Number(row.late_registration_minutes || 0),
    registered_players: row.registered_players || [],
  };
}

router.get('/', async (req, res) => {
  try {
    const result = await query(`
      SELECT t.*, COALESCE(
        json_agg(tp.user_id) FILTER (WHERE tp.user_id IS NOT NULL),
        '[]'::json
      ) AS registered_players
      FROM tournaments t
      LEFT JOIN tournament_players tp ON tp.tournament_id = t.id
      GROUP BY t.id
      ORDER BY t.start_date DESC
    `);

    const allTournaments = result.rows.map(sanitizeTournament);
    
    // Разделяем на активные и завершенные
    const activeTournaments = allTournaments.filter(t => 
      t.status !== 'completed' && t.status !== 'cancelled'
    );
    
    const completedTournaments = allTournaments.filter(t => 
      t.status === 'completed' || t.status === 'cancelled'
    );

    res.json({
      activeTournaments,
      completedTournaments
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch tournaments' });
  }
});

router.post('/reconcile', requireAuth, requireAdmin, async (req, res) => {
  try {
    const summary = await processTournamentLifecycle();
    res.json({ ok: true, ...summary });
  } catch (error) {
    console.error('Tournament lifecycle reconcile failed:', error);
    res.status(500).json({ message: 'Failed to reconcile tournament lifecycle' });
  }
});

router.post('/', async (req, res) => {
  try {
    const { name, description, start_date, end_date, max_players, buy_in, format, status, late_registration_minutes, is_manual_status } = req.body || {};

    const result = await query(
      `INSERT INTO tournaments (name, description, start_date, end_date, max_players, buy_in, format, status, is_manual_status, late_registration_minutes)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING *`,
      [name, description, start_date, end_date, max_players || 100, buy_in || 0, format || 'TT No-Limit', status || 'upcoming', !!is_manual_status, Number(late_registration_minutes) || 0]
    );

    res.status(201).json(sanitizeTournament(result.rows[0]));
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to create tournament' });
  }
});

router.post('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, start_date, end_date, max_players, buy_in, format, status, is_manual_status, late_registration_minutes } = req.body || {};

    const result = await query(
      `UPDATE tournaments
       SET name = COALESCE($1, name),
           description = COALESCE($2, description),
           start_date = COALESCE($3, start_date),
           end_date = COALESCE($4, end_date),
           max_players = COALESCE($5, max_players),
           buy_in = COALESCE($6, buy_in),
           format = COALESCE($7, format),
           status = COALESCE($8, status),
           is_manual_status = COALESCE($9, is_manual_status),
           late_registration_minutes = COALESCE($10, late_registration_minutes)
       WHERE id = $11
       RETURNING *`,
      [name, description, start_date, end_date, max_players, buy_in, format, status, is_manual_status, late_registration_minutes, id]
    );

    if (!result.rows[0]) {
      return res.status(404).json({ message: 'Tournament not found' });
    }

    res.json(sanitizeTournament(result.rows[0]));
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to update tournament' });
  }
});

router.post('/:id/delete', async (req, res) => {
  try {
    const { id } = req.params;
    await query(`DELETE FROM tournaments WHERE id = $1`, [id]);
    res.json({ ok: true });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to delete tournament' });
  }
});

router.post('/:id/start', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const result = await query(
      `UPDATE tournaments
       SET status = 'inProgress',
           start_date = COALESCE(start_date, NOW())
       WHERE id = $1
       RETURNING *`,
      [id]
    );

    if (!result.rows[0]) {
      return res.status(404).json({ message: 'Tournament not found' });
    }

    const participants = await query(
      `SELECT DISTINCT user_id FROM tournament_players WHERE tournament_id = $1`,
      [id]
    );

    for (const row of participants.rows) {
      await query(
        `INSERT INTO notifications (user_id, title, message)
         VALUES ($1, $2, $3)`,
        [row.user_id, 'Турнир стартовал', `Турнир "${result.rows[0].name}" уже идет. Добро пожаловать!`]
      );
    }

    res.json(sanitizeTournament(result.rows[0]));
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to start tournament' });
  }
});

router.post('/:id/players', async (req, res) => {
  try {
    const { id } = req.params;
    const { player_id } = req.body || {};

    if (!player_id) {
      return res.status(400).json({ message: 'player_id required' });
    }

    // Проверяем, не полон ли турнир
    const tournamentCheck = await query(
      `SELECT max_players, (
        SELECT COUNT(*) FROM tournament_players WHERE tournament_id = $1
      ) AS current_players FROM tournaments WHERE id = $1`,
      [id]
    );

    if (!tournamentCheck.rows[0]) {
      return res.status(404).json({ message: 'Tournament not found' });
    }

    const { max_players, current_players } = tournamentCheck.rows[0];
    if (Number(current_players) >= Number(max_players)) {
      return res.status(400).json({ message: 'В турнире нет свободных мест' });
    }

    // Регистрация со статусом 'pending'
    await query(
      `INSERT INTO tournament_players (tournament_id, user_id, registration_status)
       VALUES ($1, $2, 'pending')
       ON CONFLICT (tournament_id, user_id) DO UPDATE SET registration_status = 'pending'`,
      [id, player_id]
    );

    // Возвращаем обновлённый турнир с игроками
    const result = await query(`
      SELECT t.*, COALESCE(
        json_agg(tp.user_id) FILTER (WHERE tp.user_id IS NOT NULL),
        '[]'::json
      ) AS registered_players
      FROM tournaments t
      LEFT JOIN tournament_players tp ON tp.tournament_id = t.id
      WHERE t.id = $1
      GROUP BY t.id
    `, [id]);

    res.json(sanitizeTournament(result.rows[0]));
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to register player' });
  }
});

router.delete('/:id/players/:playerId', async (req, res) => {
  try {
    const { id, playerId } = req.params;
    
    await query(
      `DELETE FROM tournament_players 
       WHERE tournament_id = $1 AND user_id = $2`,
      [id, playerId]
    );

    res.json({ ok: true });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to remove player' });
  }
});

// PATCH /:id/players/:playerId/confirm — подтвердить игрока (админ)
router.patch('/:id/players/:playerId/confirm', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { id, playerId } = req.params;

    await query(
      `UPDATE tournament_players 
       SET registration_status = 'confirmed' 
       WHERE tournament_id = $1 AND user_id = $2`,
      [id, playerId]
    );

    res.json({ ok: true });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to confirm player' });
  }
});

// PATCH /:id/players/:playerId/eliminate — отметить выбывшим (админ)
router.patch('/:id/players/:playerId/eliminate', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { id, playerId } = req.params;

    await query(
      `UPDATE tournament_players 
       SET registration_status = 'eliminated' 
       WHERE tournament_id = $1 AND user_id = $2`,
      [id, playerId]
    );

    res.json({ ok: true });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to eliminate player' });
  }
});

// POST /:id/players/:playerId/cancel — отмена регистрации игроком
router.post('/:id/players/:playerId/cancel', requireAuth, async (req, res) => {
  try {
    const { id, playerId } = req.params;
    const userId = req.user.sub;

    // Проверяем, что игрок зарегистрирован и может отменить
    const check = await query(
      `SELECT registration_status FROM tournament_players 
       WHERE tournament_id = $1 AND user_id = $2`,
      [id, userId]
    );

    if (!check.rows[0]) {
      return res.status(404).json({ message: 'Регистрация не найдена' });
    }

    const { registration_status } = check.rows[0];
    if (registration_status === 'confirmed' || registration_status === 'eliminated') {
      return res.status(400).json({ message: 'Нельзя отменить подтверждённую или выбывшую регистрацию' });
    }

    await query(
      `DELETE FROM tournament_players 
       WHERE tournament_id = $1 AND user_id = $2`,
      [id, userId]
    );

    res.json({ ok: true });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to cancel registration' });
  }
});

module.exports = router;
