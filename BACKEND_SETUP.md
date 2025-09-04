# Shvil Backend Setup Guide

This guide will help you set up the backend infrastructure for the Shvil app.

## Prerequisites

- Node.js 18+ (for Supabase CLI)
- PostgreSQL 14+ (for local development)
- Supabase account
- OpenAI API key

## 1. Supabase Setup

### Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and create an account
2. Create a new project
3. Note down your project URL and anon key

### Set Up Environment Variables

Create a `.env` file in the project root:

```bash
cp environment.example .env
```

Edit `.env` with your actual values:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key-here
OPENAI_API_KEY=your-openai-api-key-here
```

### Deploy Database Schema

1. Install Supabase CLI:
```bash
npm install -g supabase
```

2. Login to Supabase:
```bash
supabase login
```

3. Link your project:
```bash
supabase link --project-ref your-project-id
```

4. Deploy the schema:
```bash
supabase db push
```

Or manually run the SQL from `supabase_schema.sql` in your Supabase dashboard.

## 2. Database Schema

The database includes the following main tables:

- **users**: User profiles and authentication
- **saved_places**: User's saved locations
- **friends**: Friend relationships
- **friend_locations**: Real-time location sharing
- **eta_shares**: ETA sharing functionality
- **group_trips**: Group trip planning
- **adventure_plans**: AI-generated adventure plans
- **safety_reports**: Community safety reports

## 3. Row Level Security (RLS)

All tables have RLS enabled with appropriate policies:

- Users can only access their own data
- Friends can see each other's locations
- Safety reports are public for community benefit
- Group trip data is shared among participants

## 4. Real-time Features

The app uses Supabase Realtime for:

- Live location sharing
- ETA updates
- Group trip coordination
- Safety alerts

## 5. Offline Support

The app includes comprehensive offline support:

- Local SQLite database for caching
- Sync queue for offline operations
- Automatic retry when connection is restored
- Graceful degradation of features

## 6. API Integration

### Supabase Services

- **Authentication**: User sign up/sign in
- **Database**: CRUD operations for all data
- **Realtime**: Live updates and notifications
- **Storage**: File uploads (future feature)

### OpenAI Integration

- **Adventure Generation**: AI-powered trip planning
- **Content Curation**: Venue recommendations
- **Safety Analysis**: Risk assessment

## 7. Development vs Production

### Development Mode

- Uses placeholder API keys
- Local SQLite database
- Mock data for testing
- Detailed logging

### Production Mode

- Real API keys from environment
- Supabase backend
- Production database
- Optimized performance

## 8. Testing the Backend

### 1. Test Database Connection

```swift
// In your app
let supabaseService = SupabaseService.shared
print("Connected: \(supabaseService.isConnected)")
```

### 2. Test Authentication

```swift
do {
    try await supabaseService.signUp(email: "test@example.com", password: "password123")
    print("Authentication working")
} catch {
    print("Auth error: \(error)")
}
```

### 3. Test Data Operations

```swift
let place = SavedPlace(
    id: UUID(),
    name: "Test Place",
    address: "123 Test St",
    latitude: 37.7749,
    longitude: -122.4194,
    type: .favorite,
    createdAt: Date(),
    userId: UUID()
)

try await supabaseService.savePlace(place)
```

## 9. Troubleshooting

### Common Issues

1. **Connection Failed**
   - Check your Supabase URL and key
   - Verify internet connection
   - Check Supabase project status

2. **Authentication Errors**
   - Verify email/password format
   - Check Supabase auth settings
   - Ensure RLS policies are correct

3. **Data Not Syncing**
   - Check offline mode status
   - Verify sync queue
   - Check network connectivity

### Debug Mode

Enable debug logging by setting `DEBUG=true` in your environment.

## 10. Security Considerations

- All API keys are stored securely
- RLS policies protect user data
- HTTPS enforced for all connections
- Regular security updates

## 11. Performance Optimization

- Database indexes for fast queries
- Connection pooling
- Caching for offline support
- Lazy loading of data

## 12. Monitoring

- Supabase dashboard for database metrics
- App analytics for usage patterns
- Error tracking and logging
- Performance monitoring

## Support

For issues with the backend setup:

1. Check the logs in Xcode console
2. Verify your Supabase configuration
3. Test with the provided examples
4. Check the Supabase documentation

## Next Steps

Once the backend is set up:

1. Test all API endpoints
2. Verify real-time functionality
3. Test offline mode
4. Deploy to production
5. Set up monitoring and alerts
