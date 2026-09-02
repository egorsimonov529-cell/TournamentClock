const express = require('express');
const { pool } = require('../config/database');
const { requireAuth, requireAdmin } = require('../middleware/authMiddleware');
const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const result = await pool.query(`SELECT id, login, first_name, last_name, avatar_url, rating, rps_points, rps_rank FROM users ORDER BY created_at DESC`);
    res.json(result.rows.map((row) => ({
      id: row.id,
      login: row.login,
      name: (row.first_name || row.login) + (row.last_name ? ' ' + row.last_name : ''),
      avatarUrl: row.avatar_url,
      rating: row.rating || 0,
      rpsPoints: row.rps_points || 0,
      rpsRank: row.rps_rank || 'FISH',
    })));
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch players' });
  }
});

router.get('/:id', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    console.log('Fetching player profile for id:', id);
    
    const userRes = await pool.query(
      'SELECT id, login, first_name, last_name, email, avatar_url, rating, rps_points, rps_rank, role FROM users WHERE id = $1 LIMIT 1',
      [id]
    );
    
    if (userRes.rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    const user = userRes.rows[0];

    const achievementsRes = await pool.query('SELECT * FROM achievements');
    const ratingHistoryRes = await pool.query(
      'SELECT * FROM rating_history WHERE user_id = $1 ORDER BY created_at DESC',
      [id]
    );

    console.log('Player profile fetched successfully');
    res.json({
      user: {
        id: user.id,
        login: user.login,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        phone_number: null,
        avatar_url: user.avatar_url,
        rating: user.rating || 0,
        rps_points: user.rps_points || 0,
        rps_rank: user.rps_rank || 'FISH',
        role: user.role,
      },
      achievements: achievementsRes.rows,
      ratingHistory: ratingHistoryRes.rows,
    });
  } catch (error) {
    console.error('Error fetching player profile:', error);
    res.status(500).json({ message: 'Failed to fetch profile', error: error.message });
  }
});

// Admin: add rating
router.post('/:id/rating', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { delta, reason } = req.body || {};
    const amount = parseInt(delta, 10) || 0;
    if (amount == 0) return res.status(400).json({ message: 'Invalid delta' });

    await pool.query('BEGIN');
    const userRes = await pool.query('SELECT rating, rps_points FROM users WHERE id = $1 FOR UPDATE', [id]);
    if (userRes.rows.length === 0) {
      await pool.query('ROLLBACK');
      return res.status(404).json({ message: 'User not found' });
    }
    const prev = userRes.rows[0].rating || 0;
    const prevRpsPoints = userRes.rows[0].rps_points || 0;
    const next = prev + amount;
    const rpsEarned = Math.floor(amount / 10);
    const nextRpsPoints = prevRpsPoints + rpsEarned;
    
    // Определяем новый ранг
    let newRank = 'FISH';
    if (nextRpsPoints >= 800) newRank = 'SHARK';
    else if (nextRpsPoints >= 600) newRank = 'GOLD';
    else if (nextRpsPoints >= 400) newRank = 'SILVER';
    else if (nextRpsPoints >= 200) newRank = 'BRONZE';
    
    await pool.query('UPDATE users SET rating = $1, rps_points = $2, rps_rank = $3 WHERE id = $4', [next, nextRpsPoints, newRank, id]);
    await pool.query('INSERT INTO rating_history (user_id, delta, reason) VALUES ($1, $2, $3)', [id, amount, reason || null]);
    await pool.query('COMMIT');

    res.json({ id, prev, next, rpsEarned, newRank });
  } catch (error) {
    try { await pool.query('ROLLBACK'); } catch (_) {}
    console.error(error);
    res.status(500).json({ message: 'Failed to add rating' });
  }
});

module.exports = router;
