const express = require('express');
const cors = require('cors');
const os = require('os');
const path = require('path');
const { query } = require('./config/database');
const { init } = require('./db/init');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 4000;
const HOST = process.env.HOST || '0.0.0.0';

const getLocalNetworkIp = () => {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name] || []) {
      if (iface.family === 'IPv4' && !iface.internal) {
        return iface.address;
      }
    }
  }
  return '127.0.0.1';
};

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const tournamentRoutes = require('./routes/tournamentRoutes');
const tableRoutes = require('./routes/tableRoutes');
const playerRoutes = require('./routes/playerRoutes');
const adminRoutes = require('./routes/adminRoutes');
const achievementsRoutes = require('./routes/achievementsRoutes');
const postsRoutes = require('./routes/postsRoutes');
const clockRoutes = require('./routes/clockRoutes');
const adminTransactionRoutes = require('./routes/adminTransactionRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const bonusRoutes = require('./routes/bonusRoutes');
const loyaltyRoutes = require('./routes/loyaltyRoutes');
const faqRoutes = require('./routes/faqRoutes');
const rpsRoutes = require('./routes/rpsRoutes');
const { startTournamentLifecycleScheduler } = require('./services/tournamentLifecycleService');

app.get('/health', (req, res) => {
  res.json({ ok: true, service: 'poker-club-backend' });
});

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/tournaments', tournamentRoutes);
app.use('/api/v1/tables', tableRoutes);
app.use('/api/v1/players', playerRoutes);
app.use('/api/v1/admin', adminRoutes);
app.use('/api/v1/admin/transactions', adminTransactionRoutes);
app.use('/api/v1/achievements', achievementsRoutes);
app.use('/api/v1/posts', postsRoutes);
app.use('/api/v1/clock', clockRoutes);
app.use('/api/v1/notifications', notificationRoutes);
app.use('/api/v1/bonuses', bonusRoutes);
app.use('/api/v1/loyalty', loyaltyRoutes);
app.use('/api/v1/faq', faqRoutes);
app.use('/api/v1/rps', rpsRoutes);

app.use((err, req, res, next) => {
  console.error(err && err.stack ? err.stack : err);
  res.status(500).json({ message: 'Internal server error' });
});

async function start() {
  try {
    await init();
    await query('SELECT 1');
    startTournamentLifecycleScheduler();
    app.listen(PORT, HOST, () => {
      const lanIp = getLocalNetworkIp();
      console.log(`Backend running on http://0.0.0.0:${PORT}`);
      console.log(`Local access: http://localhost:${PORT}`);
      console.log(`Network access: http://${lanIp}:${PORT}`);
      console.log('Android emulator should use http://10.0.2.2:4000/api/v1');
    });
  } catch (error) {
    console.error('Postgres connection failed. Start PostgreSQL and rerun.');
    console.error(error.message);
    process.exit(1);
  }
}

start();

module.exports = app;
