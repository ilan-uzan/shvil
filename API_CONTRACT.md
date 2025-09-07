# Shvil API Contract Documentation

## Supabase Integration Overview

### Authentication
- **Apple Sign-In**: ✅ Implemented with graceful degradation
- **Email/Magic Link**: ✅ Primary authentication method
- **Session Management**: ✅ Proper token handling and refresh

### Database Schema
```sql
-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    display_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Adventure Plans
CREATE TABLE adventure_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    stops JSONB,
    status TEXT DEFAULT 'draft',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Social Groups
CREATE TABLE social_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    created_by UUID REFERENCES users(id) ON DELETE CASCADE,
    invite_code TEXT UNIQUE NOT NULL,
    qr_code TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Group Members
CREATE TABLE group_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID REFERENCES social_groups(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(group_id, user_id)
);

-- Scavenger Hunts
CREATE TABLE scavenger_hunts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    created_by UUID REFERENCES users(id) ON DELETE CASCADE,
    group_id UUID REFERENCES social_groups(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'draft',
    start_time TIMESTAMP WITH TIME ZONE,
    end_time TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Hunt Checkpoints
CREATE TABLE hunt_checkpoints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hunt_id UUID REFERENCES scavenger_hunts(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    location JSONB,
    photo_required BOOLEAN DEFAULT false,
    points INTEGER DEFAULT 10,
    order_index INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Checkpoint Submissions
CREATE TABLE checkpoint_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    checkpoint_id UUID REFERENCES hunt_checkpoints(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    photo_url TEXT,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    verified BOOLEAN DEFAULT false,
    UNIQUE(checkpoint_id, user_id)
);

-- Saved Places
CREATE TABLE saved_places (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    address TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    category TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ETA Shares
CREATE TABLE eta_shares (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    route_data JSONB NOT NULL,
    recipients UUID[] NOT NULL,
    is_active BOOLEAN DEFAULT true,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## API Endpoints

### Authentication Endpoints

#### Sign In with Email
```http
POST /auth/v1/signin/email
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "refresh_token_here",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "display_name": "User Name"
  }
}
```

#### Sign Up with Email
```http
POST /auth/v1/signup/email
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

#### Apple Sign In
```http
POST /auth/v1/signin/apple
Content-Type: application/json

{
  "id_token": "apple_id_token",
  "nonce": "nonce_value"
}
```

#### Sign Out
```http
POST /auth/v1/signout
Authorization: Bearer {access_token}
```

### Adventure Plans Endpoints

#### Create Adventure Plan
```http
POST /rest/v1/adventure_plans
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "title": "Weekend Adventure",
  "description": "A fun weekend trip",
  "stops": [
    {
      "name": "Coffee Shop",
      "address": "123 Main St",
      "latitude": 37.7749,
      "longitude": -122.4194
    }
  ]
}
```

#### Get User's Adventure Plans
```http
GET /rest/v1/adventure_plans?user_id=eq.{userId}
Authorization: Bearer {access_token}
```

#### Update Adventure Plan
```http
PATCH /rest/v1/adventure_plans?id=eq.{id}
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "title": "Updated Adventure",
  "status": "active"
}
```

#### Delete Adventure Plan
```http
DELETE /rest/v1/adventure_plans?id=eq.{id}
Authorization: Bearer {access_token}
```

### Social Groups Endpoints

#### Create Group
```http
POST /rest/v1/social_groups
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "Weekend Warriors",
  "description": "Adventure group for weekend trips"
}
```

#### Join Group by Invite Code
```http
POST /rest/v1/social_groups/join
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "invite_code": "ABC123"
}
```

#### Get Group Members
```http
GET /rest/v1/group_members?group_id=eq.{groupId}
Authorization: Bearer {access_token}
```

#### Leave Group
```http
DELETE /rest/v1/group_members?group_id=eq.{groupId}&user_id=eq.{userId}
Authorization: Bearer {access_token}
```

### Scavenger Hunt Endpoints

#### Create Hunt
```http
POST /rest/v1/scavenger_hunts
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "title": "City Scavenger Hunt",
  "description": "Explore the city and find hidden treasures",
  "group_id": "uuid",
  "checkpoints": [
    {
      "title": "Find the Red Door",
      "description": "Look for a red door on Main Street",
      "location": {
        "latitude": 37.7749,
        "longitude": -122.4194
      },
      "photo_required": true,
      "points": 20
    }
  ]
}
```

