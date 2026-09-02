const { pool } = require('../src/config/database');

async function check() {
  const client = await pool.connect();
  try {
    const res = await client.query('SELECT id, login, email, password_hash, role FROM users');
    console.log('USERS:', res.rows);
  } catch (e) {
    console.error('ERROR', e.message);
  } finally {
    client.release();
    await pool.end();
  }
}

check();
