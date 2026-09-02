const express = require('express');
const { query } = require('../config/database');
const { requireAuth, requireAdmin } = require('../middleware/authMiddleware');

const router = express.Router();

// GET /api/v1/loyalty/campaigns - Get all campaigns
router.get('/campaigns', async (req, res) => {
  try {
    const { active } = req.query;

    let whereClause = '';
    const params = [];
    let paramIndex = 1;

    if (active !== undefined) {
      whereClause += ` WHERE is_active = $${paramIndex}`;
      params.push(active === 'true');
      paramIndex++;
    }

    const result = await query(
      `SELECT * FROM loyalty_campaigns${whereClause} ORDER BY created_at DESC`,
      params
    );

    res.json(result.rows.map((row) => ({
      id: row.id,
      title: row.title,
      description: row.description,
      isActive: row.active,
      createdAt: row.created_at,
    })));
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch loyalty campaigns' });
  }
});

// POST /api/v1/loyalty/campaigns - Create campaign (admin only)
router.post('/campaigns', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { title, description, active } = req.body || {};

    if (!title) {
      return res.status(400).json({ message: 'title is required' });
    }

    const result = await query(
      `INSERT INTO loyalty_campaigns (title, description, active)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [title, description || '', active !== false]
    );

    res.status(201).json({
      id: result.rows[0].id,
      title: result.rows[0].title,
      description: result.rows[0].description,
      isActive: result.rows[0].active,
      createdAt: result.rows[0].created_at,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to create loyalty campaign' });
  }
});

// PATCH /api/v1/loyalty/campaigns/:id - Update campaign (admin only)
router.patch('/campaigns/:id', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, active } = req.body || {};

    const result = await query(
      `UPDATE loyalty_campaigns 
       SET title = COALESCE($1, title),
           description = COALESCE($2, description),
           active = COALESCE($3, active),
           updated_at = NOW()
       WHERE id = $4
       RETURNING *`,
      [title, description, active, id]
    );

    if (!result.rows[0]) {
      return res.status(404).json({ message: 'Loyalty campaign not found' });
    }

    res.json({
      id: result.rows[0].id,
      title: result.rows[0].title,
      description: result.rows[0].description,
      isActive: result.rows[0].active,
      createdAt: result.rows[0].created_at,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to update loyalty campaign' });
  }
});

// DELETE /api/v1/loyalty/campaigns/:id - Delete campaign (admin only)
router.delete('/campaigns/:id', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;

    const result = await query(`DELETE FROM loyalty_campaigns WHERE id = $1 RETURNING *`, [id]);

    if (!result.rows[0]) {
      return res.status(404).json({ message: 'Loyalty campaign not found' });
    }

    res.json({ ok: true });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to delete loyalty campaign' });
  }
});

module.exports = router;
