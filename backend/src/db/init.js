const { pool } = require('../config/database');
const { hashPassword } = require('../utils/auth');

async function init() {
  const client = await pool.connect();

  try {
    // Ensure legacy DBs get missing columns added safely
    await client.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS rating INTEGER NOT NULL DEFAULT 0;`);
    await client.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS rps_points INTEGER NOT NULL DEFAULT 0;`);
    await client.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS rps_rank VARCHAR(50) NOT NULL DEFAULT 'FISH';`);
    await client.query(`ALTER TABLE admin_workspace ADD COLUMN IF NOT EXISTS address TEXT;`);
    await client.query(`ALTER TABLE admin_workspace ADD COLUMN IF NOT EXISTS city VARCHAR(100);`);

    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        login VARCHAR(100) UNIQUE NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        first_name VARCHAR(100),
        last_name VARCHAR(100),
        phone_number VARCHAR(30),
        rating INTEGER NOT NULL DEFAULT 0,
        role VARCHAR(50) NOT NULL DEFAULT 'player',
        avatar_url TEXT,
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        last_login_at TIMESTAMPTZ
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS tournaments (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name VARCHAR(255) NOT NULL,
        description TEXT,
        start_date TIMESTAMPTZ NOT NULL,
        end_date TIMESTAMPTZ NOT NULL,
        max_players INTEGER NOT NULL DEFAULT 100,
        buy_in NUMERIC(12,2) DEFAULT 0,
        format VARCHAR(100) DEFAULT 'TT No-Limit',
        status VARCHAR(50) DEFAULT 'upcoming',
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS tournament_players (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        tournament_id UUID NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        UNIQUE (tournament_id, user_id)
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS tables (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name VARCHAR(255) NOT NULL,
        capacity INTEGER NOT NULL DEFAULT 9,
        status VARCHAR(50) DEFAULT 'open',
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);

    // Добавляем tournament_id для поддержки привязки столов к турнирам
    await client.query(`
      ALTER TABLE tables 
      ADD COLUMN IF NOT EXISTS tournament_id UUID REFERENCES tournaments(id) ON DELETE CASCADE;
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS table_seats (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        table_id UUID NOT NULL REFERENCES tables(id) ON DELETE CASCADE,
        seat_number INTEGER NOT NULL,
        user_id UUID REFERENCES users(id) ON DELETE SET NULL,
        UNIQUE (table_id, seat_number)
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS ranks (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        code VARCHAR(50) NOT NULL UNIQUE,
        name VARCHAR(100) NOT NULL,
        minimum_points INTEGER NOT NULL DEFAULT 0,
        description TEXT,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS admin_workspace (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        club_name VARCHAR(200) NOT NULL DEFAULT 'Poker Club ERM',
        club_short_name VARCHAR(20) DEFAULT 'ERM',
        logo_asset_path TEXT DEFAULT 'assets/logos/logo_white.svg',
        currency VARCHAR(10) DEFAULT 'RUB',
        notifications_enabled BOOLEAN DEFAULT true,
        address TEXT,
        city VARCHAR(100),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS achievements (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        title VARCHAR(255) NOT NULL,
        description TEXT,
        image_url TEXT,
        current_value INTEGER NOT NULL DEFAULT 0,
        target_value INTEGER NOT NULL DEFAULT 1,
        achieved BOOLEAN NOT NULL DEFAULT false,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);

    await client.query(`
      INSERT INTO achievements (title, description, image_url, current_value, target_value, achieved)
      VALUES
        ('Первый турнир', 'Участвуй в первом турнире', 'assets/achievements/achievement_first_tournament.svg', 0, 1, false),
        ('Регулярный игрок', 'Посети 10 турниров', 'assets/achievements/achievement_regular.svg', 0, 10, false)
      ON CONFLICT DO NOTHING;
    `);

    await client.query(`
      INSERT INTO admin_workspace (
        club_name,
        club_short_name,
        logo_asset_path,
        currency,
        notifications_enabled,
        address,
        city
      )
      VALUES ('Poker Club ERM', 'ERM', 'assets/logos/logo_white.svg', 'RUB', true, NULL, NULL)
      ON CONFLICT DO NOTHING;
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS rating_history (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        delta INTEGER NOT NULL,
        reason TEXT,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS tournament_results (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        tournament_id UUID NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        position INTEGER NOT NULL,
        rating_earned INTEGER NOT NULL DEFAULT 0,
        rps_earned INTEGER NOT NULL DEFAULT 0,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        UNIQUE (tournament_id, user_id)
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS rps_settings (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        rating_per_rps INTEGER NOT NULL DEFAULT 10,
        base_rps_per_tournament INTEGER NOT NULL DEFAULT 10,
        position_multiplier JSONB NOT NULL DEFAULT '[1.5, 1.2, 1.0, 0.8, 0.5]'::jsonb,
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);

    await client.query(`
      INSERT INTO rps_settings (rating_per_rps, base_rps_per_tournament, position_multiplier)
      VALUES (10, 10, '[1.5, 1.2, 1.0, 0.8, 0.5]'::jsonb)
      ON CONFLICT DO NOTHING;
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS posts (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        author_id UUID REFERENCES users(id) ON DELETE SET NULL,
        title VARCHAR(255) NOT NULL,
        body TEXT,
        image_url TEXT,
        is_published BOOLEAN DEFAULT true,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS blind_levels (
        id SERIAL PRIMARY KEY,
        tournament_id UUID NOT NULL,
        level_number INTEGER NOT NULL,
        small_blind INTEGER NOT NULL DEFAULT 0,
        big_blind INTEGER NOT NULL DEFAULT 0,
        ante INTEGER NOT NULL DEFAULT 0,
        duration_minutes INTEGER NOT NULL DEFAULT 10,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS transactions (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE SET NULL,
        type VARCHAR(50) NOT NULL DEFAULT 'general',
        description TEXT NOT NULL,
        amount NUMERIC(12,2) NOT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS notifications (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        title VARCHAR(255) NOT NULL,
        message TEXT NOT NULL,
        is_read BOOLEAN NOT NULL DEFAULT false,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS bonuses (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        title VARCHAR(255) NOT NULL,
        description TEXT,
        type VARCHAR(50) NOT NULL DEFAULT 'general',
        value VARCHAR(100),
        conditions TEXT,
        is_active BOOLEAN NOT NULL DEFAULT true,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS loyalty_campaigns (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        title VARCHAR(255) NOT NULL,
        description TEXT,
        active BOOLEAN NOT NULL DEFAULT true,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS faq (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        question VARCHAR(500) NOT NULL,
        answer TEXT NOT NULL,
        is_active BOOLEAN NOT NULL DEFAULT true,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);

    await client.query(`
      INSERT INTO ranks (code, name, minimum_points, description)
      VALUES
        ('FISH', 'Fish', 0, 'Новичок'),
        ('BRONZE', 'Bronze', 100, 'Бронзовый уровень'),
        ('SILVER', 'Silver', 500, 'Серебряный уровень'),
        ('GOLD', 'Gold', 1200, 'Золотой уровень'),
        ('PLATINUM', 'Platinum', 2500, 'Платиновый уровень')
      ON CONFLICT (code) DO NOTHING;
    `);

    const adminPasswordHash = await hashPassword('admin123');
    const playerPasswordHash = await hashPassword('player123');

    await client.query(
      `INSERT INTO users (login, email, password_hash, first_name, last_name, role)
       VALUES ($1, $2, $3, $4, $5, $6)
       ON CONFLICT (login) DO NOTHING;`,
      ['admin', 'admin@club.local', adminPasswordHash, 'Админ', 'Клуба', 'admin']
    );

    await client.query(
      `INSERT INTO users (login, email, password_hash, first_name, last_name, role)
       VALUES ($1, $2, $3, $4, $5, $6)
       ON CONFLICT (login) DO NOTHING;`,
      ['player', 'player@club.local', playerPasswordHash, 'Игрок', 'Тестовый', 'player']
    );

    // Seed bonuses
    await client.query(`
      INSERT INTO bonuses (title, description, type, value, conditions, is_active)
      VALUES
        ('Welcome Bonus', 'Бонус за первую регистрацию', 'welcome', '500 RUB', 'Регистрация в клубе', true),
        ('Reload Bonus', 'Бонус за пополнение счета', 'reload', '10%', 'Пополнение от 1000 RUB', true),
        ('Tournament Bonus', 'Бонус за участие в турнире', 'tournament', '50 RUB', 'Регистрация в турнире', true),
        ('Birthday Bonus', 'Бонус на день рождения', 'birthday', '1000 RUB', 'Указание даты рождения', true)
      ON CONFLICT DO NOTHING;
    `);

    // Seed loyalty campaigns
    await client.query(`
      INSERT INTO loyalty_campaigns (title, description, active)
      VALUES
        ('Приветственный бонус', '500 бонусных баллов новым игрокам', true),
        ('Еженедельный кэшбэк', '5% от турнирных взносов', false),
        ('VIP программа', 'Повышенный кэшбэк для VIP игроков', true)
      ON CONFLICT DO NOTHING;
    `);

    // Seed FAQ
    await client.query(`
      INSERT INTO faq (question, answer, is_active)
      VALUES
        ('Как зарегистрироваться в клубе?', 'Нажмите кнопку регистрации и заполните форму с логином, email и паролем.', true),
        ('Как принять участие в турнире?', 'Выберите турнир из списка и нажмите кнопку регистрации.', true),
        ('Как работает программа лояльности?', 'За участие в турнирах вы получаете баллы, которые можно обменять на бонусы.', true),
        ('Как связаться с поддержкой?', 'Вы можете написать нам в Telegram или на email, указанный в разделе контакты.', true)
      ON CONFLICT DO NOTHING;
    `);

    console.log('Database initialized successfully');
  } catch (error) {
    console.error('DB init failed:', error);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

init();
