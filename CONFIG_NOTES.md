# Configuration Notes

## Supabase Configuration

### Environment Variables
To connect to a real Supabase backend, set these environment variables:

```bash
export SUPABASE_URL="your-supabase-url"
export SUPABASE_ANON_KEY="your-supabase-anon-key"
```

### Current Status
- **Mode**: Demo mode (no real backend connection)
- **URL**: `https://demo.supabase.co` (placeholder)
- **Key**: `demo-key` (placeholder)

### Switching to Production
1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Get your project URL and anon key from the project settings
3. Set the environment variables in your development environment
4. The app will automatically detect the configuration and switch to production mode

## Location Services

### Required Permissions
The following permissions are configured in the app's Info.plist:

- `NSLocationWhenInUseUsageDescription`: "Shvil needs location access to show your current position on the map and provide navigation services."
- `NSLocationAlwaysAndWhenInUseUsageDescription`: "Shvil needs location access to provide navigation services and track your route."

### Location Manager
- **Service**: `LocationManager` (unified service)
- **Thread Safety**: All location updates happen on the main thread
- **Fallback**: Demo region (Israel) when location is denied
- **Authorization**: Handles all permission states gracefully

## Map Configuration

### MapKit Setup
- **Framework**: MapKit (native iOS)
- **Region**: Defaults to Israel (31.7683, 35.2137)
- **Fallback**: Demo region when location is unavailable
- **Annotations**: Currently disabled to prevent rendering errors

### Map Styles
- Standard
- Satellite
- Hybrid
- 3D
- 2D

## Development Notes

### Simulator Setup
1. **Location Services**: Must be enabled in Simulator → Features → Location
2. **Location Setting**: Should not be set to "None"
3. **Recommended**: Use "Apple" or "Freeway Drive" for testing
4. **GPX Routes**: Can be used for custom location testing

### Debugging
- **Logs**: Check console for location permission status
- **Error States**: App shows proper error UI when location is denied
- **Demo Mode**: App falls back to demo region when location is unavailable

## API Keys

### OpenAI (Optional)
- **Status**: Not configured (ignored in demo mode)
- **Usage**: AI-powered adventure generation
- **Configuration**: Set `OPENAI_API_KEY` environment variable

### Third-Party Services
- **Mapbox**: Not used (using native MapKit)
- **Google Maps**: Not used (using native MapKit)
- **Other**: No additional API keys required

## Security Notes

- All API keys should be stored as environment variables
- Never commit API keys to version control
- Use different keys for development and production
- Rotate keys regularly for security
