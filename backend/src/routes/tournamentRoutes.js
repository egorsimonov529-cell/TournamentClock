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

    res.json(result.rows.map(sanitizeTournament));
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
    const { name, description, start_date, end_date, max_players, buy_in, format, status, late_registration_minutes } = req.body || {};

    const result = await query(
      `INSERT INTO tournaments (name, description, start_date, end_date, max_players, buy_in, format, status, late_registration_minutes)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING *`,
      [name, description, start_date, end_date, max_players || 100, buy_in || 0, format || 'TT No-Limit', status || 'upcoming', Number(late_registration_minutes) || 0]
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
    const { name, description, start_date, end_date, max_players, buy_in, format, status, late_registration_minutes } = req.body || {};

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
           late_registration_minutes = COALESCE($9, late_registration_minutes)
       WHERE id = $10
       RETURNING *`,
      [name, description, start_date, end_date, max_players, buy_in, format, status, late_registration_minutes, id]
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

    await query(
      `INSERT INTO tournament_players (tournament_id, user_id)
       VALUES ($1, $2)
       ON CONFLICT (tournament_id, user_id) DO NOTHING`,
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

module.exports = router;
