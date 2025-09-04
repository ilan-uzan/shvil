-- Seed data for Shvil development environment
-- This script creates sample data for testing and development

-- Note: This script assumes the database schema is already set up
-- Run this after applying the migrations

-- Insert sample users (these will be created via auth.users in real app)
-- For development, we'll insert directly into public.users

-- Sample User 1: Alice (Adventure Enthusiast)
INSERT INTO public.users (id, email, display_name, avatar_url, created_at, updated_at)
VALUES (
    '11111111-1111-1111-1111-111111111111',
    'alice@example.com',
    'Alice Johnson',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=alice',
    NOW() - INTERVAL '30 days',
    NOW() - INTERVAL '1 day'
) ON CONFLICT (id) DO NOTHING;

-- Sample User 2: Bob (Group Trip Organizer)
INSERT INTO public.users (id, email, display_name, avatar_url, created_at, updated_at)
VALUES (
    '22222222-2222-2222-2222-222222222222',
    'bob@example.com',
    'Bob Smith',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=bob',
    NOW() - INTERVAL '25 days',
    NOW() - INTERVAL '2 hours'
) ON CONFLICT (id) DO NOTHING;

-- Sample User 3: Carol (Safety Reporter)
INSERT INTO public.users (id, email, display_name, avatar_url, created_at, updated_at)
VALUES (
    '33333333-3333-3333-3333-333333333333',
    'carol@example.com',
    'Carol Davis',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=carol',
    NOW() - INTERVAL '20 days',
    NOW() - INTERVAL '30 minutes'
) ON CONFLICT (id) DO NOTHING;

-- Create friendship between Alice and Bob
INSERT INTO public.friends (user_id, friend_id, status, created_at)
VALUES 
    ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'accepted', NOW() - INTERVAL '15 days'),
    ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'accepted', NOW() - INTERVAL '15 days')
ON CONFLICT (user_id, friend_id) DO NOTHING;

-- Create friendship between Bob and Carol
INSERT INTO public.friends (user_id, friend_id, status, created_at)
VALUES 
    ('22222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333333', 'accepted', NOW() - INTERVAL '10 days'),
    ('33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222', 'accepted', NOW() - INTERVAL '10 days')
ON CONFLICT (user_id, friend_id) DO NOTHING;

-- Insert saved places for Alice
INSERT INTO public.saved_places (user_id, name, address, latitude, longitude, type, created_at, updated_at)
VALUES 
    ('11111111-1111-1111-1111-111111111111', 'Home', '123 Main St, San Francisco, CA', 37.7749, -122.4194, 'home', NOW() - INTERVAL '30 days', NOW() - INTERVAL '1 day'),
    ('11111111-1111-1111-1111-111111111111', 'Work', '456 Tech Ave, San Francisco, CA', 37.7849, -122.4094, 'work', NOW() - INTERVAL '25 days', NOW() - INTERVAL '2 days'),
    ('11111111-1111-1111-1111-111111111111', 'Golden Gate Park', 'Golden Gate Park, San Francisco, CA', 37.7694, -122.4862, 'favorite', NOW() - INTERVAL '20 days', NOW() - INTERVAL '3 days')
ON CONFLICT DO NOTHING;

-- Insert saved places for Bob
INSERT INTO public.saved_places (user_id, name, address, latitude, longitude, type, created_at, updated_at)
VALUES 
    ('22222222-2222-2222-2222-222222222222', 'Home', '789 Oak St, Oakland, CA', 37.8044, -122.2712, 'home', NOW() - INTERVAL '25 days', NOW() - INTERVAL '1 hour'),
    ('22222222-2222-2222-2222-222222222222', 'Office', '321 Business Blvd, Oakland, CA', 37.8144, -122.2612, 'work', NOW() - INTERVAL '20 days', NOW() - INTERVAL '4 hours')
ON CONFLICT DO NOTHING;

