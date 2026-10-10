const express = require('express');
const { query } = require('../config/database');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const router = express.Router();

const { pool } = require('../config/database');
const { requireAuth, requireAdmin } = require('../middleware/authMiddleware');

// ========================================
// Multer config for logo uploads
// ========================================
const uploadsDir = path.join(__dirname, '..', '..', 'uploads', 'logos');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadsDir),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname) || '.png';
    const name = `logo_${Date.now()}${ext}`;
    cb(null, name);
  },
});

const fileFilter = (req, file, cb) => {
  const allowed = /\.(jpg|jpeg|png|gif|svg|webp)$/i;
  if (allowed.test(file.originalname)) {
    cb(null, true);
  } else {
    cb(new Error('Недопустимый формат файла. Используйте JPG, PNG, GIF, SVG, WEBP'));
  }
};

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter,
});

router.get('/workspace', async (req, res) => {
  try {
    const workspaceResult = await query(`SELECT * FROM admin_workspace ORDER BY updated_at DESC LIMIT 1`);
    const transactionsResult = await query(`SELECT * FROM tournament_players LIMIT 10`);
    const campaigns = [
      { id: 'welcome', title: 'Приветственный бонус', description: '500 бонусных баллов новым игрокам', active: true },
      { id: 'weekly', title: 'Еженедельный кэшбэк', description: '5% от турнирных взносов', active: false },
    ];

    const workspace = workspaceResult.rows[0] || {
      club_name: 'Poker Club ERM',
      club_short_name: 'ERM',
      logo_asset_path: 'assets/logos/logo_white.svg',
      currency: 'RUB',
      notifications_enabled: true,
      club_description: 'Место для честной игры, ярких турниров и сильного сообщества.',
    };

    // Build full logo URL if it's a relative path (uploaded file)
    let logoUrl = workspace.logo_asset_path;
    if (logoUrl && !logoUrl.startsWith('http') && !logoUrl.startsWith('assets/')) {
      logoUrl = `http://localhost:${process.env.PORT || 4000}${logoUrl}`;
    }

    res.json({
      club_name: workspace.club_name,
      club_short_name: workspace.club_short_name,
      logo_asset_path: workspace.logo_asset_path,
      logo_url: logoUrl,
      club_description: workspace.club_description || 'Место для честной игры, ярких турниров и сильного сообщества.',
      currency: workspace.currency,
      notifications_enabled: workspace.notifications_enabled,
      address: workspace.address,
      city: workspace.city,
      transactions: transactionsResult.rows.map((tx) => ({
        id: tx.id,
        description: 'Участие в турнире',
        amount: 1000,
        created_at: tx.registered_at,
      })),
      campaigns,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch admin workspace' });
  }
});

router.get('/ranks', async (req, res) => {
  try {
    const result = await query(`SELECT * FROM ranks ORDER BY minimum_points ASC`);
    res.json(result.rows.map((row) => ({
      id: row.id,
      code: row.code,
      name: row.name,
      minimumPoints: Number(row.minimum_points),
      description: row.description,
    })));
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch ranks' });
  }
});

router.get('/players', async (req, res) => {
  try {
    const result = await query(`SELECT * FROM users ORDER BY created_at DESC LIMIT 20`);
    res.json(result.rows.map((row) => ({
      id: row.id,
      login: row.login,
      name: row.first_name || row.login,
      email: row.email,
      rank: 'gold',
      rankPoints: 1200,
      tournaments: 0,
      wins: 0,
    })));
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch admin players' });
  }
});

// ========================================
// Upload logo (admin only)
// ========================================
router.post('/logo', requireAuth, requireAdmin, upload.single('logo'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'Файл не загружен' });
    }

    const logoUrl = `/uploads/logos/${req.file.filename}`;

    // Update workspace with new logo path
    await pool.query(
      `UPDATE admin_workspace SET logo_asset_path = COALESCE($1, logo_asset_path), updated_at = NOW() RETURNING *`,
      [logoUrl]
    );

    res.json({
      message: 'Логотип загружен',
      logo_url: logoUrl,
      filename: req.file.filename,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Ошибка загрузки логотипа' });
  }
});

// ========================================
// Update workspace settings (admin only)
// ========================================
router.post('/workspace', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { club_name, club_short_name, logo_asset_path, currency, notifications_enabled, address, city, club_description } = req.body || {};
    const result = await pool.query(
      `UPDATE admin_workspace SET club_name = COALESCE($1, club_name), club_short_name = COALESCE($2, club_short_name), logo_asset_path = COALESCE($3, logo_asset_path), currency = COALESCE($4, currency), notifications_enabled = COALESCE($5, notifications_enabled), address = COALESCE($6, address), city = COALESCE($7, city), club_description = COALESCE($8, club_description), updated_at = NOW() RETURNING *`,
      [club_name, club_short_name, logo_asset_path, currency, notifications_enabled, address, city, club_description]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Failed to update workspace' });
  }
});

module.exports = router;