#### Join Hunt
```http
POST /rest/v1/scavenger_hunts/{huntId}/join
Authorization: Bearer {access_token}
```

#### Start Hunt
```http
PATCH /rest/v1/scavenger_hunts?id=eq.{huntId}
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "status": "active",
  "start_time": "2024-01-01T10:00:00Z"
}
```

#### Submit Checkpoint
```http
POST /rest/v1/checkpoint_submissions
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "checkpoint_id": "uuid",
  "photo_url": "https://storage.supabase.co/object/public/photos/photo.jpg"
}
```

#### Get Hunt Leaderboard
```http
GET /rest/v1/hunt_leaderboard?hunt_id=eq.{huntId}
Authorization: Bearer {access_token}
```

### Saved Places Endpoints

#### Save Place
```http
POST /rest/v1/saved_places
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "Favorite Coffee Shop",
  "address": "123 Main St, San Francisco, CA",
  "latitude": 37.7749,
  "longitude": -122.4194,
  "category": "coffee"
}
```

#### Get Saved Places
```http
GET /rest/v1/saved_places?user_id=eq.{userId}
Authorization: Bearer {access_token}
```

#### Delete Saved Place
```http
DELETE /rest/v1/saved_places?id=eq.{id}
Authorization: Bearer {access_token}
```

### ETA Sharing Endpoints

#### Share ETA
```http
POST /rest/v1/eta_shares
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "route_data": {
    "origin": {
      "latitude": 37.7749,
      "longitude": -122.4194,
      "address": "123 Main St"
    },
    "destination": {
      "latitude": 37.7849,
      "longitude": -122.4094,
      "address": "456 Oak St"
    },
    "distance": 5.2,
    "duration": 1800,
    "transport_mode": "driving",
    "estimated_arrival": "2024-01-01T15:30:00Z"
  },
  "recipients": ["uuid1", "uuid2"],
  "expires_at": "2024-01-01T16:00:00Z"
}
```

#### Get Active ETA Shares
```http
GET /rest/v1/eta_shares?is_active=eq.true
Authorization: Bearer {access_token}
```

### Health Check Endpoints

#### Basic Health Check
```http
GET /rest/v1/rpc/health_check
Authorization: Bearer {access_token}
```

#### Detailed Health Check
```http
GET /rest/v1/rpc/health_check_detailed
Authorization: Bearer {access_token}
```

#### System Metrics
```http
GET /rest/v1/rpc/get_system_metrics
Authorization: Bearer {access_token}
```

## Data Models

### User
```swift
struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let displayName: String?
    let avatarUrl: String?
    let createdAt: Date
    let updatedAt: Date
}
```

### SavedPlace
```swift
struct SavedPlace: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let placeType: PlaceType
    let createdAt: Date
    let updatedAt: Date
}
```

### Adventure
```swift
struct Adventure: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let title: String
    let description: String?
    let routeData: RouteData
    let stops: [AdventureStop]
    let status: AdventureStatus
    let createdAt: Date
    let updatedAt: Date
}
```

### SocialGroup
```swift
struct SocialGroup: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String?
    let createdBy: UUID
    let inviteCode: String
    let qrCode: String
    let memberCount: Int
    let createdAt: Date
    let updatedAt: Date
}
```

### ScavengerHunt
```swift
struct ScavengerHunt: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String?
    let createdBy: UUID
    let groupId: UUID?
    let status: HuntStatus
    let startTime: Date?
    let endTime: Date?
    let participantCount: Int
    let checkpointCount: Int
    let progress: Double
    let createdAt: Date
    let updatedAt: Date
}
```

### ETAShare
```swift
struct ETAShare: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let routeData: RouteData
    let recipients: [UUID]
    let isActive: Bool
    let expiresAt: Date
    let createdAt: Date
    let updatedAt: Date
}
```

## Error Handling

