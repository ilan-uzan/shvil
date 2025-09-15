# Shvil API Endpoints Documentation

This document describes all API endpoints used by the Shvil app, including request/response schemas and examples.

## Base URL
- **Development**: `https://lnniqqjaslpyljtcmkmf.supabase.co`
- **Production**: `https://lnniqqjaslpyljtcmkmf.supabase.co`

## Authentication
All endpoints require authentication via Supabase Auth. Include the JWT token in the `Authorization` header:
```
Authorization: Bearer <jwt_token>
```

## Health Check

### GET /rest/v1/rpc/health_check
Check database and API health status.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-09-05T00:00:00Z",
  "services": {
    "database": true,
    "realtime": true
  },
  "version": "1.0.0",
  "error": null
}
```

### GET /rest/v1/rpc/health_check_detailed
Detailed health check with system metrics (authenticated only).

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-09-05T00:00:00Z",
  "services": {
    "database": true,
    "realtime": true,
    "auth": true,
    "storage": true
  },
  "version": "1.0.0",
  "environment": "development",
  "table_counts": {
    "public.users": 3,
    "public.saved_places": 5,
    "public.friends": 4
  },
  "errors": []
}
```

## User Management

### GET /rest/v1/users
Get current user profile.

**Response:**
```json
[
  {
    "id": "11111111-1111-1111-1111-111111111111",
    "email": "alice@example.com",
    "display_name": "Alice Johnson",
    "avatar_url": "https://api.dicebear.com/7.x/avataaars/svg?seed=alice",
    "created_at": "2024-08-06T00:00:00Z",
    "updated_at": "2024-09-04T00:00:00Z"
  }
]
```

### PATCH /rest/v1/users
Update user profile.

**Request Body:**
```json
{
  "display_name": "Alice Johnson",
  "avatar_url": "https://api.dicebear.com/7.x/avataaars/svg?seed=alice"
}
```

## Saved Places

### GET /rest/v1/saved_places
Get user's saved places.

**Response:**
```json
[
  {
    "id": "11111111-1111-1111-1111-111111111111",
    "name": "Home",
    "address": "123 Main St, San Francisco, CA",
    "latitude": 37.7749,
    "longitude": -122.4194,
    "type": "home",
    "created_at": "2024-08-06T00:00:00Z",
    "updated_at": "2024-09-04T00:00:00Z"
  }
]
```

### POST /rest/v1/saved_places
Save a new place.

**Request Body:**
```json
{
  "name": "New Place",
  "address": "456 Oak St, San Francisco, CA",
  "latitude": 37.7849,
  "longitude": -122.4094,
  "type": "custom"
}
```

### DELETE /rest/v1/saved_places?id=eq.{place_id}
Delete a saved place.

## Friends & Social

### GET /rest/v1/friends
Get user's friends list.

**Response:**
```json
[
  {
    "id": "22222222-2222-2222-2222-222222222222",
    "user_id": "11111111-1111-1111-1111-111111111111",
    "friend_id": "33333333-3333-3333-3333-333333333333",
    "status": "accepted",
    "created_at": "2024-08-21T00:00:00Z"
  }
]
```

### POST /rest/v1/friends
Send friend request.

**Request Body:**
```json
{
  "friend_id": "33333333-3333-3333-3333-333333333333"
}
```

### PATCH /rest/v1/friends?id=eq.{friend_id}
Update friend status.

**Request Body:**
```json
{
  "status": "accepted"
}
```

### GET /rest/v1/friend_locations
Get friends' current locations.

**Response:**
```json
[
  {
    "id": "11111111-1111-1111-1111-111111111111",
    "user_id": "22222222-2222-2222-2222-222222222222",
    "latitude": 37.8044,
    "longitude": -122.2712,
    "accuracy": 8.0,
    "timestamp": "2024-09-05T00:00:00Z"
  }
]
```

### POST /rest/v1/friend_locations
Update user's location.

**Request Body:**
```json
{
  "latitude": 37.7749,
  "longitude": -122.4194,
  "accuracy": 5.0
}
```

### GET /rest/v1/friends_presence
Get friends' online status.

**Response:**
```json
[
  {
    "id": "11111111-1111-1111-1111-111111111111",
    "user_id": "22222222-2222-2222-2222-222222222222",
    "is_online": true,
    "last_seen": "2024-09-05T00:00:00Z",
    "status": "available",
    "updated_at": "2024-09-05T00:00:00Z"
  }
]
```

## ETA Sharing

### GET /rest/v1/eta_shares
Get active ETA shares.

**Response:**
```json
[
  {
    "id": "11111111-1111-1111-1111-111111111111",
    "user_id": "22222222-2222-2222-2222-222222222222",
    "route_data": {
      "duration": "25 minutes",
      "distance": "8.5 miles",
      "type": "driving",
      "isFastest": true,
      "isSafest": false
    },
    "recipients": ["alice@example.com", "bob@example.com"],
    "is_active": true,
    "created_at": "2024-09-05T00:00:00Z",
    "expires_at": "2024-09-05T01:00:00Z"
  }
]
```

