const express = require('express');
const { query } = require('../config/database');
const { hashPassword, comparePassword, signToken } = require('../utils/auth');
const jwt = require('jsonwebtoken');

const router = express.Router();

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

    const existing = await query(
      `SELECT id FROM users WHERE email = $1 OR login = $2 LIMIT 1`,
      [email, name]
    );

    if (existing.rows.length > 0) {
      return res.status(409).json({ message: 'User already exists' });
    }

    const passwordHash = await hashPassword(password);
    const login = name.trim();
    const result = await query(
      `INSERT INTO users (login, email, password_hash, first_name, role)
       VALUES ($1, $2, $3, $4, 'player') RETURNING *`,
      [login, email, passwordHash, name]
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