### Standard Error Response
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": "Additional error details"
  }
}
```

### Common Error Codes
- `AUTH_REQUIRED`: Authentication required
- `INVALID_CREDENTIALS`: Invalid email/password
- `USER_NOT_FOUND`: User does not exist
- `GROUP_NOT_FOUND`: Group does not exist
- `HUNT_NOT_FOUND`: Hunt does not exist
- `PERMISSION_DENIED`: Insufficient permissions
- `VALIDATION_ERROR`: Input validation failed
- `RATE_LIMIT_EXCEEDED`: Too many requests
- `SERVER_ERROR`: Internal server error
- `NOT_CONNECTED`: Supabase connection failed

### Error Handling in Swift
```swift
enum APIError: LocalizedError {
    case authRequired
    case invalidCredentials
    case userNotFound
    case groupNotFound
    case huntNotFound
    case permissionDenied
    case validationError(String)
    case rateLimitExceeded
    case serverError
    case networkError
    case notConnected
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .authRequired:
            return "Authentication required"
        case .invalidCredentials:
            return "Invalid email or password"
        case .userNotFound:
            return "User not found"
        case .groupNotFound:
            return "Group not found"
        case .huntNotFound:
            return "Hunt not found"
        case .permissionDenied:
            return "Permission denied"
        case .validationError(let message):
            return "Validation error: \(message)"
        case .rateLimitExceeded:
            return "Too many requests. Please try again later."
        case .serverError:
            return "Server error. Please try again later."
        case .networkError:
            return "Network error. Please check your connection."
        case .notConnected:
            return "Not connected to Supabase. Please check your internet connection."
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
```

## Row Level Security (RLS) Policies

### Users Table
```sql
-- Users can only see their own data
CREATE POLICY "Users can view own data" ON users
    FOR SELECT USING (auth.uid() = id);

-- Users can update their own data
CREATE POLICY "Users can update own data" ON users
    FOR UPDATE USING (auth.uid() = id);
```

### Adventure Plans Table
```sql
-- Users can only see their own adventure plans
CREATE POLICY "Users can view own adventures" ON adventure_plans
    FOR SELECT USING (auth.uid() = user_id);

-- Users can create their own adventure plans
CREATE POLICY "Users can create adventures" ON adventure_plans
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own adventure plans
CREATE POLICY "Users can update own adventures" ON adventure_plans
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own adventure plans
CREATE POLICY "Users can delete own adventures" ON adventure_plans
    FOR DELETE USING (auth.uid() = user_id);
```

### Social Groups Table
```sql
-- Group members can view group details
CREATE POLICY "Group members can view groups" ON social_groups
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM group_members 
            WHERE group_id = social_groups.id 
            AND user_id = auth.uid()
        )
    );

-- Users can create groups
CREATE POLICY "Users can create groups" ON social_groups
    FOR INSERT WITH CHECK (auth.uid() = created_by);
```

### Group Members Table
```sql
-- Group members can view other members
CREATE POLICY "Group members can view members" ON group_members
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM group_members gm
            WHERE gm.group_id = group_members.group_id
            AND gm.user_id = auth.uid()
        )
    );

-- Users can join groups
CREATE POLICY "Users can join groups" ON group_members
    FOR INSERT WITH CHECK (auth.uid() = user_id);
```

### ETA Shares Table
```sql
-- Users can view their own shares and shares shared with them
CREATE POLICY "Users can view relevant shares" ON eta_shares
    FOR SELECT USING (
        auth.uid() = user_id OR 
        auth.uid() = ANY(recipients)
    );

-- Users can create their own shares
CREATE POLICY "Users can create shares" ON eta_shares
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own shares
CREATE POLICY "Users can update own shares" ON eta_shares
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own shares
CREATE POLICY "Users can delete own shares" ON eta_shares
    FOR DELETE USING (auth.uid() = user_id);
```

## Required Indexes

### Performance Indexes
```sql
-- Adventure plans by user
CREATE INDEX idx_adventure_plans_user_id ON adventure_plans(user_id);

-- Social groups by invite code
CREATE INDEX idx_social_groups_invite_code ON social_groups(invite_code);

-- Group members by group
CREATE INDEX idx_group_members_group_id ON group_members(group_id);

-- Group members by user
CREATE INDEX idx_group_members_user_id ON group_members(user_id);