-- Insert friend locations (real-time location sharing)
INSERT INTO public.friend_locations (user_id, latitude, longitude, accuracy, timestamp)
VALUES 
    ('11111111-1111-1111-1111-111111111111', 37.7749, -122.4194, 5.0, NOW() - INTERVAL '5 minutes'),
    ('22222222-2222-2222-2222-222222222222', 37.8044, -122.2712, 8.0, NOW() - INTERVAL '2 minutes'),
    ('33333333-3333-3333-3333-333333333333', 37.7849, -122.4094, 12.0, NOW() - INTERVAL '1 minute')
ON CONFLICT DO NOTHING;

-- Insert friends presence
INSERT INTO public.friends_presence (user_id, is_online, last_seen, status, updated_at)
VALUES 
    ('11111111-1111-1111-1111-111111111111', true, NOW() - INTERVAL '5 minutes', 'available', NOW() - INTERVAL '5 minutes'),
    ('22222222-2222-2222-2222-222222222222', true, NOW() - INTERVAL '2 minutes', 'available', NOW() - INTERVAL '2 minutes'),
    ('33333333-3333-3333-3333-333333333333', false, NOW() - INTERVAL '1 hour', 'away', NOW() - INTERVAL '1 hour')
ON CONFLICT (user_id) DO NOTHING;

-- Insert ETA shares
INSERT INTO public.eta_shares (user_id, route_data, recipients, is_active, created_at, expires_at)
VALUES 
    ('11111111-1111-1111-1111-111111111111', 
     '{"duration": "25 minutes", "distance": "8.5 miles", "type": "driving", "isFastest": true, "isSafest": false}',
     ARRAY['bob@example.com', 'carol@example.com'],
     true,
     NOW() - INTERVAL '10 minutes',
     NOW() + INTERVAL '50 minutes'
    ),
    ('22222222-2222-2222-2222-222222222222',
     '{"duration": "15 minutes", "distance": "3.2 miles", "type": "walking", "isFastest": true, "isSafest": true}',
     ARRAY['alice@example.com'],
     true,
     NOW() - INTERVAL '5 minutes',
     NOW() + INTERVAL '55 minutes'
    )
ON CONFLICT DO NOTHING;

-- Insert ETA sessions
INSERT INTO public.eta_sessions (user_id, session_name, route_data, current_position, eta_seconds, is_active, started_at, expires_at, updated_at)
VALUES 
    ('11111111-1111-1111-1111-111111111111',
     'Commute to Work',
     '{"start": {"lat": 37.7749, "lng": -122.4194}, "end": {"lat": 37.7849, "lng": -122.4094}, "waypoints": []}',
     '{"lat": 37.7799, "lng": -122.4144, "accuracy": 5.0}',
     1200, -- 20 minutes
     true,
     NOW() - INTERVAL '10 minutes',
     NOW() + INTERVAL '50 minutes',
     NOW() - INTERVAL '2 minutes'
    )
ON CONFLICT DO NOTHING;

-- Insert group trip
INSERT INTO public.group_trips (name, description, creator_id, destination_latitude, destination_longitude, destination_name, start_time, end_time, status, created_at, updated_at)
VALUES 
    ('Weekend Adventure to Napa Valley',
     'A relaxing weekend trip to explore Napa Valley wineries and enjoy the beautiful scenery.',
     '22222222-2222-2222-2222-222222222222',
     38.2975, -122.2869, 'Napa Valley, CA',
     NOW() + INTERVAL '2 days',
     NOW() + INTERVAL '4 days',
     'planning',
     NOW() - INTERVAL '5 days',
     NOW() - INTERVAL '1 day'
    )
ON CONFLICT DO NOTHING;

-- Insert group trip participants
INSERT INTO public.group_trip_participants (trip_id, user_id, status, joined_at)
SELECT 
    gt.id,
    '11111111-1111-1111-1111-111111111111',
    'accepted',
    NOW() - INTERVAL '4 days'
FROM public.group_trips gt 
WHERE gt.name = 'Weekend Adventure to Napa Valley'
ON CONFLICT (trip_id, user_id) DO NOTHING;

