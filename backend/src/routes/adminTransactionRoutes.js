const express = require('express');
const { query } = require('../config/database');
const { requireAuth, requireAdmin } = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/', requireAuth, requireAdmin, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;

    const typeFilter = req.query.type || null;
    const userFilter = req.query.user_id || null;

    let whereClause = '';
    const params = [];
    let paramIndex = 1;

    if (typeFilter) {
      whereClause += ` WHERE type = $${paramIndex}`;
      params.push(typeFilter);
      paramIndex++;
    }

    if (userFilter) {
      if (whereClause) {
        whereClause += ` AND user_id = $${paramIndex}`;
      } else {
        whereClause += ` WHERE user_id = $${paramIndex}`;
      }
      params.push(userFilter);
      paramIndex++;
    }

    const countResult = await query(
      `SELECT COUNT(*) FROM transactions${whereClause}`,
      params
    );

    const totalItems = parseInt(countResult.rows[0].count);
    const totalPages = Math.ceil(totalItems / limit);

    const result = await query(
      `SELECT * FROM transactions${whereClause} ORDER BY created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
      [...params, limit, offset]
    );

    res.json({
      data: result.rows.map((row) => ({
        id: row.id,
        userId: row.user_id,
        type: row.type,
        description: row.description,
        amount: Number(row.amount),
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
    res.status(500).json({ message: 'Failed to fetch transactions' });
  }
});

router.post('/', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { user_id, type, description, amount } = req.body || {};

    console.log('[TRANSACTIONS] POST request received:', { user_id, type, description, amount });

    if (!description || amount === undefined || amount === null || amount === '') {
      console.log('[TRANSACTIONS] Validation failed: missing description or amount');
      return res.status(400).json({ message: 'description and amount are required' });
    }

    // Преобразуем amount в число
    const numericAmount = typeof amount === 'string' ? parseFloat(amount) : Number(amount);
    
    if (isNaN(numericAmount)) {
      console.log('[TRANSACTIONS] Invalid amount:', amount);
      return res.status(400).json({ message: 'Некорректная сумма' });
    }

    console.log('[TRANSACTIONS] Inserting transaction:', { user_id, type: type || 'general', description, amount: numericAmount });

    const result = await query(
      `INSERT INTO transactions (user_id, type, description, amount)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [user_id || null, type || 'general', description, numericAmount]
    );

    console.log('[TRANSACTIONS] Transaction created successfully:', result.rows[0]);

    res.status(201).json({
      id: result.rows[0].id,
      userId: result.rows[0].user_id,
      type: result.rows[0].type,
      description: result.rows[0].description,
      amount: Number(result.rows[0].amount),
      createdAt: result.rows[0].created_at,
    });
  } catch (error) {
    console.error('[TRANSACTIONS] Error creating transaction:', error);
    res.status(500).json({ message: 'Failed to create transaction', error: error.message });
  }
});

module.exports = router;