-- Scavenger hunts by group
CREATE INDEX idx_scavenger_hunts_group_id ON scavenger_hunts(group_id);

-- Hunt checkpoints by hunt
CREATE INDEX idx_hunt_checkpoints_hunt_id ON hunt_checkpoints(hunt_id);

-- Checkpoint submissions by user and checkpoint
CREATE INDEX idx_checkpoint_submissions_user_checkpoint ON checkpoint_submissions(user_id, checkpoint_id);

-- Saved places by user
CREATE INDEX idx_saved_places_user_id ON saved_places(user_id);

-- ETA shares by user
CREATE INDEX idx_eta_shares_user_id ON eta_shares(user_id);

-- ETA shares by recipients (GIN index for array)
CREATE INDEX idx_eta_shares_recipients ON eta_shares USING gin(recipients);
```

### Composite Indexes
```sql
-- Hunt leaderboard query
CREATE INDEX idx_checkpoint_submissions_hunt_user ON checkpoint_submissions(checkpoint_id, user_id, submitted_at);

-- Group activity query
CREATE INDEX idx_group_members_group_joined ON group_members(group_id, joined_at);

-- ETA shares by active status and expiration
CREATE INDEX idx_eta_shares_active_expires ON eta_shares(is_active, expires_at);
```

## Rate Limiting

### API Rate Limits
- **Authentication**: 10 requests per minute per IP
- **General API**: 100 requests per minute per user
- **File Upload**: 20 requests per minute per user
- **Search**: 50 requests per minute per user

### Rate Limit Headers
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640995200
```

## Caching Strategy

### Client-Side Caching
- **User Data**: 1 hour TTL
- **Adventure Plans**: 30 minutes TTL
- **Social Groups**: 15 minutes TTL
- **Hunt Data**: 5 minutes TTL
- **ETA Shares**: 1 minute TTL

### Server-Side Caching
- **Static Data**: 24 hours TTL
- **User Sessions**: 1 hour TTL
- **API Responses**: 5 minutes TTL

## Security Considerations

### Authentication
- JWT tokens with 1-hour expiration
- Refresh tokens with 30-day expiration
- Secure token storage in Keychain
- Automatic token refresh

### Data Protection
- All sensitive data encrypted at rest
- HTTPS for all API communications
- Input validation and sanitization
- SQL injection prevention

### Privacy
- RLS policies for data isolation
- User consent for data collection
- GDPR compliance for EU users
- Data retention policies

## Real-time Features

### Subscriptions
- **Saved Places**: Real-time updates when places are added/removed
- **Adventures**: Real-time updates when adventure status changes
- **Social Groups**: Real-time updates when members join/leave
- **Scavenger Hunts**: Real-time updates when hunts start/complete
- **ETA Shares**: Real-time updates when ETA is shared

### Channels
- `saved_places:user_id` - User's saved places updates
- `adventures:user_id` - User's adventures updates
- `social_groups:group_id` - Group updates
- `scavenger_hunts:hunt_id` - Hunt updates
- `eta_shares:user_id` - ETA share updates

## Configuration

### Environment Variables
- `SUPABASE_URL`: Supabase project URL
- `SUPABASE_ANON_KEY`: Supabase anonymous key
- `OPENAI_API_KEY`: OpenAI API key (optional, for AI features)

### Connection Management
- Automatic connection testing on app launch
- Retry logic for failed connections
- Graceful degradation when offline

## Monitoring and Analytics

### API Metrics
- Request/response times
- Error rates by endpoint
- Authentication success rates
- Database query performance

### User Analytics
- Feature usage tracking
- Error reporting
- Performance monitoring
- Crash reporting

## Testing

### API Testing
- Unit tests for all endpoints
- Integration tests for data flow
- Load testing for performance
- Security testing for vulnerabilities

### Client Testing
- Mock API responses
- Offline mode testing
- Error handling testing
- Performance testing

## Documentation Updates

This API contract is maintained and updated as the backend evolves. All changes are documented with:
- Version numbers
- Change descriptions
- Migration guides
- Breaking change notices

## Support

For API support and questions:
- **Documentation**: This file and inline code comments
- **Issues**: GitHub issues for bug reports
- **Discussions**: GitHub discussions for questions
- **Email**: api-support@shvil.app