### POST /rest/v1/eta_shares
Share ETA with friends.

**Request Body:**
```json
{
  "route_data": {
    "duration": "25 minutes",
    "distance": "8.5 miles",
    "type": "driving",
    "isFastest": true,
    "isSafest": false
  },
  "recipients": ["alice@example.com", "bob@example.com"]
}
```

### PATCH /rest/v1/eta_shares?id=eq.{share_id}
Update ETA share status.

**Request Body:**
```json
{
  "is_active": false
}
```

### GET /rest/v1/eta_sessions
Get active ETA sessions.

**Response:**
```json
[
  {
    "id": "11111111-1111-1111-1111-111111111111",
    "user_id": "22222222-2222-2222-2222-222222222222",
    "session_name": "Commute to Work",
    "route_data": {
      "start": {"lat": 37.7749, "lng": -122.4194},
      "end": {"lat": 37.7849, "lng": -122.4094},
      "waypoints": []
    },
    "current_position": {
      "lat": 37.7799,
      "lng": -122.4144,
      "accuracy": 5.0
    },
    "eta_seconds": 1200,
    "is_active": true,
    "started_at": "2024-09-05T00:00:00Z",
    "expires_at": "2024-09-05T01:00:00Z",
    "updated_at": "2024-09-05T00:00:00Z"
  }
]
```

## Group Trips

### GET /rest/v1/group_trips
Get user's group trips.

**Response:**
```json
[
  {
    "id": "11111111-1111-1111-1111-111111111111",
    "name": "Weekend Adventure to Napa Valley",
    "description": "A relaxing weekend trip to explore Napa Valley wineries",
    "creator_id": "22222222-2222-2222-2222-222222222222",
    "destination_latitude": 38.2975,
    "destination_longitude": -122.2869,
    "destination_name": "Napa Valley, CA",
    "start_time": "2024-09-07T00:00:00Z",
    "end_time": "2024-09-09T00:00:00Z",
    "status": "planning",
    "created_at": "2024-08-31T00:00:00Z",
    "updated_at": "2024-09-04T00:00:00Z"
  }
]
```

### POST /rest/v1/group_trips
Create new group trip.

**Request Body:**
```json
{
  "name": "Weekend Adventure to Napa Valley",
  "description": "A relaxing weekend trip to explore Napa Valley wineries",
  "destination_latitude": 38.2975,
  "destination_longitude": -122.2869,
  "destination_name": "Napa Valley, CA",
  "start_time": "2024-09-07T00:00:00Z",
  "end_time": "2024-09-09T00:00:00Z"
}
```

### GET /rest/v1/group_trip_participants?trip_id=eq.{trip_id}
Get group trip participants.

**Response:**
```json
[
  {
    "id": "11111111-1111-1111-1111-111111111111",
    "trip_id": "22222222-2222-2222-2222-222222222222",
    "user_id": "33333333-3333-3333-3333-333333333333",
    "status": "accepted",
    "joined_at": "2024-08-31T00:00:00Z"
  }
]
```

## Plans (Together Mode)

### GET /rest/v1/plans
Get user's plans.

**Response:**
```json
[
  {
    "id": "11111111-1111-1111-1111-111111111111",
    "title": "Food Tour of Mission District",
    "description": "Explore the best food spots in San Francisco's Mission District",
    "creator_id": "22222222-2222-2222-2222-222222222222",
    "city": "San Francisco",
    "start_date": "2024-09-12T00:00:00Z",
    "end_date": "2024-09-13T00:00:00Z",
    "status": "voting",
    "created_at": "2024-09-02T00:00:00Z",
    "updated_at": "2024-09-04T00:00:00Z"
  }
]
```

### POST /rest/v1/plans
Create new plan.

**Request Body:**
```json
{
  "title": "Food Tour of Mission District",
  "description": "Explore the best food spots in San Francisco's Mission District",
  "city": "San Francisco",
  "start_date": "2024-09-12T00:00:00Z",
  "end_date": "2024-09-13T00:00:00Z"
}
```

### GET /rest/v1/plan_places?plan_id=eq.{plan_id}
Get plan places.

**Response:**
```json
[
  {
    "id": "11111111-1111-1111-1111-111111111111",
    "plan_id": "22222222-2222-2222-2222-222222222222",
    "name": "La Taqueria",
    "address": "2889 Mission St, San Francisco, CA 94110",
    "latitude": 37.7500,
    "longitude": -122.4194,
    "category": "food",
    "added_by": "33333333-3333-3333-3333-333333333333",
    "added_at": "2024-09-02T00:00:00Z"
  }
]
```

### POST /rest/v1/plan_places
Add place to plan.

