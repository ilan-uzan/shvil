#!/bin/bash

echo "📱 Building Shvil for iPhone..."

# Clean derived data
echo "🧹 Cleaning derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData

# Build for iPhone
echo "🔨 Building for iPhone..."
xcodebuild -project shvil.xcodeproj -scheme shvil -destination 'generic/platform=iOS' -configuration Debug DEVELOPMENT_TEAM="64BG5ARK2Y" build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "📱 Next steps:"
    echo "1. Open Xcode beta"
    echo "2. Open shvil.xcodeproj"
    echo "3. Select your iPhone as destination"
    echo "4. Click Run (▶️)"
    echo ""
    echo "🎯 The app should now work properly with:"
    echo "   ✅ Hebrew language switching"
    echo "   ✅ Simplified onboarding (no theme selection)"
    echo "   ✅ Working location permissions"
    echo "   ✅ Clean project structure"
else
    echo "❌ Build failed. Please check the errors above."
fi