-- Insert plan (for Together Mode)
INSERT INTO public.plans (title, description, creator_id, city, start_date, end_date, status, created_at, updated_at)
VALUES 
    ('Food Tour of Mission District',
     'Explore the best food spots in San Francisco''s Mission District',
     '11111111-1111-1111-1111-111111111111',
     'San Francisco',
     NOW() + INTERVAL '1 week',
     NOW() + INTERVAL '1 week 1 day',
     'voting',
     NOW() - INTERVAL '3 days',
     NOW() - INTERVAL '1 hour'
    )
ON CONFLICT DO NOTHING;

-- Insert plan participants
INSERT INTO public.plan_participants (plan_id, user_id, role, joined_at)
SELECT 
    p.id,
    '22222222-2222-2222-2222-222222222222',
    'participant',
    NOW() - INTERVAL '2 days'
FROM public.plans p 
WHERE p.title = 'Food Tour of Mission District'
ON CONFLICT (plan_id, user_id) DO NOTHING;

-- Insert plan places
INSERT INTO public.plan_places (plan_id, name, address, latitude, longitude, category, added_by, added_at)
SELECT 
    p.id,
    'La Taqueria',
    '2889 Mission St, San Francisco, CA 94110',
    37.7500, -122.4194,
    'food',
    '11111111-1111-1111-1111-111111111111',
    NOW() - INTERVAL '2 days'
FROM public.plans p 
WHERE p.title = 'Food Tour of Mission District'
UNION ALL
SELECT 
    p.id,
    'Bi-Rite Creamery',
    '3692 18th St, San Francisco, CA 94110',
    37.7611, -122.4256,
    'food',
    '22222222-2222-2222-2222-222222222222',
    NOW() - INTERVAL '1 day'
FROM public.plans p 
WHERE p.title = 'Food Tour of Mission District'
UNION ALL
SELECT 
    p.id,
    'Dolores Park',
    'Dolores St & 19th St, San Francisco, CA 94114',
    37.7596, -122.4269,
    'activity',
    '11111111-1111-1111-1111-111111111111',
    NOW() - INTERVAL '1 day'
FROM public.plans p 
WHERE p.title = 'Food Tour of Mission District'
ON CONFLICT DO NOTHING;

-- Insert plan votes
INSERT INTO public.plan_votes (plan_id, place_id, user_id, vote_type, rank_value, created_at)
SELECT 
    p.id,
    pp.id,
    '11111111-1111-1111-1111-111111111111',
    'up',
    NULL,
    NOW() - INTERVAL '1 day'
FROM public.plans p 
JOIN public.plan_places pp ON pp.plan_id = p.id
WHERE p.title = 'Food Tour of Mission District' AND pp.name = 'La Taqueria'
UNION ALL
SELECT 
    p.id,
    pp.id,
    '22222222-2222-2222-2222-222222222222',
    'up',
    NULL,
    NOW() - INTERVAL '1 day'
FROM public.plans p 
JOIN public.plan_places pp ON pp.plan_id = p.id
WHERE p.title = 'Food Tour of Mission District' AND pp.name = 'La Taqueria'
UNION ALL
SELECT 
    p.id,
    pp.id,
    '11111111-1111-1111-1111-111111111111',
    'up',
    NULL,
    NOW() - INTERVAL '1 day'
FROM public.plans p 
JOIN public.plan_places pp ON pp.plan_id = p.id
WHERE p.title = 'Food Tour of Mission District' AND pp.name = 'Bi-Rite Creamery'
UNION ALL
SELECT 
    p.id,
    pp.id,
    '22222222-2222-2222-2222-222222222222',
    'down',
    NULL,
    NOW() - INTERVAL '1 day'
FROM public.plans p 
JOIN public.plan_places pp ON pp.plan_id = p.id
WHERE p.title = 'Food Tour of Mission District' AND pp.name = 'Bi-Rite Creamery'
ON CONFLICT (plan_id, place_id, user_id) DO NOTHING;

