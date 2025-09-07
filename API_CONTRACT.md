# Shvil API Contract Documentation

**Version:** 2.0 (Liquid Glass Refactor)  
**Date:** December 2024  
**Backend:** Supabase (PostgreSQL + Auth + Realtime)

## 🔐 Authentication Endpoints

### User Registration
```http
POST /auth/v1/signup
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword123",
  "options": {
    "data": {
      "display_name": "John Doe"
    }
  }
}
```

**Response:**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "created_at": "2024-12-01T00:00:00Z"
  },
  "session": {
    "access_token": "jwt_token",
    "refresh_token": "refresh_token",
    "expires_at": 1234567890
  }
}
```

### User Login
```http
POST /auth/v1/token?grant_type=password
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

### Apple Sign-in (Feature Flag: APPLE_SIGNIN_ENABLED)
```http
POST /auth/v1/authorize
Content-Type: application/json

{
  "provider": "apple",
  "id_token": "apple_id_token",
  "nonce": "random_nonce"
}
```

### Magic Link Authentication
```http
POST /auth/v1/magiclink
Content-Type: application/json

{
  "email": "user@example.com",
  "options": {
    "redirect_to": "shvil://auth/callback"
  }
}
```

## 📍 Location & Places Endpoints

### Save Place
```http
POST /rest/v1/saved_places
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "Home",
  "address": "123 Main St, City, State",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "type": "home"
}
```

### Get Saved Places
```http
GET /rest/v1/saved_places?select=*
Authorization: Bearer {access_token}
```

**Response:**
```json
[
  {
    "id": "uuid",
    "name": "Home",
    "address": "123 Main St, City, State",
    "latitude": 40.7128,
    "longitude": -74.0060,
    "type": "home",
    "created_at": "2024-12-01T00:00:00Z"
  }
]
```

### Delete Saved Place
```http
DELETE /rest/v1/saved_places?id=eq.{place_id}
Authorization: Bearer {access_token}
```

## 🗺️ Adventure & Route Endpoints

### Create Adventure Plan
```http
POST /rest/v1/adventure_plans
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "title": "Downtown Food Tour",
  "description": "Explore the best restaurants in downtown",
  "city": "New York",
  "duration_hours": 4,
  "mood": "foodie",
  "is_group": false
}
```

### Get Adventure Plans
```http
GET /rest/v1/adventure_plans?select=*,adventure_stops(*)
Authorization: Bearer {access_token}
```

### Create Adventure Stop
```http
POST /rest/v1/adventure_stops
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "adventure_id": "uuid",
  "name": "Joe's Pizza",
  "description": "Best pizza in the city",
  "latitude": 40.7589,
  "longitude": -73.9851,
  "category": "food",
  "order_index": 1,
  "estimated_duration": 60
}
```

## 👥 Social Features Endpoints

### Share ETA
```http
POST /rest/v1/eta_shares
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "route_data": {
    "duration": "25 minutes",
    "distance": "5.2 miles",
    "type": "driving",
    "is_fastest": true,
    "is_safest": false
  },
  "recipients": ["friend1@example.com", "friend2@example.com"],
  "expires_at": "2024-12-01T01:00:00Z"
}
```

### Get Active ETA Shares
```http
GET /rest/v1/eta_shares?is_active=eq.true&select=*
Authorization: Bearer {access_token}
```

### Update Friend Location
```http
POST /rest/v1/friend_locations
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "latitude": 40.7128,
  "longitude": -74.0060,
  "accuracy": 10.0
}
```

### Get Friend Locations
```http
GET /rest/v1/friend_locations?select=*
Authorization: Bearer {access_token}
```

## 🚨 Safety & Emergency Endpoints

### Create Safety Report
```http
POST /rest/v1/safety_reports
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "latitude": 40.7128,
  "longitude": -74.0060,
  "report_type": "incident",
  "description": "Construction blocking sidewalk",
  "severity": 3
}
```

### Get Safety Reports
```http
GET /rest/v1/safety_reports?select=*&created_at=gte.{timestamp}
Authorization: Bearer {access_token}
```

## 🔍 Search & Discovery Endpoints

