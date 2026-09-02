const express = require('express');
const { query } = require('../config/database');
const { requireAuth } = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const { tournament_id } = req.query;
    console.log('[TABLES] Query params:', req.query);

    let tablesQuery = 'SELECT * FROM tables';
    let tablesParams = [];

    if (tournament_id) {
      tablesQuery += ' WHERE tournament_id = $1';
      tablesParams.push(tournament_id);
    }

    tablesQuery += ' ORDER BY created_at ASC';

    const tablesResult = await query(tablesQuery, tablesParams);
    const tables = tablesResult.rows;
    console.log('[TABLES] Found tables:', tables.length);

    // ID текущего пользователя (если авторизован)
    let currentUserId = null;
    try {
      const header = req.headers.authorization || req.headers.Authorization;
      if (header) {
        const parts = header.split(' ');
        if (parts.length === 2 && parts[0] === 'Bearer') {
          const { verifyToken } = require('../utils/auth');
          const payload = verifyToken(parts[1]);
          currentUserId = payload.sub;
        }
      }
    } catch (e) {
      // Не авторизован или неверный токен - currentUserId остается null
    }

    const result = [];
    for (const table of tables) {
      let seatsQuery = `
        SELECT ts.*, u.id AS user_id, u.login, u.first_name, u.last_name, u.rps_rank, u.rating
        FROM table_seats ts
        LEFT JOIN users u ON u.id = ts.user_id
        WHERE ts.table_id = $1
        ORDER BY ts.seat_number ASC
      `;
      const seatsResult = await query(seatsQuery, [table.id]);
      console.log('[TABLES] Table', table.id, 'has', seatsResult.rows.length, 'seats');

      result.push({
        id: table.id,
        name: table.name,
        capacity: table.capacity,
        tournamentId: table.tournament_id,
        seats: seatsResult.rows.map((seat) => {
          const isOccupied = !!seat.user_id;
          const isBookedByMe = isOccupied && currentUserId && seat.user_id === currentUserId;
          
          return {
            number: seat.seat_number,
            status: isBookedByMe ? 'booked' : (isOccupied ? 'occupied' : 'free'),
            player: isOccupied
              ? {
                  id: seat.user_id,
                  name: `${seat.first_name || seat.login || 'Player'}`,
                  rpsRank: seat.rps_rank || 'FISH',
                  skillScore: Number(seat.rating) || 0,
                  isCurrentUser: isBookedByMe,
                }
              : null,
            isBookedByMe,
          };
        }),
      });
    }

    res.json(result);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch tables' });
  }
});

