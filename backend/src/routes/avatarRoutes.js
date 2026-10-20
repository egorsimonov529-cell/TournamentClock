const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { query } = require('../config/database');
const { requireAuth } = require('../middleware/authMiddleware');

const router = express.Router();

// Настройка хранилища для multer
const uploadsDir = path.join(__dirname, '..', '..', 'uploads', 'avatars');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadsDir);
  },
  filename: function (req, file, cb) {
    const userId = req.user.sub;
    const ext = path.extname(file.originalname);
    cb(null, `avatar-${userId}-${Date.now()}${ext}`);
  },
});

const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif|webp/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);
  
  if (mimetype && extname) {
    return cb(null, true);
  } else {
    cb(new Error('Разрешены только изображения (jpeg, jpg, png, gif, webp)'));
  }
};

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB
  },
  fileFilter: fileFilter,
});

// POST /api/v1/users/avatar - Upload user avatar
router.post('/avatar', requireAuth, upload.single('avatar'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'Файл не выбран' });
    }

    const userId = req.user.sub;
    const avatarUrl = `/uploads/avatars/${req.file.filename}`;

    // Обновляем avatar_url в базе данных
    await query(
      `UPDATE users SET avatar_url = $1 WHERE id = $2`,
      [avatarUrl, userId]
    );

    res.json({
      message: 'Аватарка загружена',
      avatarUrl: avatarUrl,
    });
  } catch (error) {
    console.error('Ошибка загрузки аватарки:', error);
    res.status(500).json({ message: 'Ошибка загрузки аватарки' });
  }
});

// DELETE /api/v1/users/avatar - Delete user avatar
router.delete('/avatar', requireAuth, async (req, res) => {
  try {
    const userId = req.user.sub;

    // Получаем текущий путь к аватарке
    const result = await query(
      `SELECT avatar_url FROM users WHERE id = $1`,
      [userId]
    );

    if (result.rows[0] && result.rows[0].avatar_url) {
      // Удаляем файл с диска
      const filePath = path.join(__dirname, '..', '..', result.rows[0].avatar_url);
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    }

    // Обновляем avatar_url в базе данных
    await query(
      `UPDATE users SET avatar_url = NULL WHERE id = $1`,
      [userId]
    );

    res.json({ message: 'Аватарка удалена' });
  } catch (error) {
    console.error('Ошибка удаления аватарки:', error);
    res.status(500).json({ message: 'Ошибка удаления аватарки' });
  }
});

module.exports = router;