### Search Places
```http
GET /rest/v1/places?select=*&name=ilike.*{query}*
Authorization: Bearer {access_token}
```

### Get Nearby Places
```http
GET /rest/v1/places?select=*&location=within.{radius}of.{lat},{lng}
Authorization: Bearer {access_token}
```

## 📊 Analytics & Health Check Endpoints

### Health Check
```http
GET /rest/v1/rpc/health_check
```

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-12-01T00:00:00Z",
  "version": "1.0.0"
}
```

### Detailed Health Check
```http
GET /rest/v1/rpc/health_check_detailed
```

**Response:**
```json
{
  "status": "healthy",
  "database": "connected",
  "auth": "operational",
  "storage": "operational",
  "realtime": "operational",
  "timestamp": "2024-12-01T00:00:00Z"
}
```

### System Metrics
```http
GET /rest/v1/rpc/get_system_metrics
Authorization: Bearer {access_token}
```

## 🔄 Real-time Subscriptions

### Friend Locations
```javascript
const subscription = supabase
  .channel('friend_locations')
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'friend_locations'
  }, (payload) => {
    console.log('New friend location:', payload.new)
  })
  .subscribe()
```

### ETA Shares
```javascript
const subscription = supabase
  .channel('eta_shares')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'eta_shares',
    filter: 'user_id=eq.' + userId
  }, (payload) => {
    console.log('ETA share update:', payload)
  })
  .subscribe()
```

## 🚫 Error Responses

### Authentication Errors
```json
{
  "error": "invalid_grant",
  "error_description": "Invalid login credentials"
}
```

### Validation Errors
```json
{
  "code": "23505",
  "details": "Key (email)=(user@example.com) already exists",
  "hint": null,
  "message": "duplicate key value violates unique constraint"
}
```

### Permission Errors
```json
{
  "code": "42501",
  "details": "new row violates row-level security policy",
  "hint": null,
  "message": "permission denied for table saved_places"
}
```

## 🔒 Security Headers

### Required Headers
```http
Authorization: Bearer {access_token}
Content-Type: application/json
apikey: {supabase_anon_key}
```

### Optional Headers
```http
Prefer: return=minimal
Prefer: resolution=merge-duplicates
```

## 📈 Rate Limiting

### Limits
- **Authentication**: 5 requests per minute per IP
- **API Calls**: 1000 requests per hour per user
- **File Uploads**: 10MB per request, 100MB per hour
- **Real-time**: 10 concurrent connections per user

### Rate Limit Headers
```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640995200
```

## 🔄 Pagination

### Query Parameters
```http
GET /rest/v1/saved_places?limit=20&offset=0&order=created_at.desc
```

### Response Headers
```http
Content-Range: 0-19/100
X-Total-Count: 100
```

## 🧪 Testing Endpoints

### Test Data Creation
```http
POST /rest/v1/rpc/create_test_data
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "user_count": 10,
  "places_count": 50,
  "adventures_count": 20
}
```

### Test Data Cleanup
```http
POST /rest/v1/rpc/cleanup_test_data
Authorization: Bearer {access_token}
```

## 📱 Mobile-Specific Considerations

### Deep Links
- **Authentication Callback**: `shvil://auth/callback?token={access_token}`
- **Adventure Share**: `shvil://adventure/{adventure_id}`
- **Location Share**: `shvil://location/{lat},{lng}`

### Push Notifications
- **ETA Updates**: Real-time ETA changes
- **Safety Alerts**: Nearby safety incidents
- **Friend Requests**: Social notifications

### Offline Support
- **Cached Data**: Local storage for offline access
- **Sync Queue**: Background sync when online
- **Conflict Resolution**: Last-write-wins strategy

---

## 🔧 Development & Testing

### Local Development
```bash
# Start Supabase locally
supabase start

# Run migrations
supabase db reset

# Generate types
supabase gen types typescript --local > types/supabase.ts
```

### Environment Variables
```bash
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

### API Testing
```bash
# Test health check
curl -X GET "http://localhost:54321/rest/v1/rpc/health_check"

# Test authentication
curl -X POST "http://localhost:54321/auth/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

---

*This API contract will be updated as new endpoints are added and existing ones are modified.*
