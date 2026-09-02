const { query } = require('../config/database');

async function fixTables() {
  try {
    // Добавляем tournament_id если не существует
    await query('ALTER TABLE tables ADD COLUMN IF NOT EXISTS tournament_id UUID REFERENCES tournaments(id) ON DELETE CASCADE');
    console.log('✓ Added tournament_id column');
    
    // Проверяем структуру
    const columns = await query("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'tables' ORDER BY ordinal_position");
    console.log('Tables structure:');
    columns.rows.forEach(col => console.log(`  - ${col.column_name}: ${col.data_type}`));
    
    // Проверяем table_seats
    const seatsColumns = await query("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'table_seats' ORDER BY ordinal_position");
    console.log('\nTable seats structure:');
    seatsColumns.rows.forEach(col => console.log(`  - ${col.column_name}: ${col.data_type}`));
    
    console.log('\n✓ Database structure fixed');
  } catch (error) {
    console.error('✗ Error:', error.message);
  } finally {
    process.exit(0);
  }
}

fixTables();
