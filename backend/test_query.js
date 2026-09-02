const { pool } = require('./src/config/database');

async function test() {
  try {
    // Test the exact query from tableRoutes.js
    const tables = await pool.query('SELECT * FROM tables LIMIT 1');
    if (tables.rows.length === 0) {
      console.log('⚠️ No tables found');
    } else {
      console.log('✅ Tables found:', tables.rows.length);
      
      const tableId = tables.rows[0].id;
      console.log('Testing query on table:', tableId);
      
      const seats = await pool.query(
        `SELECT ts.*, u.id AS user_id, u.login, u.first_name, u.last_name, u.rps_rank, u.rating
         FROM table_seats ts
         LEFT JOIN users u ON u.id = ts.user_id
         WHERE ts.table_id = $1
         ORDER BY ts.seat_number ASC`,
        [tableId]
      );
      console.log('✅ Query succeeded! Seats:', seats.rows.length);
    }
  } catch (e) {
    console.error('❌ Error:', e.message);
    console.error('Code:', e.code);
  } finally {
    await pool.end();
  }
}

test();
