# Temporary Test Configuration

## ⚠️ IMPORTANT: This is for testing only - DO NOT COMMIT

### Step 1: Get Your Anon Key
1. Go to https://supabase.com/dashboard/project/lnniqqjaslpyljtcmkmf
2. Navigate to Settings → API
3. Copy the "anon public" key

### Step 2: Update Config.swift Temporarily
1. Open `shvil/Shared/Services/Config.swift`
2. Find this line:
   ```swift
   return "YOUR_ANON_KEY_HERE"
   ```
3. Replace with your actual anon key:
   ```swift
   return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." // Your actual key
   ```

### Step 3: Test Connection
1. Run the app in Xcode
2. Navigate to "Test Supabase Connection"
3. Tap "Test Connection"
4. You should see green "Connected" status

### Step 4: Revert Changes
1. Change the key back to placeholder:
   ```swift
   return "YOUR_ANON_KEY_HERE"
   ```
2. Save the file
3. **DO NOT COMMIT** the real key

## Expected Results

### ✅ Success:
- Connection Status: "Connected"
- Health Check: "3/3 services healthy"
- No error messages

### ❌ Failure:
- Connection Status: "Error: [message]"
- Health Check: "0/3 services healthy"
- Error details shown

## Troubleshooting

### Common Issues:
1. **Invalid API Key**: Double-check the anon key from dashboard
2. **Network Error**: Check internet connection
3. **Project Not Found**: Verify project ID is correct
4. **Permission Denied**: Ensure anon key has proper permissions

### Next Steps:
Once connection is verified, we can proceed with authentication implementation.
