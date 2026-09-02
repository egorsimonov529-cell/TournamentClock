const { pool } = require('./src/config/database');

async function fix() {
  try {
    // Check DB
    const db = await pool.query('SELECT current_database(), current_user');
    console.log('DB:', db.rows[0].current_database);
    console.log('User:', db.rows[0].current_user);

    // Check rps_rank
    const cols = await pool.query(
      "SELECT column_name FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'rps_rank'"
    );
    
    if (cols.rows.length === 0) {
      console.log('Adding rps_rank...');
      await pool.query(
        "ALTER TABLE users ADD COLUMN rps_rank VARCHAR(50) NOT NULL DEFAULT 'FISH'"
      );
      console.log('✅ rps_rank added');
    } else {
      console.log('✅ rps_rank exists');
    }

    // Check rps_points
    const cols2 = await pool.query(
      "SELECT column_name FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'rps_points'"
    );
    
    if (cols2.rows.length === 0) {
      console.log('Adding rps_points...');
      await pool.query(
        "ALTER TABLE users ADD COLUMN rps_points INTEGER NOT NULL DEFAULT 0"
      );
      console.log('✅ rps_points added');
    } else {
      console.log('✅ rps_points exists');
    }

    // List all users columns
    const allCols = await pool.query(
      "SELECT column_name FROM information_schema.columns WHERE table_name = 'users' ORDER BY ordinal_position"
    );
    console.log('\nAll users columns:');
    allCols.rows.forEach(c => console.log('  -', c.column_name));

  } catch (e) {
    console.error('Error:', e.message);
  } finally {
    await pool.end();
  }
}

fix();
