const { verifyToken } = require('../utils/auth');

async function requireAuth(req, res, next) {
  try {
    const header = req.headers.authorization || req.headers.Authorization;
    if (!header) return res.status(401).json({ message: 'Missing Authorization header' });

    const parts = header.split(' ');
    if (parts.length !== 2 || parts[0] !== 'Bearer') return res.status(401).json({ message: 'Invalid Authorization header' });

    const token = parts[1];
    const payload = verifyToken(token);
    req.user = payload;
    next();
  } catch (err) {
    console.error('Auth verify failed', err);
    return res.status(401).json({ message: 'Invalid token' });
  }
}

function requireAdmin(req, res, next) {
  const user = req.user;
  if (!user) return res.status(401).json({ message: 'Unauthorized' });
  if (user.role !== 'admin') return res.status(403).json({ message: 'Forbidden' });
  return next();
}

module.exports = { requireAuth, requireAdmin };
