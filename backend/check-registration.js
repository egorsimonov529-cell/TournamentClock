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
    console.log('1. User:', userResult.rows[0] || 'NOT FOUND');

    // Check tournament
    const tournamentResult = await query(
      'SELECT id, name FROM tournaments WHERE id = $1',
      [tournamentId]
    );
    console.log('2. Tournament:', tournamentResult.rows[0] || 'NOT FOUND');

    // Check registration for this tournament
    const specificReg = await query(
      `SELECT registration_status, user_id, registered_at 
       FROM tournament_players 
       WHERE tournament_id = $1 AND user_id = $2`,
      [tournamentId, userId]
    );
    console.log('\n3. Registration for tournament', tournamentId);
    if (specificReg.rows.length === 0) {
      console.log('   ❌ NOT REGISTERED!');
    } else {
      console.log('   ✅ Status:', specificReg.rows[0].registration_status);
      console.log('   Registered:', specificReg.rows[0].registered_at);
    }

    // Check table
    const tableResult = await query(
      'SELECT id, name, tournament_id FROM tables WHERE id = $1',
      [tableId]
    );
    console.log('\n4. Table:', tableResult.rows[0] || 'NOT FOUND');

    // Check all tables for this tournament
    const tablesResult = await query(
      'SELECT id, name, tournament_id FROM tables WHERE tournament_id = $1',
      [tournamentId]
    );
    console.log('\n5. All tables for tournament', tournamentId);
    if (tablesResult.rows.length === 0) {
      console.log('   ❌ NO TABLES FOUND!');
    } else {
      for (const table of tablesResult.rows) {
        console.log(`   ✅ Table: ${table.name} (ID: ${table.id})`);
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
    console.log('\n6. Seats for table', tableId);
    if (seatsResult.rows.length === 0) {
      console.log('   ❌ NO SEATS FOUND!');
    } else {
      for (const seat of seatsResult.rows) {
        const status = seat.user_id ? `🔴 OCCUPIED by ${seat.login}` : '🟢 FREE';
        console.log(`   Seat ${seat.seat_number}: ${status}`);
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
    console.log('\n7. Current seat for user:');
    if (userSeat.rows.length === 0) {
      console.log('   ✅ NO SEAT ASSIGNED (good for booking)');
    } else {
      console.log('   ⚠️  USER HAS SEAT:');
      for (const seat of userSeat.rows) {
        console.log(`      Table: ${seat.table_name} (ID: ${seat.table_id}), Seat: ${seat.seat_number}`);
      }
    }

    // Check ALL registrations for this user
    const allRegs = await query(
      `SELECT tp.user_id, u.login, t.name as tournament_name, tp.registration_status, tp.registered_at 
       FROM tournament_players tp 
       JOIN users u ON u.id = tp.user_id 
       JOIN tournaments t ON t.id = tp.tournament_id 
       WHERE tp.user_id = $1
       ORDER BY tp.registered_at DESC`,
      [userId]
    );
    console.log('\n8. ALL registrations for user:');
    if (allRegs.rows.length === 0) {
      console.log('   ❌ NO REGISTRATIONS FOUND!');
    } else {
      for (const reg of allRegs.rows) {
        const statusIcon = (reg.registration_status === 'pending' || reg.registration_status === 'confirmed') ? '✅' : '⚠️';
        console.log(`   ${statusIcon} ${reg.tournament_name}: ${reg.registration_status}`);
      }
    }

    console.log('\n=== CHECK COMPLETE ===');

  } catch (error) {
    console.error('❌ ERROR:', error);
  } finally {
    process.exit(0);
  }
}

checkRegistration();
