const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

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
  const { pool } = require('../config/database');
  const { requireAuth, requireAdmin } = require('../middleware/authMiddleware');

  // List public posts
  router.get('/', async (req, res) => {
    try {
      const result = await pool.query('SELECT p.*, u.login as author_login FROM posts p LEFT JOIN users u ON u.id = p.author_id WHERE p.is_published = true ORDER BY created_at DESC');
      res.json(result.rows);
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: 'Failed to list posts' });
    }
  });

  // Admin create post
  router.post('/', requireAuth, requireAdmin, upload.single('image'), async (req, res) => {
    try {
      const { title, body, is_published } = req.body;
      let imageUrl = null;
      if (req.file) imageUrl = `/uploads/${req.file.filename}`;

      const authorId = req.user?.sub || null;
      const result = await pool.query(
        `INSERT INTO posts (author_id, title, body, image_url, is_published) VALUES ($1,$2,$3,$4,$5) RETURNING *`,
        [authorId, title, body || null, imageUrl, is_published === 'true' || is_published === true]
      );
      res.status(201).json(result.rows[0]);
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: 'Failed to create post' });
    }
  });

  // Admin delete post
  router.delete('/:id', requireAuth, requireAdmin, async (req, res) => {
    try {
      const { id } = req.params;
      const existing = await pool.query('SELECT image_url FROM posts WHERE id = $1', [id]);
      if (existing.rows.length === 0) return res.status(404).json({ message: 'Not found' });
      const imageUrl = existing.rows[0].image_url;
      await pool.query('DELETE FROM posts WHERE id = $1', [id]);
      if (imageUrl && imageUrl.startsWith('/uploads/')) {
        const filename = imageUrl.replace('/uploads/', '');
        const filePath = path.join(uploadDir, filename);
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
        }
      }
      res.status(204).end();
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: 'Failed to delete post' });
    }
  });

  return router;
})();
