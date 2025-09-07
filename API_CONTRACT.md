# Shvil API Contract Documentation

**Version:** 1.0  
**Date:** December 2024  
**Backend:** Supabase (PostgreSQL + Auth + Realtime + Storage)

## 📋 Overview

This document defines the complete API contract between the Shvil iOS app and the Supabase backend, including all tables, RPCs, Edge Functions, and real-time subscriptions.

## 🔐 Authentication

### Supabase Auth Configuration
- **Provider:** Supabase Auth
- **Methods:** Email/Password, Magic Link, Apple Sign-in (planned)
- **Session Management:** Automatic refresh, secure storage
- **Error Handling:** Centralized via `ErrorHandlingService`

### Auth Endpoints
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/auth/v1/signup` | User registration | No |
| POST | `/auth/v1/token` | User login | No |
| POST | `/auth/v1/logout` | User logout | Yes |
| POST | `/auth/v1/recover` | Password reset | No |
| GET | `/auth/v1/user` | Get current user | Yes |

## 🗄️ Database Schema

### Tables Overview
| Table | Purpose | RLS Enabled | Indexes |
|-------|---------|-------------|---------|
| `users` | User profiles | ✅ | Primary key, email |
| `saved_places` | User's saved locations | ✅ | User ID, place type |
| `friends` | User relationships | ✅ | User ID, friend ID |
| `eta_shares` | ETA sharing | ✅ | User ID, created_at |
| `adventure_plans` | Adventure itineraries | ✅ | User ID, status |
| `safety_reports` | Safety incidents | ✅ | Location, created_at |

### Detailed Table Schemas

#### 1. `users` Table
```sql
CREATE TABLE public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    display_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Fields:**
- `id`: UUID primary key
- `email`: User's email address (unique)
- `display_name`: User's display name
- `avatar_url`: Profile picture URL
- `created_at`: Account creation timestamp
- `updated_at`: Last update timestamp

**RLS Policies:**
- Users can view their own profile
- Users can update their own profile
- Public profiles are readable by friends

