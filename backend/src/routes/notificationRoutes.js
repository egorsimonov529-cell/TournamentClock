const express = require('express');
const { query } = require('../config/database');
const { requireAuth } = require('../middleware/authMiddleware');

const router = express.Router();

// GET /api/v1/notifications - Get notifications for current user
router.get('/', requireAuth, async (req, res) => {
  try {
    const userId = req.user.sub;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;
    const unreadOnly = req.query.unread === 'true';

    let whereClause = 'WHERE user_id = $1';
    const params = [userId];
    let paramIndex = 2;

    if (unreadOnly) {
      whereClause += ' AND is_read = false';
    }

    const countResult = await query(
      `SELECT COUNT(*) FROM notifications ${whereClause}`,
      params
    );

    const totalItems = parseInt(countResult.rows[0].count);
    const totalPages = Math.ceil(totalItems / limit);

    const result = await query(
      `SELECT * FROM notifications ${whereClause} ORDER BY created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
      [...params, limit, offset]
    );

    res.json({
      data: result.rows.map((row) => ({
        id: row.id,
        userId: row.user_id,
        title: row.title,
        message: row.message,
        isRead: row.is_read,
        createdAt: row.created_at,
      })),
      pagination: {
        page,
        limit,
        totalItems,
        totalPages,
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch notifications' });
  }
});

// POST /api/v1/notifications - Create notification (admin only)
router.post('/', requireAuth, async (req, res) => {
  try {
    const currentUserId = req.user.sub;
    const currentRole = req.user.role;
    const { user_id, title, message } = req.body || {};

    if (!title || !message) {
      return res.status(400).json({ message: 'title and message are required' });
    }

    // Only admins can send notifications to users
    if (currentRole !== 'admin' && !user_id) {
      return res.status(403).json({ message: 'Only admins can send notifications to users' });
    }

    const targetUserId = currentRole === 'admin' ? (user_id || null) : currentUserId;

    const result = await query(
      `INSERT INTO notifications (user_id, title, message)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [targetUserId, title, message]
    );

    res.status(201).json({
      id: result.rows[0].id,
      userId: result.rows[0].user_id,
      title: result.rows[0].title,
      message: result.rows[0].message,
      isRead: result.rows[0].is_read,
      createdAt: result.rows[0].created_at,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to create notification' });
  }
});

// PATCH /api/v1/notifications/:id/read - Mark notification as read
router.patch('/:id/read', requireAuth, async (req, res) => {
  try {
    const userId = req.user.sub;
    const { id } = req.params;

    const result = await query(
      `UPDATE notifications 
       SET is_read = true 
       WHERE id = $1 AND user_id = $2 
       RETURNING *`,
      [id, userId]
    );

    if (!result.rows[0]) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    res.json({
      id: result.rows[0].id,
      userId: result.rows[0].user_id,
      title: result.rows[0].title,
      message: result.rows[0].message,
      isRead: result.rows[0].is_read,
      createdAt: result.rows[0].created_at,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to update notification' });
  }
});

// POST /api/v1/notifications/mark-all-read - Mark all notifications as read
router.post('/mark-all-read', requireAuth, async (req, res) => {
  try {
    const userId = req.user.sub;

    await query(
      `UPDATE notifications SET is_read = true WHERE user_id = $1 AND is_read = false`,
      [userId]
    );

    res.json({ ok: true, message: 'All notifications marked as read' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to mark notifications as read' });
  }
});

module.exports = router;
