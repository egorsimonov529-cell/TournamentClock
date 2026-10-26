const { query } = require('./src/config/database');

async function checkRegistration() {
  try {
    const userId = '0e66f75d-94b6-4fd2-86b3-b4ea2b4812f2';
    const tournamentId = '1867de91-0487-48bf-841c-7bf009032282';
    const tableId = '48008f96-7c51-4afe-a124-4d926e2e8a82';

    console.log('=== CHECKING REGISTRATION STATUS ===\n');

    // Check user
    const userResult = await query(
      'SELECT id, login, nickname FROM users WHERE id = $1',
      [userId]
    );
    console.log('User:', userResult.rows[0] || 'NOT FOUND');

    // Check tournament
    const tournamentResult = await query(
      'SELECT id, name FROM tournaments WHERE id = $1',
      [tournamentId]
    );
    console.log('Tournament:', tournamentResult.rows[0] || 'NOT FOUND');

    // Check registration
    const registrationResult = await query(
      `SELECT tp.user_id, u.login, u.nickname, t.name, tp.registration_status, tp.registered_at 
       FROM tournament_players tp 
       JOIN users u ON u.id = tp.user_id 
       JOIN tournaments t ON t.id = tp.tournament_id 
       WHERE tp.user_id = $1`,
      [userId]
    );
    console.log('\nAll registrations for user:');
    if (registrationResult.rows.length === 0) {
      console.log('  NO REGISTRATIONS FOUND!');
    } else {
      for (const row of registrationResult.rows) {
        console.log(`  Tournament: ${row.name}`);
        console.log(`    Status: ${row.registration_status}`);
        console.log(`    Registered: ${row.registered_at}`);
      }
    }

    // Check specific tournament registration
    const specificReg = await query(
      `SELECT registration_status FROM tournament_players 
       WHERE tournament_id = $1 AND user_id = $2`,
      [tournamentId, userId]
    );
    console.log('\nRegistration for tournament', tournamentId);
    if (specificReg.rows.length === 0) {
      console.log('  NOT REGISTERED!');
    } else {
      console.log('  Status:', specificReg.rows[0].registration_status);
    }

    // Check table
    const tableResult = await query(
      'SELECT id, name, tournament_id FROM tables WHERE id = $1',
      [tableId]
    );
    console.log('\nTable:', tableResult.rows[0] || 'NOT FOUND');

    // Check all tables for this tournament
    const tablesResult = await query(
      'SELECT id, name, tournament_id FROM tables WHERE tournament_id = $1',
      [tournamentId]
    );
    console.log('\nAll tables for tournament', tournamentId);
    if (tablesResult.rows.length === 0) {
      console.log('  NO TABLES FOUND!');
    } else {
      for (const table of tablesResult.rows) {
        console.log(`  Table: ${table.name} (ID: ${table.id})`);
      }
    }

    // Check table seats
    const seatsResult = await query(
      `SELECT ts.seat_number, ts.user_id, u.login 
       FROM table_seats ts 
       LEFT JOIN users u ON u.id = ts.user_id 
       WHERE ts.table_id = $1`,
      [tableId]
    );
    console.log('\nSeats for table', tableId);
    if (seatsResult.rows.length === 0) {
      console.log('  NO SEATS FOUND!');
    } else {
      for (const seat of seatsResult.rows) {
        console.log(`  Seat ${seat.seat_number}: ${seat.user_id || 'FREE'} (${seat.login || 'empty'})`);
      }
    }

    // Check if user has any seat
    const userSeat = await query(
      `SELECT ts.table_id, ts.seat_number, t.name as table_name 
       FROM table_seats ts 
       JOIN tables t ON t.id = ts.table_id 
       WHERE ts.user_id = $1`,
      [userId]
    );
    console.log('\nCurrent seat for user:');
    if (userSeat.rows.length === 0) {
      console.log('  NO SEAT ASSIGNED');
    } else {
      for (const seat of userSeat.rows) {
        console.log(`  Table: ${seat.table_name}, Table ID: ${seat.table_id}, Seat: ${seat.seat_number}`);
      }
    }

  } catch (error) {
    console.error('ERROR:', error);
  } finally {
    process.exit(0);
  }
}

checkRegistration();