#### 2. `saved_places` Table
```sql
CREATE TABLE public.saved_places (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    place_type place_type NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Fields:**
- `id`: UUID primary key
- `user_id`: Foreign key to users table
- `name`: Place name
- `address`: Full address string
- `latitude`: GPS latitude
- `longitude`: GPS longitude
- `place_type`: Enum (home, work, favorite, other)
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

**RLS Policies:**
- Users can view their own saved places
- Users can create/update/delete their own saved places

#### 3. `friends` Table
```sql
CREATE TABLE public.friends (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    friend_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    status friend_status NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, friend_id)
);
```

**Fields:**
- `id`: UUID primary key
- `user_id`: User who sent the request
- `friend_id`: User who received the request
- `status`: Enum (pending, accepted, blocked)
- `created_at`: Request timestamp
- `updated_at`: Status update timestamp

**RLS Policies:**
- Users can view their own friend relationships
- Users can create friend requests
- Users can update friend request status

#### 4. `eta_shares` Table
```sql
CREATE TABLE public.eta_shares (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    route_data JSONB NOT NULL,
    recipients JSONB NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Fields:**
- `id`: UUID primary key
- `user_id`: User sharing the ETA
- `route_data`: JSON containing route information
- `recipients`: JSON array of recipient user IDs
- `is_active`: Whether the share is still active
- `expires_at`: When the share expires
- `created_at`: Share creation timestamp
- `updated_at`: Last update timestamp

**RLS Policies:**
- Users can view their own ETA shares
- Users can view active ETA shares they're recipients of
- Users can create/update/delete their own ETA shares

#### 5. `adventure_plans` Table
```sql
CREATE TABLE public.adventure_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    route_data JSONB NOT NULL,
    stops JSONB NOT NULL,
    status adventure_status NOT NULL DEFAULT 'draft',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Fields:**
- `id`: UUID primary key
- `user_id`: User who created the adventure
- `title`: Adventure title
- `description`: Adventure description
- `route_data`: JSON containing route information
- `stops`: JSON array of adventure stops
- `status`: Enum (draft, active, completed, cancelled)
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

**RLS Policies:**
- Users can view their own adventure plans
- Users can create/update/delete their own adventure plans

#### 6. `safety_reports` Table
```sql
CREATE TABLE public.safety_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    report_type TEXT NOT NULL,
    description TEXT,
    severity INTEGER DEFAULT 1,
    is_resolved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Fields:**
- `id`: UUID primary key
- `user_id`: User who reported the incident
- `latitude`: GPS latitude of incident
- `longitude`: GPS longitude of incident
- `report_type`: Type of safety incident
- `description`: Detailed description
- `severity`: Severity level (1-5)
- `is_resolved`: Whether the incident is resolved
- `created_at`: Report timestamp
- `updated_at`: Last update timestamp

**RLS Policies:**
- Users can view all safety reports (public safety)
- Users can create safety reports
- Users can update their own safety reports

## 🔄 RPC Functions

### 1. `get_user_profile(user_id UUID)`
**Purpose:** Get user profile information
**Parameters:**
- `user_id`: UUID of the user

**Returns:**
```json
{
  "id": "uuid",
  "email": "string",
  "display_name": "string",
  "avatar_url": "string",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

**Error Handling:**
- `404`: User not found
- `403`: Access denied

### 2. `search_places(query TEXT, user_id UUID)`
**Purpose:** Search for places with autocomplete
**Parameters:**
- `query`: Search query string
- `user_id`: Current user ID for personalization

**Returns:**
```json
[
  {
    "id": "uuid",
    "name": "string",
    "address": "string",
    "latitude": "number",
    "longitude": "number",
    "place_type": "string",
    "distance": "number"
  }
]
```

**Error Handling:**
- `400`: Invalid query
- `500`: Search service error

### 3. `get_active_eta_shares(user_id UUID)`
**Purpose:** Get active ETA shares for a user
**Parameters:**
- `user_id`: User ID to get shares for

**Returns:**
```json
[
  {
    "id": "uuid",
    "user_id": "uuid",
    "route_data": "object",
    "recipients": "array",
    "is_active": "boolean",
    "expires_at": "timestamp",
    "created_at": "timestamp"
  }
]
```

**Error Handling:**
- `403`: Access denied
- `500`: Database error

## 📡 Real-time Subscriptions

### 1. `eta_shares` Table Changes
**Purpose:** Real-time updates for ETA shares
**Filter:** `user_id = auth.uid() OR recipients @> [auth.uid()]`
**Events:** INSERT, UPDATE, DELETE

### 2. `friends` Table Changes
**Purpose:** Real-time updates for friend requests
**Filter:** `user_id = auth.uid() OR friend_id = auth.uid()`
**Events:** INSERT, UPDATE, DELETE

### 3. `safety_reports` Table Changes
**Purpose:** Real-time safety updates
**Filter:** `is_resolved = false`
**Events:** INSERT, UPDATE

## 🗂️ Storage Buckets

### 1. `avatars` Bucket
**Purpose:** User profile pictures
**Access:** Public read, authenticated write
**File Types:** JPEG, PNG, WebP
**Size Limit:** 5MB
**Dimensions:** 200x200px recommended

### 2. `adventure_photos` Bucket
**Purpose:** Adventure photos and proofs
**Access:** Private (user-specific)
**File Types:** JPEG, PNG, WebP
**Size Limit:** 10MB
**Dimensions:** Max 2048x2048px

### 3. `safety_reports` Bucket
**Purpose:** Safety incident photos
**Access:** Public read, authenticated write
**File Types:** JPEG, PNG, WebP
**Size Limit:** 5MB
**Dimensions:** Max 1024x1024px

## 🔧 Edge Functions

### 1. `process-adventure` Function
**Purpose:** Process AI-generated adventure data
**Trigger:** After adventure plan creation
**Input:**
```json
{
  "adventure_id": "uuid",
  "user_id": "uuid",
  "route_data": "object"
}
```

**Output:**
```json
{
  "success": "boolean",
  "processed_stops": "array",
  "estimated_duration": "number"
}
```

### 2. `send-eta-notification` Function
**Purpose:** Send ETA notifications to recipients
**Trigger:** After ETA share creation
**Input:**
```json
{
  "eta_share_id": "uuid",
  "recipients": "array",
  "message": "string"
}
```

**Output:**
```json
{
  "success": "boolean",
  "notifications_sent": "number"
}
```

## 🚨 Error Handling

### Standard Error Responses
```json
{
  "error": {
    "code": "string",
    "message": "string",
    "details": "object"
  }
}
```

### Common Error Codes
| Code | HTTP Status | Description |
|------|-------------|-------------|
| `AUTH_REQUIRED` | 401 | Authentication required |
| `AUTH_INVALID` | 401 | Invalid authentication |
| `ACCESS_DENIED` | 403 | Access denied |
| `NOT_FOUND` | 404 | Resource not found |
| `VALIDATION_ERROR` | 400 | Input validation failed |
| `RATE_LIMITED` | 429 | Rate limit exceeded |
| `SERVER_ERROR` | 500 | Internal server error |

## 🔄 Retry Strategies

### Network Requests
- **Max Retries:** 3
- **Backoff:** Exponential (1s, 2s, 4s)
- **Retry Conditions:** Network errors, 5xx status codes
- **No Retry:** 4xx status codes (except 429)

### Real-time Connections
- **Reconnect:** Automatic on disconnect
- **Max Reconnect Attempts:** 10
- **Reconnect Delay:** 1s, 2s, 4s, 8s, 16s, 30s, 60s, 120s, 300s, 600s

## 📊 Performance Considerations

### Database Indexes
- `users.email` - Unique index for login
- `saved_places.user_id` - Index for user's places
- `eta_shares.created_at` - Index for time-based queries
- `adventure_plans.status` - Index for status filtering
- `safety_reports.latitude, longitude` - Spatial index for location queries

### Query Optimization
- Use prepared statements for repeated queries
- Implement pagination for large result sets
- Use materialized views for complex aggregations
- Cache frequently accessed data

### Rate Limiting
- **API Calls:** 1000 requests/hour per user
- **File Uploads:** 10 uploads/hour per user
- **Real-time:** 100 messages/minute per user

## 🔐 Security Considerations

### Row Level Security (RLS)
- All tables have RLS enabled
- Policies enforce user-specific access
- No cross-user data leakage

### Data Validation
- Input validation on all endpoints
- SQL injection prevention
- XSS protection for text fields

### Privacy
- User data is encrypted at rest
- Sensitive data is not logged
- GDPR compliance for data deletion

## 📱 Client Integration

### Swift/SwiftUI Integration
```swift
// Example: Get user profile
let profile = try await supabase
    .from("users")
    .select()
    .eq("id", userId)
    .single()
    .execute()
    .value
```

### Error Handling
```swift
// Example: Handle API errors
do {
    let result = try await apiCall()
} catch let error as SupabaseError {
    ErrorHandlingService.shared.handleError(error)
} catch {
    ErrorHandlingService.shared.handleError(AppError.unknown(error))
}
```

### Real-time Subscriptions
```swift
// Example: Subscribe to ETA shares
let subscription = supabase
    .from("eta_shares")
    .on(.all) { change in
        // Handle real-time updates
    }
    .subscribe()
```

## 📋 Testing Strategy

### Unit Tests
- Test all API calls with mock data
- Test error handling scenarios
- Test data validation

### Integration Tests
- Test complete user flows
- Test real-time subscriptions
- Test file uploads

### Contract Tests
- Validate API responses match schema
- Test error response formats
- Test rate limiting behavior

## 🔄 Versioning

### API Versioning
- Current version: v1
- Version header: `X-API-Version: 1.0`
- Backward compatibility maintained for 6 months

### Schema Evolution
- Additive changes only
- No breaking changes without major version bump
- Migration scripts for database changes

## 📈 Monitoring & Analytics

### Metrics Tracked
- API response times
- Error rates by endpoint
- Real-time connection stability
- Database query performance

### Alerts
- High error rates (>5%)
- Slow response times (>2s)
- Database connection issues
- Real-time connection failures

## 🚀 Future Enhancements

### Planned Features
- GraphQL API layer
- Advanced caching strategies
- Real-time collaboration
- Advanced analytics

### Performance Improvements
- Database query optimization
- CDN integration for assets
- Edge function optimization
- Real-time connection pooling