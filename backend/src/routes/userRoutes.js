const express = require('express');
const { query } = require('../config/database');
const { requireAuth } = require('../middleware/authMiddleware');

const router = express.Router();

function sanitizeUser(user) {
  return {
    id: user.id,
    login: user.login,
    email: user.email,
    role: user.role,
    firstName: user.first_name,
    lastName: user.last_name,
    avatarUrl: user.avatar_url,
    isActive: user.is_active,
    createdAt: user.created_at,
    lastLoginAt: user.last_login_at,
  };
}

// GET /api/v1/users/me - Get current authenticated user
router.get('/me', requireAuth, async (req, res) => {
  try {
    const userId = req.user.sub;
    
    const result = await query(
      `SELECT * FROM users WHERE id = $1`,
      [userId]
    );

    if (!result.rows[0]) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json(sanitizeUser(result.rows[0]));
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch current user' });
  }
});

// GET /api/v1/users/profile - Get profile of authenticated user
router.get('/profile', requireAuth, async (req, res) => {
  try {
    const userId = req.user.sub;
    
    const result = await query(
      `SELECT * FROM users WHERE id = $1`,
      [userId]
    );

    if (!result.rows[0]) {
      return res.status(404).json({ message: 'Profile not found' });
    }

    res.json(sanitizeUser(result.rows[0]));
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch profile' });
  }
});

// POST /api/v1/users/profile - Update profile of authenticated user
router.post('/profile', requireAuth, async (req, res) => {
  try {
    const userId = req.user.sub;
    const { login, email, firstName, lastName, avatarUrl } = req.body || {};

    const result = await query(
      `UPDATE users
       SET login = COALESCE($1, login),
           email = COALESCE($2, email),
           first_name = COALESCE($3, first_name),
           last_name = COALESCE($4, last_name),
           avatar_url = COALESCE($5, avatar_url)
       WHERE id = $6
       RETURNING *`,
      [login, email, firstName, lastName, avatarUrl, userId]
    );

    if (!result.rows[0]) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json(sanitizeUser(result.rows[0]));
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to update profile' });
  }
});

// GET /api/v1/users/:id - Get profile by ID (with pagination for rating history)
router.get('/:id/tournament-history', requireAuth, async (req, res) => {
  try {
    const { id } = req.params;
    const currentUserId = req.user.sub;

    if (req.user.role !== 'admin' && currentUserId !== id) {
      return res.status(403).json({ message: 'Forbidden' });
    }

    const result = await query(
      `
        SELECT
          tp.tournament_id,
          t.name AS tournament_name,
          t.start_date,
          t.end_date,
          t.status,
          tr.position,
          tr.rating_earned,
          tr.rps_earned,
          tp.registered_at
        FROM tournament_players tp
        LEFT JOIN tournaments t ON t.id = tp.tournament_id
        LEFT JOIN tournament_results tr ON tr.tournament_id = tp.tournament_id AND tr.user_id = tp.user_id
        WHERE tp.user_id = $1
        ORDER BY t.start_date DESC
      `,
      [id]
    );

    res.json({
      data: result.rows.map((row) => ({
        tournamentId: row.tournament_id,
        tournamentName: row.tournament_name,
        startDate: row.start_date,
        endDate: row.end_date,
        status: row.status,
        position: row.position ? Number(row.position) : null,
        ratingEarned: row.rating_earned ? Number(row.rating_earned) : 0,
        rpsEarned: row.rps_earned ? Number(row.rps_earned) : 0,
        registeredAt: row.registered_at,
      })),
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch tournament history' });
  }
});

router.get('/:id', requireAuth, async (req, res) => {
  try {
    const { id } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;

    const userResult = await query(
      `SELECT * FROM users WHERE id = $1`,
      [id]
    );

    if (!userResult.rows[0]) {
      return res.status(404).json({ message: 'User not found' });
    }

    const ratingHistoryResult = await query(
      `SELECT * FROM rating_history WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3`,
      [id, limit, offset]
    );

    const rankResult = await query(
      `SELECT * FROM ranks ORDER BY minimum_points DESC LIMIT 1`
    );

    res.json({
      ...sanitizeUser(userResult.rows[0]),
      rating: Number(userResult.rows[0].rating),
      rank: rankResult.rows[0] ? {
        id: rankResult.rows[0].id,
        code: rankResult.rows[0].code,
        name: rankResult.rows[0].name,
        minimumPoints: Number(rankResult.rows[0].minimum_points),
      } : null,
      ratingHistory: ratingHistoryResult.rows.map((row) => ({
        id: row.id,
        delta: Number(row.delta),
        reason: row.reason,
        createdAt: row.created_at,
      })),
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch user profile' });
  }
});

module.exports = router;