**Request Body:**
```json
{
  "plan_id": "22222222-2222-2222-2222-222222222222",
  "name": "La Taqueria",
  "address": "2889 Mission St, San Francisco, CA 94110",
  "latitude": 37.7500,
  "longitude": -122.4194,
  "category": "food"
}
```

### GET /rest/v1/plan_votes?plan_id=eq.{plan_id}
Get plan votes.

**Response:**
```json
[
  {
    "id": "11111111-1111-1111-1111-111111111111",
    "plan_id": "22222222-2222-2222-2222-222222222222",
    "place_id": "33333333-3333-3333-3333-333333333333",
    "user_id": "44444444-4444-4444-4444-444444444444",
    "vote_type": "up",
    "rank_value": null,
    "created_at": "2024-09-02T00:00:00Z"
  }
]
```

### POST /rest/v1/plan_votes
Vote on plan place.

**Request Body:**
```json
{
  "plan_id": "22222222-2222-2222-2222-222222222222",
  "place_id": "33333333-3333-3333-3333-333333333333",
  "vote_type": "up",
  "rank_value": null
}
```

## Adventure Plans

### GET /rest/v1/adventure_plans
Get user's adventure plans.

**Response:**
```json
[
  {
    "id": "11111111-1111-1111-1111-111111111111",
    "user_id": "22222222-2222-2222-2222-222222222222",
    "title": "Mystical San Francisco Adventure",
    "description": "Discover the hidden gems and mystical places of San Francisco",
    "city": "San Francisco",
    "duration_hours": 6,
    "mood": "mystical",
    "is_group": false,
    "status": "active",
    "created_at": "2024-09-03T00:00:00Z",
    "updated_at": "2024-09-04T00:00:00Z"
  }
]
```

### POST /rest/v1/adventure_plans
Create new adventure plan.

**Request Body:**
```json
{
  "title": "Mystical San Francisco Adventure",
  "description": "Discover the hidden gems and mystical places of San Francisco",
  "city": "San Francisco",
  "duration_hours": 6,
  "mood": "mystical",
  "is_group": false
}
```

### GET /rest/v1/adventure_stops?adventure_id=eq.{adventure_id}
Get adventure stops.

**Response:**
```json
[
  {
    "id": "11111111-1111-1111-1111-111111111111",
    "adventure_id": "22222222-2222-2222-2222-222222222222",
    "name": "Lombard Street",
    "description": "The famous \"crookedest street in the world\" with beautiful views",
    "latitude": 37.8021,
    "longitude": -122.4187,
    "category": "landmark",
    "order_index": 1,
    "estimated_duration": 30,
    "created_at": "2024-09-03T00:00:00Z"
  }
]
```

## Safety Reports

### GET /rest/v1/safety_reports
Get safety reports (public data).

**Query Parameters:**
- `latitude`: Filter by latitude range
- `longitude`: Filter by longitude range
- `radius`: Search radius in meters (default: 1000)

**Response:**
```json
[
  {
    "id": "11111111-1111-1111-1111-111111111111",
    "user_id": "22222222-2222-2222-2222-222222222222",
    "latitude": 37.7749,
    "longitude": -122.4194,
    "report_type": "hazard",
    "description": "Construction zone with reduced visibility",
    "severity": 3,
    "is_resolved": false,
    "created_at": "2024-09-05T00:00:00Z",
    "updated_at": "2024-09-05T00:00:00Z",
    "expires_at": "2024-09-06T00:00:00Z",
    "geohash": "9q8yyk"
  }
]
```

### POST /rest/v1/safety_reports
Create safety report.

**Request Body:**
```json
{
  "latitude": 37.7749,
  "longitude": -122.4194,
  "report_type": "hazard",
  "description": "Construction zone with reduced visibility",
  "severity": 3
}
```

## Realtime Channels

The app uses Supabase Realtime for live updates. Subscribe to these channels:

### ETA Updates
- **Channel**: `eta:{session_id}`
- **Events**: `position_update`, `eta_update`, `session_ended`

### Group Trips
- **Channel**: `trip:{trip_id}`
- **Events**: `participant_joined`, `participant_left`, `trip_updated`

### Plans
- **Channel**: `plan:{plan_id}`
- **Events**: `place_added`, `vote_cast`, `plan_locked`

### Adventures
- **Channel**: `adventure:{adventure_id}`
- **Events**: `stop_reached`, `adventure_completed`

### Safety Reports
- **Channel**: `safety:reports`
- **Events**: `new_report`, `report_resolved`

## Error Responses

All endpoints return standard HTTP status codes. Error responses follow this format:

```json
{
  "code": "ERROR_CODE",
  "message": "Human readable error message",
  "details": "Additional error details"
}
```

Common error codes:
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `409` - Conflict
- `500` - Internal Server Error

## Rate Limiting

API requests are rate limited:
- **Authenticated users**: 1000 requests per hour
- **Anonymous users**: 100 requests per hour

Rate limit headers are included in responses:
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640995200
```
