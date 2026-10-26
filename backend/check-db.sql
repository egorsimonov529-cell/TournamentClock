-- Check registration status for user trying to book seat
SELECT 
    tp.user_id,
    u.login,
    u.nickname,
    t.name as tournament_name,
    tp.registration_status,
    tp.registered_at,
    CASE 
        WHEN tp.registration_status IN ('pending', 'confirmed') THEN '✅ CAN BOOK'
        ELSE '❌ CANNOT BOOK (' || tp.registration_status || ')'
    END as booking_eligible
FROM tournament_players tp 
JOIN users u ON u.id = tp.user_id 
JOIN tournaments t ON t.id = tp.tournament_id 
WHERE tp.user_id = '0e66f75d-94b6-4fd2-86b3-b4ea2b4812f2'
ORDER BY tp.registered_at DESC;

-- Check if user has any seat assigned
SELECT 
    ts.user_id,
    ts.table_id,
    t.name as table_name,
    ts.seat_number,
    CASE WHEN ts.user_id IS NOT NULL THEN '🔴 OCCUPIED' ELSE '🟢 FREE' END as status
FROM table_seats ts
JOIN tables t ON t.id = ts.table_id
WHERE ts.user_id = '0e66f75d-94b6-4fd2-86b3-b4ea2b4812f2';

-- Check seat #2 on table 48008f96-7c51-4afe-a124-4d926e2e8a82
SELECT 
    ts.seat_number,
    ts.user_id,
    u.login,
    CASE WHEN ts.user_id IS NOT NULL THEN '🔴 OCCUPIED' ELSE '🟢 FREE' END as status
FROM table_seats ts
LEFT JOIN users u ON u.id = ts.user_id
WHERE ts.table_id = '48008f96-7c51-4afe-a124-4d926e2e8a82' AND ts.seat_number = 2;

-- Check all tables for this tournament
SELECT 
    id,
    name,
    tournament_id,
    (SELECT COUNT(*) FROM table_seats WHERE table_id = tables.id AND user_id IS NOT NULL) as occupied_seats,
    (SELECT COUNT(*) FROM table_seats WHERE table_id = tables.id) as total_seats
FROM tables
WHERE tournament_id = '1867de91-0487-48bf-841c-7bf009032282';
