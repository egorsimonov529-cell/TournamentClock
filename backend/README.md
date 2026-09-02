# Poker Club Backend

## Setup

1. Install PostgreSQL and create a database named `poker_club`.
2. Copy `.env.example` to `.env` and fill in credentials.
3. Install dependencies:

```bash
npm install
```

4. Initialize database:

```bash
npm run db:init
```

5. Start server:

```bash
npm run dev
```

## Base endpoints

- GET /health
- POST /api/v1/auth/login
- POST /api/v1/auth/register
- POST /api/v1/auth/refresh
- POST /api/v1/auth/logout
- GET /api/v1/users/me
- GET /api/v1/users/profile
- POST /api/v1/users/profile
- GET /api/v1/tournaments
- POST /api/v1/tournaments
- POST /api/v1/tournaments/:id
- POST /api/v1/tournaments/:id/players
- GET /api/v1/tables
- GET /api/v1/admin/workspace
- GET /api/v1/admin/ranks
- GET /api/v1/admin/players
