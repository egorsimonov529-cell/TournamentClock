const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { query } = require('../config/database');

const router = express.Router();

// ── Multer config for file uploads ─────────────────────────────────────────

const UPLOAD_DIR = path.join(__dirname, '../../uploads/tv-logos');
if (!fs.existsSync(UPLOAD_DIR)) {
  fs.mkdirSync(UPLOAD_DIR, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, UPLOAD_DIR),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'tv-logo-' + uniqueSuffix + path.extname(file.originalname));
  },
});

const fileFilter = (req, file, cb) => {
  const allowed = /jpeg|jpg|png|gif|svg|webp/;
  const ext = allowed.test(path.extname(file.originalname).toLowerCase());
  const mime = allowed.test(file.mimetype.replace('image/', ''));
  if (ext || mime) cb(null, true);
  else cb(new Error('Недопустимый тип файла'));
};

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter,
});

// ── Tournament Grids ────────────────────────────────────────────────────────

router.get('/grids', async (req, res) => {
  try {
    const result = await query(
      `SELECT id, name, blind_levels, tv_background, tv_logo
       FROM tournament_grids
       ORDER BY created_at ASC`
    );

    res.json(
      result.rows.map((row) => ({
        id: row.id,
        name: row.name,
        blindLevels: row.blind_levels || [],
        tvBackground: row.tv_background || 'dark',
        tvLogoUrl: row.tv_logo,
      }))
    );
  } catch (error) {
    console.error('Error fetching grids:', error);
    // Table may not exist yet — return empty
    res.json([]);
  }
});

router.post('/grids', async (req, res) => {
  try {
    const { name, blindLevels, tvBackground, tvLogoUrl } = req.body || {};

    if (!name) {
      return res.status(400).json({ message: 'Name is required' });
    }

    const result = await query(
      `INSERT INTO tournament_grids (name, blind_levels, tv_background, tv_logo)
       VALUES ($1, $2, $3, $4)
       RETURNING id, name, blind_levels, tv_background, tv_logo, created_at`,
      [name, JSON.stringify(blindLevels || []), tvBackground || 'dark', tvLogoUrl || null]
    );

    const row = result.rows[0];
    res.status(201).json({
      id: row.id,
      name: row.name,
      blindLevels: row.blind_levels || [],
      tvBackground: row.tv_background || 'dark',
      tvLogoUrl: row.tv_logo,
    });
  } catch (error) {
    console.error('Error creating grid:', error);
    res.status(500).json({ message: 'Failed to create grid', error: error.message });
  }
});

router.put('/grids/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, blindLevels, tvBackground, tvLogoUrl } = req.body || {};

    const result = await query(
      `UPDATE tournament_grids
       SET name = $1, blind_levels = $2, tv_background = $3, tv_logo = $4
       WHERE id = $5
       RETURNING id, name, blind_levels, tv_background, tv_logo`,
      [name, JSON.stringify(blindLevels || []), tvBackground || 'dark', tvLogoUrl || null, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Grid not found' });
    }

    const row = result.rows[0];
    res.json({
      id: row.id,
      name: row.name,
      blindLevels: row.blind_levels || [],
      tvBackground: row.tv_background || 'dark',
      tvLogoUrl: row.tv_logo,
    });
  } catch (error) {
    console.error('Error updating grid:', error);
    res.status(500).json({ message: 'Failed to update grid', error: error.message });
  }
});