-- Insert adventure plan
INSERT INTO public.adventure_plans (user_id, title, description, city, duration_hours, mood, is_group, status, created_at, updated_at)
VALUES 
    ('11111111-1111-1111-1111-111111111111',
     'Mystical San Francisco Adventure',
     'Discover the hidden gems and mystical places of San Francisco',
     'San Francisco',
     6,
     'mystical',
     false,
     'active',
     NOW() - INTERVAL '2 days',
     NOW() - INTERVAL '1 hour'
    )
ON CONFLICT DO NOTHING;

-- Insert adventure stops
INSERT INTO public.adventure_stops (adventure_id, name, description, latitude, longitude, category, order_index, estimated_duration, created_at)
SELECT 
    ap.id,
    'Lombard Street',
    'The famous "crookedest street in the world" with beautiful views',
    37.8021, -122.4187,
    'landmark',
    1,
    30,
    NOW() - INTERVAL '2 days'
FROM public.adventure_plans ap 
WHERE ap.title = 'Mystical San Francisco Adventure'
UNION ALL
SELECT 
    ap.id,
    'Coit Tower',
    'Historic tower with panoramic views of the city',
    37.8024, -122.4058,
    'landmark',
    2,
    45,
    NOW() - INTERVAL '2 days'
FROM public.adventure_plans ap 
WHERE ap.title = 'Mystical San Francisco Adventure'
UNION ALL
SELECT 
    ap.id,
    'Chinatown',
    'Explore the vibrant culture and hidden alleys',
    37.7941, -122.4078,
    'activity',
    3,
    60,
    NOW() - INTERVAL '2 days'
FROM public.adventure_plans ap 
WHERE ap.title = 'Mystical San Francisco Adventure'
ON CONFLICT DO NOTHING;

-- Insert safety reports
INSERT INTO public.safety_reports (user_id, latitude, longitude, report_type, description, severity, is_resolved, created_at, updated_at, expires_at, geohash)
VALUES 
    ('33333333-3333-3333-3333-333333333333',
     37.7749, -122.4194,
     'hazard',
     'Construction zone with reduced visibility',
     3,
     false,
     NOW() - INTERVAL '2 hours',
     NOW() - INTERVAL '2 hours',
     NOW() + INTERVAL '22 hours',
     public.generate_geohash(37.7749, -122.4194)
    ),
    ('33333333-3333-3333-3333-333333333333',
     37.7849, -122.4094,
     'incident',
     'Traffic accident on main street',
     4,
     false,
     NOW() - INTERVAL '1 hour',
     NOW() - INTERVAL '1 hour',
     NOW() + INTERVAL '23 hours',
     public.generate_geohash(37.7849, -122.4094)
    ),
    ('11111111-1111-1111-1111-111111111111',
     37.8044, -122.2712,
     'general',
     'Road closure due to street festival',
     2,
     true,
     NOW() - INTERVAL '6 hours',
     NOW() - INTERVAL '1 hour',
     NOW() + INTERVAL '18 hours',
     public.generate_geohash(37.8044, -122.2712)
    )
ON CONFLICT DO NOTHING;

-- Update statistics
ANALYZE;

-- Print summary
DO $$
BEGIN
    RAISE NOTICE 'Seed data inserted successfully!';
    RAISE NOTICE 'Users: %', (SELECT COUNT(*) FROM public.users);
    RAISE NOTICE 'Saved Places: %', (SELECT COUNT(*) FROM public.saved_places);
    RAISE NOTICE 'Friends: %', (SELECT COUNT(*) FROM public.friends);
    RAISE NOTICE 'ETA Shares: %', (SELECT COUNT(*) FROM public.eta_shares);
    RAISE NOTICE 'Group Trips: %', (SELECT COUNT(*) FROM public.group_trips);
    RAISE NOTICE 'Plans: %', (SELECT COUNT(*) FROM public.plans);
    RAISE NOTICE 'Adventure Plans: %', (SELECT COUNT(*) FROM public.adventure_plans);
    RAISE NOTICE 'Safety Reports: %', (SELECT COUNT(*) FROM public.safety_reports);
END $$;
