const express = require('express');
const { query } = require('../config/database');
const { hashPassword, comparePassword, signToken } = require('../utils/auth');
const jwt = require('jsonwebtoken');

const router = express.Router();

function normalizeLoginBase(name, email) {
  const source = (name || email || 'player').trim();
  const cleaned = source
    .toLowerCase()
    .replace(/[^a-z0-9._-]+/g, '_')
    .replace(/^_+|_+$/g, '')
    .slice(0, 32);

  if (cleaned && cleaned !== '_') return cleaned;

  const emailBase = (email || 'player').split('@')[0].trim().toLowerCase();
  return (emailBase || 'player').replace(/[^a-z0-9._-]+/g, '_').slice(0, 32) || 'player';
}

async function buildUniqueLogin(name, email) {
  let login = normalizeLoginBase(name, email);
  let candidate = login;
  let counter = 2;

  while (true) {
    const existing = await query(
      `SELECT id FROM users WHERE login = $1 LIMIT 1`,
      [candidate]
    );

    if (existing.rows.length === 0) {
      return candidate;
    }

    candidate = `${login}_${counter}`;
    counter += 1;
  }
}

router.post('/login', async (req, res) => {
  try {
    const { login, password } = req.body || {};

    if (!login || !password) {
      return res.status(400).json({ message: 'login and password are required' });
    }

    const userResult = await query(
      `SELECT * FROM users WHERE login = $1 OR email = $1 LIMIT 1`,
      [login]
    );

    const user = userResult.rows[0];
    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const isValid = await comparePassword(password, user.password_hash);
    if (!isValid) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const accessToken = signToken({ sub: user.id, role: user.role });
    const refreshToken = signToken({ sub: user.id, type: 'refresh' });

    await query(
      `UPDATE users SET last_login_at = NOW() WHERE id = $1`,
      [user.id]
    );

    res.json({
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        login: user.login,
        email: user.email,
        role: user.role,
        firstName: user.first_name,
        lastName: user.last_name,
        avatarUrl: user.avatar_url,
        isActive: user.is_active,
        createdAt: user.created_at,
        lastLoginAt: user.last_login_at,
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Auth failed' });
  }
});

router.post('/register', async (req, res) => {
  try {
    const { name, email, password } = req.body || {};

    if (!name || !email || !password) {
      return res.status(400).json({ message: 'name, email and password are required' });
    }

    const normalizedName = String(name).trim();
    const normalizedEmail = String(email).trim().toLowerCase();
    const existing = await query(
      `SELECT id, login, email FROM users WHERE lower(email) = lower($1) OR lower(login) = lower($2) LIMIT 1`,
      [normalizedEmail, normalizeLoginBase(normalizedName, normalizedEmail)]
    );

    if (existing.rows.length > 0) {
      const existingUser = existing.rows[0];
      const sameEmail = existingUser.email && existingUser.email.toLowerCase() === normalizedEmail;
      const sameLogin = existingUser.login && existingUser.login.toLowerCase() === normalizeLoginBase(normalizedName, normalizedEmail).toLowerCase();

      const friendlyMessage = sameEmail && sameLogin
        ? 'Аккаунт с таким email и логином уже зарегистрирован. Попробуйте другой email или имя.'
        : sameEmail
          ? 'Пользователь с таким email уже зарегистрирован. Войдите в аккаунт или используйте другой email.'
          : sameLogin
            ? 'Такое имя уже занято. Пожалуйста, выберите другое имя пользователя.'
            : 'Аккаунт с такими данными уже существует. Попробуйте другой email или имя.';

      return res.status(409).json({
        message: friendlyMessage,
        conflict: sameEmail ? 'email' : sameLogin ? 'login' : 'account',
      });
    }

    const passwordHash = await hashPassword(password);
    const login = await buildUniqueLogin(normalizedName, normalizedEmail);
    const result = await query(
      `INSERT INTO users (login, email, password_hash, first_name, role)
       VALUES ($1, $2, $3, $4, 'player') RETURNING *`,
      [login, normalizedEmail, passwordHash, normalizedName]
    );

    const user = result.rows[0];
    const accessToken = signToken({ sub: user.id, role: user.role });
    const refreshToken = signToken({ sub: user.id, type: 'refresh' });

    res.status(201).json({
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        login: user.login,
        email: user.email,
        role: user.role,
        firstName: user.first_name,
        lastName: user.last_name,
        avatarUrl: user.avatar_url,
        isActive: user.is_active,
        createdAt: user.created_at,
        lastLoginAt: user.last_login_at,
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Register failed' });
  }
});

router.post('/refresh', async (req, res) => {
  try {
    const { refreshToken } = req.body || {};
    if (!refreshToken) {
      return res.status(400).json({ message: 'refreshToken required' });
    }

    const payload = jwt.verify(refreshToken, process.env.JWT_SECRET || 'dev_secret_key');
    const userResult = await query(`SELECT * FROM users WHERE id = $1 LIMIT 1`, [payload.sub]);
    const user = userResult.rows[0];

    if (!user) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    const accessToken = signToken({ sub: user.id, role: user.role });
    const nextRefreshToken = signToken({ sub: user.id, type: 'refresh' });

    res.json({
      accessToken,
      refreshToken: nextRefreshToken,
      user: {
        id: user.id,
        login: user.login,
        email: user.email,
        role: user.role,
        firstName: user.first_name,
        lastName: user.last_name,
        avatarUrl: user.avatar_url,
        isActive: user.is_active,
        createdAt: user.created_at,
        lastLoginAt: user.last_login_at,
      },
    });
  } catch (error) {
    res.status(401).json({ message: 'Invalid refresh token' });
  }
});

router.post('/logout', (req, res) => {
  res.json({ ok: true });
});

module.exports = router;