router.patch('/grids/:id', async (req, res) => {
  // Alias for PUT
  const { id } = req.params;
  const { name, blindLevels, tvBackground, tvLogoUrl } = req.body || {};

  try {
    const result = await query(
      `UPDATE tournament_grids
       SET name = $1, blind_levels = $2, tv_background = $3, tv_logo = $4
       WHERE id = $5
       RETURNING id, name, blind_levels, tv_background, tv_logo`,
      [name, JSON.stringify(blindLevels || []), tvBackground || 'dark', tvLogoUrl || null, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Grid not found' });
    }

    const row = result.rows[0];
    res.json({
      id: row.id,
      name: row.name,
      blindLevels: row.blind_levels || [],
      tvBackground: row.tv_background || 'dark',
      tvLogoUrl: row.tv_logo,
    });
  } catch (error) {
    console.error('Error updating grid:', error);
    res.status(500).json({ message: 'Failed to update grid', error: error.message });
  }
});

// ── Blind Levels (existing) ────────────────────────────────────────────────

router.delete('/grids/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await query(
      `DELETE FROM tournament_grids WHERE id = $1 RETURNING id`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Grid not found' });
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Error deleting grid:', error);
    res.status(500).json({ message: 'Failed to delete grid', error: error.message });
  }
});

// ── Blind Levels (existing) ────────────────────────────────────────────────

router.get('/blind-levels', async (req, res) => {
  try {
    const tournamentId = req.query.tournament_id;

    if (tournamentId) {
      const result = await query(
        `SELECT * FROM blind_levels 
         WHERE tournament_id = $1 
         ORDER BY level_number ASC`,
        [tournamentId]
      );

      return res.json(result.rows.map((row) => ({
        id: row.id,
        tournamentId: row.tournament_id,
        level: row.level_number,
        smallBlind: Number(row.small_blind),
        bigBlind: Number(row.big_blind),
        ante: Number(row.ante),
        durationMinutes: Number(row.duration_minutes),
      })));
    }

    // Default blind levels if no tournament specified
    const defaultLevels = [
      { level: 1, smallBlind: 25, bigBlind: 50, ante: 0, durationMinutes: 15 },
      { level: 2, smallBlind: 50, bigBlind: 100, ante: 25, durationMinutes: 15 },
      { level: 3, smallBlind: 100, bigBlind: 200, ante: 50, durationMinutes: 20 },
      { level: 4, smallBlind: 200, bigBlind: 400, ante: 100, durationMinutes: 20 },
      { level: 5, smallBlind: 300, bigBlind: 600, ante: 150, durationMinutes: 20 },
      { level: 6, smallBlind: 400, bigBlind: 800, ante: 200, durationMinutes: 25 },
      { level: 7, smallBlind: 500, bigBlind: 1000, ante: 250, durationMinutes: 25 },
      { level: 8, smallBlind: 750, bigBlind: 1500, ante: 375, durationMinutes: 30 },
    ];

    res.json(defaultLevels);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch blind levels' });
  }
});

router.post('/', async (req, res) => {
  try {
    const { tournament_id, level_number, small_blind, big_blind, ante, duration_minutes } = req.body || {};

    if (!tournament_id || !level_number) {
      return res.status(400).json({ message: 'tournament_id and level_number are required' });
    }

    const result = await query(
      `INSERT INTO blind_levels (tournament_id, level_number, small_blind, big_blind, ante, duration_minutes)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [tournament_id, level_number, small_blind || 0, big_blind || 0, ante || 0, duration_minutes || 10]
    );

    res.status(201).json({
      id: result.rows[0].id,
      tournamentId: result.rows[0].tournament_id,
      level: result.rows[0].level_number,
      smallBlind: Number(result.rows[0].small_blind),
      bigBlind: Number(result.rows[0].big_blind),
      ante: Number(result.rows[0].ante),
      durationMinutes: Number(result.rows[0].duration_minutes),
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to create blind level' });
  }
});

// ── TV Logo Upload ─────────────────────────────────────────────────────────

router.post('/tv-logo', upload.single('logo'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'Файл не загружен' });
    }

    const logoUrl = `/uploads/tv-logos/${req.file.filename}`;
    
    res.status(201).json({
      message: 'Логотип загружен',
      logoUrl,
    });
  } catch (error) {
    console.error('Error uploading TV logo:', error);
    res.status(500).json({ message: 'Ошибка загрузки логотипа', error: error.message });
  }
});

module.exports = router;
