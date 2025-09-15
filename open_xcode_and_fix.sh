#!/bin/bash

echo "📱 Opening Xcode and fixing package dependencies..."

# Clean derived data
echo "🧹 Cleaning derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Caches/org.swift.swiftpm

# Open Xcode
echo "🔧 Opening Xcode..."
open shvil.xcodeproj

echo "✅ Xcode opened!"
echo ""
echo "📋 Manual steps to fix packages:"
echo "1. Wait for Xcode to fully load"
echo "2. Go to File → Packages → Reset Package Caches"
echo "3. Go to File → Packages → Resolve Package Versions"
echo "4. Wait for packages to resolve"
echo "5. Select your iPhone as destination"
echo "6. Click Run (▶️)"
echo ""
echo "🎯 This should fix all the missing package product errors!"
