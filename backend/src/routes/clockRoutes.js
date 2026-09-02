const express = require('express');
const { query } = require('../config/database');

const router = express.Router();

router.get('/blind-levels', async (req, res) => {
  try {
    const tournamentId = req.query.tournament_id;

    if (tournamentId) {
      const result = await query(
        `SELECT * FROM blind_levels 
         WHERE tournament_id = $1 
         ORDER BY level_number ASC`,
        [tournamentId]
      );

      return res.json(result.rows.map((row) => ({
        id: row.id,
        tournamentId: row.tournament_id,
        level: row.level_number,
        smallBlind: Number(row.small_blind),
        bigBlind: Number(row.big_blind),
        ante: Number(row.ante),
        durationMinutes: Number(row.duration_minutes),
      })));
    }

    // Default blind levels if no tournament specified
    const defaultLevels = [
      { level: 1, smallBlind: 25, bigBlind: 50, ante: 0, durationMinutes: 15 },
      { level: 2, smallBlind: 50, bigBlind: 100, ante: 25, durationMinutes: 15 },
      { level: 3, smallBlind: 100, bigBlind: 200, ante: 50, durationMinutes: 20 },
      { level: 4, smallBlind: 200, bigBlind: 400, ante: 100, durationMinutes: 20 },
      { level: 5, smallBlind: 300, bigBlind: 600, ante: 150, durationMinutes: 20 },
      { level: 6, smallBlind: 400, bigBlind: 800, ante: 200, durationMinutes: 25 },
      { level: 7, smallBlind: 500, bigBlind: 1000, ante: 250, durationMinutes: 25 },
      { level: 8, smallBlind: 750, bigBlind: 1500, ante: 375, durationMinutes: 30 },
    ];

    res.json(defaultLevels);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch blind levels' });
  }
});

router.post('/', async (req, res) => {
  try {
    const { tournament_id, level_number, small_blind, big_blind, ante, duration_minutes } = req.body || {};

    if (!tournament_id || !level_number) {
      return res.status(400).json({ message: 'tournament_id and level_number are required' });
    }

    const result = await query(
      `INSERT INTO blind_levels (tournament_id, level_number, small_blind, big_blind, ante, duration_minutes)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [tournament_id, level_number, small_blind || 0, big_blind || 0, ante || 0, duration_minutes || 10]
    );

    res.status(201).json({
      id: result.rows[0].id,
      tournamentId: result.rows[0].tournament_id,
      level: result.rows[0].level_number,
      smallBlind: Number(result.rows[0].small_blind),
      bigBlind: Number(result.rows[0].big_blind),
      ante: Number(result.rows[0].ante),
      durationMinutes: Number(result.rows[0].duration_minutes),
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to create blind level' });
  }
});

module.exports = router;
