#!/bin/bash

# iOS Build Script for Shvil
echo "🔨 Building Shvil for iOS..."

# Clean build folder
echo "🧹 Cleaning build folder..."
xcodebuild clean -scheme shvil

# Build for iOS Simulator
echo "📱 Building for iOS Simulator..."
xcodebuild build \
    -scheme shvil \
    -destination 'platform=iOS Simulator,name=Any iOS Simulator Device' \
    -configuration Debug

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "🚀 Ready to run on iOS Simulator"
else
    echo "❌ Build failed!"
    echo "🔍 Check the errors above"
    exit 1
fi
