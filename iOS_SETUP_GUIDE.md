# iOS Setup Guide for Shvil

## 🚨 Current Issue
```
Command SwiftCompile failed with a nonzero exit code
No such module 'Supabase'
```

## ✅ Solution Steps

### Step 1: Open Xcode Project
```bash
open shvil.xcodeproj
```

### Step 2: Add Supabase Package (CRITICAL)
1. In Xcode, go to **File** → **Add Package Dependencies**
2. Enter URL: `https://github.com/supabase/supabase-swift`
3. Click **Add Package**
4. Select **Supabase** from the list
5. Click **Add Package**

### Step 3: Verify Project Structure
Make sure these files are in your Xcode project:
- ✅ `shvil/shvilApp.swift` (main app file)
- ✅ `shvil/ContentView.swift` (main view)
- ✅ `shvil/Shared/Services/Config.swift`
- ✅ `shvil/Shared/Services/SupabaseManager.swift`
- ✅ `shvil/Shared/Services/LocationService.swift`
- ✅ `shvil/Shared/Services/SupabaseTestView.swift`

### Step 4: Check Target Membership
1. Select each Swift file in Xcode
2. In the File Inspector, ensure "shvil" target is checked
3. All files should be included in the app target

### Step 5: Build and Test
1. Select an iOS Simulator (iPhone 15, iPhone 14, etc.)
2. Press **Cmd+R** to build and run
3. Should compile without errors

## 🔧 Alternative: Command Line Build
```bash
# Run the build script
./build_ios.sh
```

## 🚨 Troubleshooting

### If "No such module 'Supabase'" persists:
1. **Clean Build Folder**: Cmd+Shift+K
2. **Restart Xcode**
3. **Re-add Supabase package**
4. **Check Package Dependencies** in Project Navigator

### If files are missing from project:
1. **Right-click** on the project in Xcode
2. **Add Files to "shvil"**
3. **Select** the missing Swift files
4. **Ensure target membership** is checked

### If build still fails:
1. **Check iOS Deployment Target**: Should be 13.0+
2. **Check Swift Language Version**: Should be 5.0+
3. **Verify Bundle Identifier**: Should be unique

## 📱 iOS-Specific Configuration

### Info.plist Requirements:
- ✅ Location permissions configured
- ✅ Privacy manifest included
- ✅ Bundle identifier set

### Build Settings:
- ✅ iOS Deployment Target: 13.0+
- ✅ Swift Language Version: 5.0+
- ✅ Code Signing: Automatic

## 🎯 Expected Result

After successful setup:
- ✅ Project builds without errors
- ✅ App runs on iOS Simulator
- ✅ Supabase connection test works
- ✅ Location services functional

## 🚀 Next Steps

Once build is successful:
1. **Test Supabase connection** in the app
2. **Verify location permissions** work
3. **Proceed with authentication** implementation

---

**The key issue is adding the Supabase package to Xcode. Follow Step 2 carefully!**
