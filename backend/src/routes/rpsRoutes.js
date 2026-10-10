const express = require('express');
const { query } = require('../config/database');
const { requireAuth, requireAdmin } = require('../middleware/authMiddleware');

const router = express.Router();

// ===== RPS Settings =====

// GET /api/v1/rps/settings - Получить настройки RPS
router.get('/settings', requireAuth, requireAdmin, async (req, res) => {
  try {
    const result = await query(`SELECT * FROM rps_settings ORDER BY updated_at DESC LIMIT 1`);
    const settings = result.rows[0] || {
      rating_per_rps: 10,
    };

    res.json({
      rating_per_rps: Number(settings.rating_per_rps) || 10,
    });
  } catch (error) {
    console.error('Error fetching RPS settings:', error);
    res.status(500).json({ message: 'Failed to fetch RPS settings' });
  }
});

// POST /api/v1/rps/settings - Сохранить настройки RPS
router.post('/settings', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { rating_per_rps } = req.body || {};
    const ratingPerRps = parseInt(rating_per_rps) || 10;

    const result = await query(`
      INSERT INTO rps_settings (rating_per_rps, updated_at)
      VALUES ($1, NOW())
      ON CONFLICT DO NOTHING
    `, [ratingPerRps]);

    // Если запись уже существует, обновляем
    if (result.rowCount === 0) {
      await query(`
        UPDATE rps_settings 
        SET rating_per_rps = $1, updated_at = NOW()
      `, [ratingPerRps]);
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Error saving RPS settings:', error);
    res.status(500).json({ message: 'Failed to save RPS settings' });
  }
});

// ===== Helper: Get RPS rank from points =====
function getRankFromPoints(points) {
  if (points >= 800) return { rank: 'SHARK', code: 'SHARK' };
  if (points >= 600) return { rank: 'PRO', code: 'GOLD' };
  if (points >= 400) return { rank: 'GRINDER', code: 'SILVER' };
  if (points >= 200) return { rank: 'REGULAR', code: 'BRONZE' };
  return { rank: 'FISH', code: 'FISH' };
}

// ===== Tournament Results =====

// GET /api/v1/tournaments/:id/results - Получить результаты турнира
router.get('/tournaments/:id/results', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await query(`
      SELECT tr.*, u.login, u.first_name, u.last_name, u.rating, u.rps_points, u.rps_rank
      FROM tournament_results tr
      JOIN users u ON u.id = tr.user_id
      WHERE tr.tournament_id = $1
      ORDER BY tr.position ASC
    `, [id]);

    res.json(result.rows.map(row => ({
      id: row.id,
      userId: row.user_id,
      userName: `${row.first_name || ''} ${row.last_name || ''} ${row.login}`.trim(),
      position: row.position,
      ratingEarned: Number(row.rating_earned),
      rpsEarned: Number(row.rps_earned),
      currentRating: Number(row.rating),
      currentRpsPoints: Number(row.rps_points),
      currentRank: row.rps_rank,
    })));
  } catch (error) {
    console.error('Error fetching tournament results:', error);
    res.status(500).json({ message: 'Failed to fetch tournament results' });
  }
});

// POST /api/v1/tournaments/:id/distribute - Распределить рейтинг и RPS
router.post('/tournaments/:id/distribute', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { results } = req.body || {};

    if (!results || !Array.isArray(results) || results.length === 0) {
      return res.status(400).json({ message: 'Results array is required' });
    }

    // Получаем настройки RPS
    const settingsResult = await query(`SELECT * FROM rps_settings ORDER BY updated_at DESC LIMIT 1`);
    const settings = settingsResult.rows[0] || { rating_per_rps: 10 };
    const ratingPerRps = Number(settings.rating_per_rps) || 10;

    // Транзакция для обновления результатов
    await query('BEGIN');

    const distributed = [];
    const hasWinner = results.some((item) => Number(item.position) === 1);

    for (const item of results) {
      const { userId, position, ratingEarned } = item;
      
      if (!userId || !position || ratingEarned === undefined) continue;

      // RPS = рейтинг / 10 (за каждые 10 очков рейтинга = 1 RPS)
      const rpsEarned = Math.floor(ratingEarned / ratingPerRps);

      // Обновляем рейтинг и RPS пользователя
      await query(`
        UPDATE users 
        SET rating = rating + $1, rps_points = rps_points + $2
        WHERE id = $3
      `, [ratingEarned, rpsEarned, userId]);

      // Определяем новый ранг на основе rps_points
      const userResult = await query(`SELECT rps_points FROM users WHERE id = $1`, [userId]);
      const currentRpsPoints = Number(userResult.rows[0]?.rps_points) || 0;
      const newRank = getRankFromPoints(currentRpsPoints);

      // Обновляем ранг
      await query(`
        UPDATE users SET rps_rank = $1 WHERE id = $2
      `, [newRank.code, userId]);

      // Записываем в историю изменений рейтинга
      await query(`
        INSERT INTO rating_history (user_id, delta, reason)
        VALUES ($1, $2, $3)
      `, [userId, ratingEarned, `Турнир: позиция #${position}, +${rpsEarned} RPS (ранг: ${newRank.rank})`]);

      // Сохраняем результат турнира
      await query(`
        INSERT INTO tournament_results (tournament_id, user_id, position, rating_earned, rps_earned)
        VALUES ($1, $2, $3, $4, $5)
        ON CONFLICT (tournament_id, user_id) DO UPDATE
        SET position = $3, rating_earned = $4, rps_earned = $5
      `, [id, userId, position, ratingEarned, rpsEarned]);

      distributed.push({ 
        userId, 
        position, 
        ratingEarned, 
        rpsEarned,
        newRank: newRank.rank,
        newCode: newRank.code,
      });
    }

    if (hasWinner) {
      await query(`
        UPDATE tournaments
        SET status = 'completed'
        WHERE id = $1
      `, [id]);
    }

    await query('COMMIT');

    res.json({
      success: true,
      message: `Рейтинг и RPS распределён ${distributed.length} игрокам`,
      distributed,
    });
  } catch (error) {
    try { await query('ROLLBACK'); } catch (_) {}
    console.error('Error distributing tournament results:', error);
    res.status(500).json({ message: 'Failed to distribute results', error: error.message });
  }
});

