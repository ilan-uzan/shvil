# API Contract Documentation

## Supabase Integration

### Authentication
- **Apple Sign-In**: Behind feature flag, graceful degradation
- **Email/Magic Link**: Primary authentication method

### Core Tables
```sql
-- Users
users (id, email, display_name, avatar_url, created_at, updated_at)

-- Adventure Plans
adventure_plans (id, user_id, title, description, stops, status, created_at, updated_at)

-- Social Groups
social_groups (id, name, description, created_by, invite_code, qr_code, created_at, updated_at)

-- Scavenger Hunts
scavenger_hunts (id, title, description, created_by, group_id, status, start_time, end_time, created_at, updated_at)

-- Hunt Checkpoints
hunt_checkpoints (id, hunt_id, title, description, location, photo_required, points, order_index, created_at)

-- Checkpoint Submissions
checkpoint_submissions (id, checkpoint_id, user_id, photo_url, submitted_at, verified)
```

### Key Endpoints

#### Authentication
- `POST /auth/v1/signin/apple` - Apple Sign-In
- `POST /auth/v1/signin/email` - Email sign-in
- `POST /auth/v1/verify` - Verify magic link

#### Adventure Plans
- `POST /rest/v1/adventure_plans` - Create adventure
- `GET /rest/v1/adventure_plans?user_id=eq.{userId}` - Get user's adventures
- `PATCH /rest/v1/adventure_plans?id=eq.{id}` - Update adventure

#### Social Features
- `POST /rest/v1/social_groups` - Create group
- `POST /rest/v1/social_groups/join` - Join group by invite code
- `GET /rest/v1/social_groups/{id}/members` - Get group members

#### Scavenger Hunts
- `POST /rest/v1/scavenger_hunts` - Create hunt
- `POST /rest/v1/scavenger_hunts/{id}/join` - Join hunt
- `GET /rest/v1/scavenger_hunts/{id}/leaderboard` - Get leaderboard
- `POST /rest/v1/checkpoint_submissions` - Submit checkpoint

### Error Handling
```swift
struct APIError: Codable {
  let code: String
  let message: String
  let details: String?
}
```

### RLS Policies
- Users can only see their own data
- Adventure plans are private to user
- Social groups visible to members
- Hunts visible to group members

### Required Indexes
- `idx_adventure_plans_user_id`
- `idx_social_groups_invite_code`
- `idx_scavenger_hunts_group_id`
- `idx_hunt_checkpoints_hunt_id`
- `idx_checkpoint_submissions_user_checkpoint`