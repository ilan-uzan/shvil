# Social Features Specification

Lightweight social features for Shvil Minimal, designed with privacy-first principles and temporary, opt-in interactions.

## 🔐 Privacy Principles

- **Opt-in by Default**: All social features are disabled by default
- **Temporary**: All social data expires automatically
- **Revocable**: Users can stop sharing at any time
- **Transparent**: Clear disclosure of what data is shared and for how long
- **Local First**: Location data stays on-device unless explicitly shared

## 📡 Share ETA Feature

### Overview
Allow users to share their estimated arrival time with friends and family through temporary, revocable live sessions.

### User Flow
1. User starts navigation to a destination
2. Bottom sheet shows "Share ETA" option
3. User taps to create a temporary trip session
4. App generates shareable link (deep-link + web fallback)
5. Recipients can view live ETA updates
6. Session auto-expires on arrival or manual stop

### Data Model
```typescript
interface TripSession {
  id: string;                    // UUID for the session
  userId: string;                // Supabase user ID
  startTime: timestamp;          // When navigation started
  estimatedArrival: timestamp;   // ETA at destination
  destination: {
    name: string;
    coordinate: {
      latitude: number;
      longitude: number;
    };
  };
  currentLocation?: {
    latitude: number;
    longitude: number;
    timestamp: timestamp;
  };
  status: 'active' | 'completed' | 'cancelled';
  expiresAt: timestamp;          // Auto-expiry time
}
```

### Technical Implementation
- **Backend**: Supabase Realtime for live updates
- **Auth**: Email/OTP authentication for MVP
- **Sharing**: Deep-link with web fallback
- **Updates**: Position updates every 30-60 seconds
- **Expiry**: Auto-expire after 4 hours or on arrival

### Privacy Controls
- Clear privacy sheet before first use
- "Stop Sharing" button in navigation bottom bar
- Session expires automatically on arrival
- No persistent location history stored

## 👥 Friends on Map

### Overview
Optional feature allowing users to see friends' approximate locations on the map with mutual consent.

### User Flow
1. User enables "Friends on Map" in settings
2. Privacy sheet explains data sharing
3. User can invite friends or accept invitations
4. Mutual consent required before showing locations
5. Friends appear as liquid drops with soft pulse
6. Coarse accuracy unless both opt-in to "Group Trip"

### Data Model
```typescript
interface FriendPresence {
  userId: string;
  displayName: string;
  location: {
    latitude: number;
    longitude: number;
    accuracy: 'coarse' | 'precise';
    timestamp: timestamp;
  };
  status: 'online' | 'offline' | 'away';
  lastSeen: timestamp;
}

interface Friendship {
  id: string;
  requesterId: string;
  recipientId: string;
  status: 'pending' | 'accepted' | 'declined' | 'blocked';
  createdAt: timestamp;
  updatedAt: timestamp;
}
```

### Privacy Levels
- **Coarse**: City-level accuracy (default)
- **Precise**: Street-level accuracy (requires Group Trip consent)
- **Offline**: No location sharing

### Technical Implementation
- **Presence**: Supabase Realtime for live updates
- **Accuracy**: Configurable precision levels
- **Updates**: 1-5 minute cadence for coarse, 30 seconds for precise
- **Expiry**: Presence expires after 10 minutes of inactivity

## 🎭 Quick Reactions

### Overview
Ephemeral reaction system for social interaction during navigation - fire-and-forget with automatic expiry.

### Available Reactions
- 👋 **Wave**: Friendly greeting
- 🚗💨 **Speed**: "I'm in a hurry" or "Catch up!"
- 🍕 **Food**: "Let's grab food" or "I'm hungry"

### User Flow
1. User is in an active trip session with friends
2. Quick reactions panel appears in navigation
3. User taps a reaction
4. Reaction appears as subtle ripple on recipient's screen
5. Reaction auto-expires after 2 minutes
6. No persistent storage of reactions

