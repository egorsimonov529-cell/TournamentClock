const express = require('express');
const { query } = require('../config/database');
const { requireAuth, requireAdmin } = require('../middleware/authMiddleware');

const router = express.Router();

// GET /api/v1/bonuses - Get all active bonuses
router.get('/', async (req, res) => {
  try {
    const { type, active } = req.query;

    let whereClause = '';
    const params = [];
    let paramIndex = 1;

    if (type) {
      whereClause += ` WHERE type = $${paramIndex}`;
      params.push(type);
      paramIndex++;
    }

    if (active !== undefined) {
      if (whereClause) {
        whereClause += ` AND is_active = $${paramIndex}`;
      } else {
        whereClause += ` WHERE is_active = $${paramIndex}`;
      }
      params.push(active === 'true');
      paramIndex++;
    }

    const result = await query(
      `SELECT * FROM bonuses${whereClause} ORDER BY created_at DESC`,
      params
    );

    res.json(result.rows.map((row) => ({
      id: row.id,
      title: row.title,
      description: row.description,
      type: row.type,
      value: row.value,
      conditions: row.conditions,
      isActive: row.is_active,
      createdAt: row.created_at,
    })));
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch bonuses' });
  }
});

// POST /api/v1/bonuses - Create bonus (admin only)
router.post('/', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { title, description, type, value, conditions, is_active } = req.body || {};

    if (!title) {
      return res.status(400).json({ message: 'title is required' });
    }

    const result = await query(
      `INSERT INTO bonuses (title, description, type, value, conditions, is_active)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [title, description || '', type || 'general', value || '', conditions || '', is_active !== false]
    );

    res.status(201).json({
      id: result.rows[0].id,
      title: result.rows[0].title,
      description: result.rows[0].description,
      type: result.rows[0].type,
      value: result.rows[0].value,
      conditions: result.rows[0].conditions,
      isActive: result.rows[0].is_active,
      createdAt: result.rows[0].created_at,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to create bonus' });
  }
});

// PATCH /api/v1/bonuses/:id - Update bonus (admin only)
router.patch('/:id', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, type, value, conditions, is_active } = req.body || {};

    const result = await query(
      `UPDATE bonuses 
       SET title = COALESCE($1, title),
           description = COALESCE($2, description),
           type = COALESCE($3, type),
           value = COALESCE($4, value),
           conditions = COALESCE($5, conditions),
           is_active = COALESCE($6, is_active),
           updated_at = NOW()
       WHERE id = $7
       RETURNING *`,
      [title, description, type, value, conditions, is_active, id]
    );

    if (!result.rows[0]) {
      return res.status(404).json({ message: 'Bonus not found' });
    }

    res.json({
      id: result.rows[0].id,
      title: result.rows[0].title,
      description: result.rows[0].description,
      type: result.rows[0].type,
      value: result.rows[0].value,
      conditions: result.rows[0].conditions,
      isActive: result.rows[0].is_active,
      createdAt: result.rows[0].created_at,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to update bonus' });
  }
});

// DELETE /api/v1/bonuses/:id - Delete bonus (admin only)
router.delete('/:id', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;

    const result = await query(`DELETE FROM bonuses WHERE id = $1 RETURNING *`, [id]);

    if (!result.rows[0]) {
      return res.status(404).json({ message: 'Bonus not found' });
    }

    res.json({ ok: true });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to delete bonus' });
  }
});

module.exports = router;
