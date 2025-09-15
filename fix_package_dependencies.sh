#!/bin/bash

echo "🔧 Fixing package dependencies..."

# Clean everything
echo "🧹 Cleaning derived data and caches..."
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/Developer/Xcode/UserData/IDESwiftPackageProductCache

# Remove the problematic xctest-dynamic-overlay from Package.resolved
echo "🔧 Removing problematic xctest-dynamic-overlay dependency..."
if [ -f "shvil.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" ]; then
    # Create a backup
    cp shvil.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved shvil.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved.backup
    
    # Remove xctest-dynamic-overlay from Package.resolved
    python3 -c "
import json
import sys

# Read the Package.resolved file
with open('shvil.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved', 'r') as f:
    data = json.load(f)

# Filter out xctest-dynamic-overlay
data['pins'] = [pin for pin in data['pins'] if pin['identity'] != 'xctest-dynamic-overlay']

# Write back the cleaned file
with open('shvil.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved', 'w') as f:
    json.dump(data, f, indent=2)

print('✅ Removed xctest-dynamic-overlay from Package.resolved')
"
else
    echo "❌ Package.resolved not found"
    exit 1
fi

echo "✅ Package dependencies fixed!"
echo ""
echo "📱 Next steps:"
echo "1. Open Xcode beta"
echo "2. Open shvil.xcodeproj"
echo "3. Go to File → Packages → Reset Package Caches"
echo "4. Go to File → Packages → Resolve Package Versions"
echo "5. Build for your iPhone"
echo ""
echo "🎯 This should resolve all the missing package product errors!"
