# Shvil Configuration Guide

## 🔧 Environment Setup

### 1. Supabase Configuration

1. Create a new Supabase project at [supabase.com](https://supabase.com)
2. Get your project URL and anon key from the project settings
3. Add them to your Xcode project:

#### Option A: Info.plist (Recommended)
Add these keys to your `Info.plist`:
```xml
<key>SUPABASE_URL</key>
<string>https://your-project-ref.supabase.co</string>
<key>SUPABASE_ANON_KEY</key>
<string>your-anon-key-here</string>
```

#### Option B: Environment Variables
Set these environment variables in your Xcode scheme:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

### 2. Database Setup

1. Run the setup script in your Supabase SQL editor:
   ```sql
   -- Copy and paste the contents of supabase/setup.sql
   ```

2. Or use the Supabase CLI:
   ```bash
   supabase init
   supabase start
   supabase db reset
   ```

### 3. OpenAI Configuration (Optional)

For AI-powered features, add your OpenAI API key:

#### Option A: Info.plist
```xml
<key>OPENAI_API_KEY</key>
<string>your-openai-api-key-here</string>
```

#### Option B: Environment Variables
- `OPENAI_API_KEY`

### 4. Xcode Configuration

1. Open `shvil.xcodeproj` in Xcode
2. Select your target
3. Go to Build Settings
4. Add the following User-Defined settings:
   - `SUPABASE_URL` = `$(SUPABASE_URL)`
   - `SUPABASE_ANON_KEY` = `$(SUPABASE_ANON_KEY)`
   - `OPENAI_API_KEY` = `$(OPENAI_API_KEY)`

### 5. Verification

The app will automatically detect if Supabase is properly configured:
- ✅ Green indicator: Connected to Supabase
- ⚠️ Yellow indicator: Demo mode (configuration needed)
- ❌ Red indicator: Configuration error

## 🚀 Development Workflow

### Local Development
1. Start Supabase locally:
   ```bash
   supabase start
   ```

2. Run the app in Xcode
3. The app will connect to your local Supabase instance

### Production Deployment
1. Deploy your schema to production Supabase
2. Update environment variables for production
3. Build and deploy your app

## 🔒 Security Notes

- Never commit API keys to version control
- Use environment variables or secure key management
- Rotate keys regularly
- Use Row Level Security (RLS) policies in Supabase

## 📱 Testing

The app includes demo mode for testing without a Supabase connection:
- All features work with mock data
- No network requests are made
- Perfect for UI testing and development

## 🆘 Troubleshooting

### Common Issues

1. **"Supabase not configured" error**
   - Check that your environment variables are set correctly
   - Verify the Supabase URL and key are valid

2. **Database connection errors**
   - Ensure your Supabase project is running
   - Check that the schema has been applied
   - Verify RLS policies are set up correctly

3. **Build errors**
   - Clean build folder (Cmd+Shift+K)
   - Reset package caches
   - Check that all dependencies are installed

### Getting Help

- Check the [Supabase Documentation](https://supabase.com/docs)
- Review the app logs for specific error messages
- Open an issue in this repository
