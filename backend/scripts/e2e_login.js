const fetch = global.fetch || require('node-fetch');

async function run() {
  const res = await fetch('http://localhost:4000/api/v1/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ login: 'admin', password: 'admin123' }),
  });
  const text = await res.text();
  console.log('STATUS', res.status);
  console.log('BODY', text);
}

run().catch((e) => { console.error('ERR', e && e.stack ? e.stack : e); process.exit(1); });
