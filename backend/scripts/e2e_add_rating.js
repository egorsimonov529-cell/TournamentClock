const fetch = global.fetch || require('node-fetch');

async function run() {
  const base = 'http://localhost:4000/api/v1';
  const loginRes = await fetch(`${base}/auth/login`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ login: 'admin', password: 'admin123' }),
  });
  const login = await loginRes.json();
  console.log('LOGGED_IN', login.user.login, login.user.id);
  const token = login.accessToken;

  const playersRes = await fetch(`${base}/players`, { headers: { Authorization: `Bearer ${token}` } });
  const playersText = await playersRes.text();
  console.log('PLAYERS_STATUS', playersRes.status);
  console.log('PLAYERS_BODY', playersText);
  const players = JSON.parse(playersText || '[]');
  console.log('PLAYERS_COUNT', players.length);
  const target = players.find(p => p.login !== 'admin') || players[0];
  console.log('TARGET', target.login, target.id, target.rating);

  const add = await fetch(`${base}/players/${target.id}/rating`, {
    method: 'POST', headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
    body: JSON.stringify({ delta: 50, reason: 'E2E test' }),
  });
  console.log('ADD_STATUS', add.status);
  const addBody = await add.json();
  console.log('ADD_BODY', addBody);

  const profileRes = await fetch(`${base}/players/${target.id}`);
  const profile = await profileRes.json();
  console.log('PROFILE_RATING', profile.user.rating);
}

run().catch(e => { console.error(e && e.stack ? e.stack : e); process.exit(1); });