### Data Model
```typescript
interface QuickReaction {
  id: string;                    // Temporary UUID
  senderId: string;              // User who sent reaction
  recipientId: string;           // User who receives reaction
  reactionType: 'wave' | 'speed' | 'food';
  timestamp: timestamp;          // When sent
  expiresAt: timestamp;          // Auto-expiry (2 minutes)
  tripSessionId: string;         // Associated trip session
}
```

### Technical Implementation
- **Transport**: Supabase Realtime channels
- **Expiry**: Automatic cleanup after 2 minutes
- **UI**: Subtle ripple animation on recipient device
- **Storage**: No persistent storage, memory only

## 🔄 Data Lifecycle

### Session Management
- **Creation**: When user starts sharing ETA
- **Updates**: Live position updates every 30-60 seconds
- **Expiry**: Automatic after 4 hours or on arrival
- **Cleanup**: All data deleted after expiry

### Presence Management
- **Start**: When user enables Friends on Map
- **Updates**: Location updates every 1-5 minutes
- **Expiry**: After 10 minutes of inactivity
- **Cleanup**: Presence data deleted after expiry

### Reaction Management
- **Send**: Immediate delivery via Realtime
- **Display**: 2-minute display duration
- **Expiry**: Automatic cleanup after 2 minutes
- **Storage**: No persistent storage

## 🛡️ Privacy Controls

### Global Settings
- **Master Kill Switch**: Disable all social features instantly
- **Privacy Dashboard**: Overview of all active sessions
- **Data Deletion**: One-tap deletion of all social data

### Per-Feature Controls
- **Share ETA**: Enable/disable with clear disclosure
- **Friends on Map**: Mutual consent required
- **Quick Reactions**: Opt-in for each trip session
- **Location Accuracy**: Coarse vs. precise control

### Transparency
- **Privacy Sheet**: Clear explanation before first use
- **Data Usage**: What data is shared and for how long
- **Third Parties**: No data shared with third parties
- **Retention**: Clear data retention policies

## 🔧 Technical Architecture

### Supabase Integration
- **Auth**: Email/OTP authentication
- **Database**: PostgreSQL for session metadata
- **Realtime**: WebSocket connections for live updates
- **Storage**: No file storage required

### Client Implementation
- **State Management**: Combine publishers for reactive updates
- **Background**: Location updates in background mode
- **Offline**: Queue updates when offline, flush on reconnect
- **Security**: End-to-end encryption for sensitive data

### API Endpoints
- `POST /api/trip-sessions` - Create new trip session
- `PUT /api/trip-sessions/:id` - Update trip session
- `DELETE /api/trip-sessions/:id` - End trip session
- `POST /api/friendships` - Send friend request
- `PUT /api/friendships/:id` - Accept/decline friend request
- `POST /api/reactions` - Send quick reaction

## 🧪 Testing Scenarios

### Share ETA
1. Start navigation → Share ETA → Verify link generation
2. Share link with friend → Verify recipient can see live updates
3. Arrive at destination → Verify session auto-expires
4. Stop sharing manually → Verify session ends immediately

### Friends on Map
1. Enable Friends on Map → Verify privacy sheet shown
2. Send friend request → Verify mutual consent required
3. Accept friend request → Verify friend appears on map
4. Disable feature → Verify friend disappears from map

### Quick Reactions
1. Start shared trip → Verify reactions panel appears
2. Send reaction → Verify recipient sees ripple animation
3. Wait 2 minutes → Verify reaction disappears
4. End trip → Verify reactions panel disappears

## 📊 Analytics (Opt-in)

### Metrics Collected
- Feature adoption rates (anonymized)
- Session duration (aggregated)
- Error rates and crash reports
- Performance metrics

### Data Privacy
- No precise location in analytics
- Coarse grid only if explicitly allowed
- Anonymous user IDs only
- Clear opt-in consent required

---

*This specification ensures social features enhance the navigation experience while maintaining the highest privacy standards.*
