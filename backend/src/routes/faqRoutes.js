const express = require('express');
const { query } = require('../config/database');
const { requireAuth, requireAdmin } = require('../middleware/authMiddleware');

const router = express.Router();

// GET /api/v1/faq - Get all active FAQ items
router.get('/', async (req, res) => {
  try {
    const result = await query(
      `SELECT * FROM faq WHERE is_active = true ORDER BY created_at ASC`
    );

    res.json(result.rows.map((row) => ({
      id: row.id,
      question: row.question,
      answer: row.answer,
      isActive: row.is_active,
      createdAt: row.created_at,
    })));
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch FAQ' });
  }
});

// POST /api/v1/faq - Create FAQ item (admin only)
router.post('/', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { question, answer, is_active } = req.body || {};

    if (!question || !answer) {
      return res.status(400).json({ message: 'question and answer are required' });
    }

    const result = await query(
      `INSERT INTO faq (question, answer, is_active)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [question, answer, is_active !== false]
    );

    res.status(201).json({
      id: result.rows[0].id,
      question: result.rows[0].question,
      answer: result.rows[0].answer,
      isActive: result.rows[0].is_active,
      createdAt: result.rows[0].created_at,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to create FAQ item' });
  }
});

// PATCH /api/v1/faq/:id - Update FAQ item (admin only)
router.patch('/:id', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { question, answer, is_active } = req.body || {};

    const result = await query(
      `UPDATE faq 
       SET question = COALESCE($1, question),
           answer = COALESCE($2, answer),
           is_active = COALESCE($3, is_active),
           updated_at = NOW()
       WHERE id = $4
       RETURNING *`,
      [question, answer, is_active, id]
    );

    if (!result.rows[0]) {
      return res.status(404).json({ message: 'FAQ item not found' });
    }

    res.json({
      id: result.rows[0].id,
      question: result.rows[0].question,
      answer: result.rows[0].answer,
      isActive: result.rows[0].is_active,
      createdAt: result.rows[0].created_at,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to update FAQ item' });
  }
});

// DELETE /api/v1/faq/:id - Delete FAQ item (admin only)
router.delete('/:id', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;

    const result = await query(`DELETE FROM faq WHERE id = $1 RETURNING *`, [id]);

    if (!result.rows[0]) {
      return res.status(404).json({ message: 'FAQ item not found' });
    }

    res.json({ ok: true });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to delete FAQ item' });
  }
});

module.exports = router;