router.post('/', requireAuth, async (req, res) => {
  try {
    const { name, capacity, tournament_id } = req.body || {};
    
    // Максимум 10 мест на столе
    const maxCapacity = 10;
    const tableCapacity = Math.min(capacity || 10, maxCapacity);
    
    const tableResult = await query(
      `INSERT INTO tables (name, capacity, tournament_id)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [name, tableCapacity, tournament_id || null]
    );

    const table = tableResult.rows[0];
    
    // Создаём места для стола
    for (let i = 1; i <= tableCapacity; i++) {
      await query(
        `INSERT INTO table_seats (table_id, seat_number)
         VALUES ($1, $2)
         ON CONFLICT (table_id, seat_number) DO NOTHING`,
        [table.id, i]
      );
    }

    res.status(201).json({ 
      id: table.id, 
      name: table.name, 
      capacity: table.capacity,
      tournamentId: table.tournament_id,
      seats: [] 
    });
  } catch (error) {
    console.error('Error creating table:', error);
    res.status(500).json({ message: 'Failed to create table' });
  }
});

// ===== Массовое сохранение рассадки (ДО параметризованных маршрутов!) =====
router.post('/:tableId/seats/save-all', requireAuth, async (req, res) => {
  try {
    const { tableId } = req.params;
    const { seats } = req.body || {};

    console.log('[TABLES] save-all called for table:', tableId, 'seats:', seats.length);

    // Проверяем, что пользователь админ
    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Доступ запрещён' });
    }

    if (!Array.isArray(seats) || seats.length === 0) {
      return res.status(400).json({ message: 'Не переданы места' });
    }

    // Обновляем каждое место
    for (const seat of seats) {
      console.log('[TABLES] Updating seat', seat.number, 'to user:', seat.userId);
      await query(
        `UPDATE table_seats 
         SET user_id = $1 
         WHERE table_id = $2 AND seat_number = $3`,
        [seat.userId || null, tableId, seat.number]
      );
    }

    console.log('[TABLES] save-all completed successfully');
    res.json({ 
      success: true, 
      message: 'Рассадка сохранена',
      tableId,
      seatsCount: seats.length 
    });
  } catch (error) {
    console.error('[TABLES] Error saving all seats:', error);
    res.status(500).json({ message: 'Ошибка при сохранении рассадки' });
  }
});

// ===== Админ посадка/освобождение игрока (ДО параметризованных маршрутов!) =====
router.patch('/:tableId/seats/:seatNumber', requireAuth, async (req, res) => {
  try {
    const { tableId, seatNumber } = req.params;
    const { user_id } = req.body || {};

    console.log('[TABLES] PATCH seat:', { tableId, seatNumber, user_id });

    // Проверяем, что пользователь админ
    if (req.user.role !== 'admin') {
      console.log('[TABLES] PATCH failed: not admin, role:', req.user.role);
      return res.status(403).json({ message: 'Доступ запрещён' });
    }

    // Проверяем, существует ли место
    const seatCheck = await query(
      `SELECT ts.*, u.id AS user_id
       FROM table_seats ts
       LEFT JOIN users u ON u.id = ts.user_id
       WHERE ts.table_id = $1 AND ts.seat_number = $2`,
      [tableId, seatNumber]
    );

    if (!seatCheck.rows[0]) {
      console.log('[TABLES] PATCH failed: seat not found');
      return res.status(404).json({ message: 'Место не найдено' });
    }

    // Обновляем место: либо сажаем игрока, либо освобождаем
    if (user_id) {
      await query(
        `UPDATE table_seats 
         SET user_id = $1 
         WHERE table_id = $2 AND seat_number = $3`,
        [user_id, tableId, seatNumber]
      );
      console.log('[TABLES] PATCH: player', user_id, 'assigned to seat', seatNumber);
    } else {
      await query(
        `UPDATE table_seats 
         SET user_id = NULL 
         WHERE table_id = $1 AND seat_number = $2`,
        [tableId, seatNumber]
      );
      console.log('[TABLES] PATCH: seat', seatNumber, 'cleared');
    }

    res.json({ 
      success: true, 
      message: user_id ? 'Игрок посажен' : 'Место освобождено',
      tableId,
      seatNumber,
      userId: user_id 
    });
  } catch (error) {
    console.error('[TABLES] PATCH error:', error);
    res.status(500).json({ message: 'Ошибка при работе с местом' });
  }
});

// POST /api/v1/tables/:tableId/seats/:seatNumber/book
// Бронирование места игроком
router.post('/:tableId/seats/:seatNumber/book', requireAuth, async (req, res) => {
  try {
    const { tableId, seatNumber } = req.params;
    const userId = req.user.sub;

    // Проверяем, свободно ли место
    const seatCheck = await query(
      `SELECT ts.*, u.id AS user_id
       FROM table_seats ts
       LEFT JOIN users u ON u.id = ts.user_id
       WHERE ts.table_id = $1 AND ts.seat_number = $2`,
      [tableId, seatNumber]
    );

    if (!seatCheck.rows[0]) {
      return res.status(404).json({ message: 'Место не найдено' });
    }

    if (seatCheck.rows[0].user_id) {
      return res.status(400).json({ message: 'Место уже занято' });
    }

    // Бронируем место
    await query(
      `UPDATE table_seats 
       SET user_id = $1 
       WHERE table_id = $2 AND seat_number = $3`,
      [userId, tableId, seatNumber]
    );

    res.json({ 
      success: true, 
      message: 'Место забронировано',
      tableId,
      seatNumber,
      userId 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Ошибка бронирования' });
  }
});

// POST /api/v1/tables/:tableId/seats/:seatNumber/cancel
// Отмена бронирования игроком
router.post('/:tableId/seats/:seatNumber/cancel', requireAuth, async (req, res) => {
  try {
    const { tableId, seatNumber } = req.params;
    const userId = req.user.sub;

    // Проверяем, что место забронировано текущим пользователем
    const seatCheck = await query(
      `SELECT ts.* FROM table_seats ts 
       WHERE ts.table_id = $1 AND ts.seat_number = $2 AND ts.user_id = $3`,
      [tableId, seatNumber, userId]
    );

    if (!seatCheck.rows[0]) {
      return res.status(404).json({ message: 'Бронирование не найдено' });
    }

    // Отменяем бронирование
    await query(
      `UPDATE table_seats 
       SET user_id = NULL 
       WHERE table_id = $1 AND seat_number = $2`,
      [tableId, seatNumber]
    );

    res.json({ 
      success: true, 
      message: 'Бронирование отменено',
      tableId,
      seatNumber,
      userId 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Ошибка отмены бронирования' });
  }
});

// DELETE /api/v1/tables/:tableId - Удаление стола (только админ)
router.delete('/:tableId', requireAuth, async (req, res) => {
  try {
    const { tableId } = req.params;
    
    // Проверяем, что пользователь админ
    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Доступ запрещён' });
    }

    // Удаляем стол (места удалятся автоматически из-за ON DELETE CASCADE)
    await query('DELETE FROM tables WHERE id = $1', [tableId]);

    res.json({ 
      success: true, 
      message: 'Стол удалён',
      tableId 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Ошибка удаления стола' });
  }
});

module.exports = router;
