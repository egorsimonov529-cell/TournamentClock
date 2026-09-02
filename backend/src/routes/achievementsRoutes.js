const express = require('express');
const multer = require('multer');
const path = require('path');

const uploadDir = path.join(__dirname, '..', '..', 'uploads');
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const unique = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, unique + '-' + file.originalname);
  }
});
const upload = multer({ storage });

module.exports = (function () {
  const router = express.Router();
  const { requireAuth, requireAdmin } = require('../middleware/authMiddleware');
  const { pool } = require('../config/database');

  router.get('/', async (req, res) => {
    try {
      const result = await pool.query('SELECT * FROM achievements ORDER BY created_at DESC');
      res.json(result.rows);
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: 'Failed to list achievements' });
    }
  });

  router.get('/:id', async (req, res) => {
    try {
      const { id } = req.params;
      const result = await pool.query('SELECT * FROM achievements WHERE id = $1', [id]);
      if (result.rows.length === 0) return res.status(404).json({ message: 'Not found' });
      res.json(result.rows[0]);
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: 'Failed to get achievement' });
    }
  });

  router.post('/', requireAuth, requireAdmin, upload.single('image'), async (req, res) => {
    try {
      const { title, description, current_value, target_value, achieved } = req.body;
      let imageUrl = null;
      if (req.file) {
        imageUrl = `/uploads/${req.file.filename}`;
      }
      const result = await pool.query(
        `INSERT INTO achievements (title, description, image_url, current_value, target_value, achieved)
         VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
        [title, description || null, imageUrl, current_value || 0, target_value || 1, achieved === 'true' || achieved === true]
      );
      res.status(201).json(result.rows[0]);
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: 'Failed to create achievement' });
    }
  });

  router.put('/:id', requireAuth, requireAdmin, upload.single('image'), async (req, res) => {
    try {
      const { id } = req.params;
      const { title, description, current_value, target_value, achieved } = req.body;

      // Fetch existing to possibly delete old image
      const existingRes = await pool.query('SELECT * FROM achievements WHERE id = $1', [id]);
      if (existingRes.rows.length === 0) return res.status(404).json({ message: 'Not found' });
      const existing = existingRes.rows[0];

      let imageUrl = null;
      if (req.file) {
        imageUrl = `/uploads/${req.file.filename}`;
      }

      const updates = [];
      const values = [];
      let idx = 1;

      if (title !== undefined) { updates.push(`title = $${idx++}`); values.push(title); }
      if (description !== undefined) { updates.push(`description = $${idx++}`); values.push(description); }
      if (imageUrl !== null) { updates.push(`image_url = $${idx++}`); values.push(imageUrl); }
      if (current_value !== undefined) { updates.push(`current_value = $${idx++}`); values.push(current_value); }
      if (target_value !== undefined) { updates.push(`target_value = $${idx++}`); values.push(target_value); }
      if (achieved !== undefined) { updates.push(`achieved = $${idx++}`); values.push(achieved === 'true' || achieved === true); }

      if (updates.length === 0) return res.status(400).json({ message: 'No fields to update' });

      values.push(id);
      const q = `UPDATE achievements SET ${updates.join(', ')}, updated_at = NOW() WHERE id = $${idx} RETURNING *`;
      const result = await pool.query(q, values);
      if (result.rows.length === 0) return res.status(404).json({ message: 'Not found' });

      // If we uploaded a new image and old image was in /uploads, try deleting old file
      try {
        if (imageUrl !== null && existing.image_url && existing.image_url.startsWith('/uploads/')) {
          const fs = require('fs');
          const oldFilename = existing.image_url.replace('/uploads/', '');
          const oldPath = path.join(uploadDir, oldFilename);
          if (fs.existsSync(oldPath)) {
            fs.unlinkSync(oldPath);
          }
        }
      } catch (e) {
        console.warn('Failed to remove old image:', e);
      }

      res.json(result.rows[0]);
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: 'Failed to update achievement' });
    }
  });

  router.delete('/:id', requireAuth, requireAdmin, async (req, res) => {
    try {
      const { id } = req.params;
      await pool.query('DELETE FROM achievements WHERE id = $1', [id]);
      res.status(204).end();
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: 'Failed to delete achievement' });
    }
  });

  return router;
})();
