const { query } = require('../config/database');

async function seedTables() {
  try {
    // Создаём турнир, если нет
    const tournaments = await query('SELECT id FROM tournaments LIMIT 1');
    let tournamentId;
    if (tournaments.rows.length === 0) {
      const result = await query(
        `INSERT INTO tournaments (name, description, start_date, end_date, max_players, buy_in, format, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
         RETURNING id`,
        ['Test Tournament', 'Test', new Date(), new Date(Date.now() + 86400000), 100, 2000, 'TT', 'upcoming']
      );
      tournamentId = result.rows[0].id;
    } else {
      tournamentId = tournaments.rows[0].id;
    }
    console.log('Tournament ID:', tournamentId);

    // Создаём столы и места
    const numTables = 3;
    const seatsPerTable = 9;

    for (let t = 1; t <= numTables; t++) {
      // Создаём стол
      const tableResult = await query(
        `INSERT INTO tables (name, capacity, tournament_id)
         VALUES ($1, $2, $3)
         ON CONFLICT DO NOTHING
         RETURNING id`,
        [`Стол ${t}`, seatsPerTable, tournamentId]
      );
      
      let tableId;
      if (tableResult.rows.length > 0) {
        tableId = tableResult.rows[0].id;
      } else {
        // Стол уже существует, получаем его ID
        const existing = await query('SELECT id FROM tables WHERE tournament_id = $1 AND name = $2', [`Стол ${t}`, tournamentId]);
        tableId = existing.rows[0]?.id;
      }

      if (!tableId) continue;

      // Создаём места для стола
      for (let s = 1; s <= seatsPerTable; s++) {
        await query(
          `INSERT INTO table_seats (table_id, seat_number)
           VALUES ($1, $2)
           ON CONFLICT (table_id, seat_number) DO NOTHING`,
          [tableId, s]
        );
      }
      console.log(`Created table ${t} with ${seatsPerTable} seats`);
    }

    console.log('Seeding completed successfully');
  } catch (error) {
    console.error('Seeding failed:', error);
  }
}

seedTables();