// DELETE /api/v1/tournaments/:id/results - Очистить результаты турнира
router.delete('/tournaments/:id/results', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    
    await query(`DELETE FROM tournament_results WHERE tournament_id = $1`, [id]);
    
    res.json({ success: true, message: 'Результаты удалены' });
  } catch (error) {
    console.error('Error deleting tournament results:', error);
    res.status(500).json({ message: 'Failed to delete results' });
  }
});

// ===== Admin: Edit RPS =====

// PATCH /api/v1/rps/players/:id - Изменить RPS игрока
router.patch('/players/:id', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { rps_points, reason } = req.body || {};
    
    const newRpsPoints = parseInt(rps_points) || 0;
    
    // Проверяем существование игрока
    const userRes = await query('SELECT rps_points, rps_rank FROM users WHERE id = $1', [id]);
    if (userRes.rows.length === 0) {
      return res.status(404).json({ message: 'Игрок не найден' });
    }
    
    const prevRps = Number(userRes.rows[0].rps_points) || 0;
    const prevRank = userRes.rows[0].rps_rank || 'FISH';
    
    // Определяем новый ранг
    const newRank = getRankFromPoints(newRpsPoints);
    
    // Обновляем RPS и ранг
    await query('UPDATE users SET rps_points = $1, rps_rank = $2 WHERE id = $3', 
      [newRpsPoints, newRank.code, id]);
    
    // Записываем в историю
    await query(
      'INSERT INTO rating_history (user_id, delta, reason) VALUES ($1, $2, $3)',
      [id, newRpsPoints - prevRps, `Ручное изменение RPS: ${prevRps} → ${newRpsPoints} (${prevRank} → ${newRank.rank})${reason ? ': ' + reason : ''}`]
    );
    
    res.json({
      success: true,
      prevRps: prevRps,
      newRps: newRpsPoints,
      prevRank: prevRank,
      newRank: newRank.rank,
      newCode: newRank.code,
    });
  } catch (error) {
    console.error('Error updating player RPS:', error);
    res.status(500).json({ message: 'Failed to update RPS', error: error.message });
  }
});

// ===== Season Reset =====

// POST /api/v1/rps/season-reset - Сброс RPS в конце сезона
router.post('/season-reset', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { reason } = req.body || {};
    
    // Получаем всех игроков
    const usersRes = await query('SELECT id, rps_points, rps_rank FROM users');
    
    const results = [];
    
    for (const user of usersRes.rows) {
      const prevRps = Number(user.rps_points) || 0;
      const prevRank = user.rps_rank || 'FISH';
      
      // Определяем текущий ранг и его базовое значение
      const currentRank = getRankFromPoints(prevRps);
      const baseScore = currentRank.baseScore;
      
      // Устанавливаем RPS на базовое значение ранга
      const newRps = baseScore;
      
      if (newRps !== prevRps) {
        await query('UPDATE users SET rps_points = $1 WHERE id = $2', [newRps, user.id]);
        
        await query(
          'INSERT INTO rating_history (user_id, delta, reason) VALUES ($1, $2, $3)',
          [user.id, newRps - prevRps, `Сезонный сброс: ${prevRps} → ${newRps} (${prevRank} → ${currentRank.rank})${reason ? ': ' + reason : ''}`]
        );
        
        results.push({
          userId: user.id,
          prevRps,
          newRps,
          prevRank,
          newRank: currentRank.rank,
        });
      }
    }
    
    res.json({
      success: true,
      message: `RPS сброшено для ${results.length} игроков`,
      results,
    });
  } catch (error) {
    console.error('Error during season reset:', error);
    res.status(500).json({ message: 'Failed to reset RPS', error: error.message });
  }
});

module.exports = router;
