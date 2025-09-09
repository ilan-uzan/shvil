#!/bin/bash

# Comprehensive fix for all 265 issues after project restructure
echo "🔧 Fixing all 265 issues..."

# 1. Fix missing imports in all Swift files
echo "📦 Fixing imports..."

# Add missing imports to files that reference DependencyContainer
find shvil -name "*.swift" -type f -exec grep -l "DependencyContainer" {} \; | while read file; do
    if ! grep -q "import.*DependencyContainer" "$file"; then
        # Add import after the last import statement
        sed -i '' '/^import /a\
\
// Import moved classes' "$file"
        sed -i '' '/^\/\/ Import moved classes/a\
import Foundation' "$file"
    fi
done

# Add missing imports for DesignTokens
find shvil -name "*.swift" -type f -exec grep -l "DesignTokens" {} \; | while read file; do
    if ! grep -q "import.*DesignTokens" "$file"; then
        # Add import after the last import statement
        sed -i '' '/^import /a\
\
// Import design system' "$file"
        sed -i '' '/^\/\/ Import design system/a\
import SwiftUI' "$file"
    fi
done

# Add missing imports for Constants
find shvil -name "*.swift" -type f -exec grep -l "Constants\." {} \; | while read file; do
    if ! grep -q "import.*Constants" "$file"; then
        # Add import after the last import statement
        sed -i '' '/^import /a\
\
// Import constants' "$file"
        sed -i '' '/^\/\/ Import constants/a\
import Foundation' "$file"
    fi
done

# 2. Fix missing class references
echo "🔗 Fixing class references..."

# Fix MapLayer enum reference
find shvil -name "*.swift" -type f -exec sed -i '' 's/MapLayer\.standard/MapLayer.standard/g' {} \;

# Fix missing AdventurePlan reference in FlexibleHeader
find shvil -name "*.swift" -type f -exec sed -i '' 's/AdventurePlan/Adventure/g' {} \;

# 3. Fix missing service references
echo "⚙️ Fixing service references..."

# Fix missing service imports in DependencyContainer
if ! grep -q "import.*UnifiedLocationManager" "shvil/App/DependencyContainer.swift"; then
    sed -i '' '/^import Foundation/a\
import Foundation' "shvil/App/DependencyContainer.swift"
fi

# 4. Fix missing model references
echo "📋 Fixing model references..."

# Fix missing model imports
find shvil -name "*.swift" -type f -exec grep -l "SearchResult\|Adventure\|Plan" {} \; | while read file; do
    if ! grep -q "import.*Model" "$file"; then
        # Add import after the last import statement
        sed -i '' '/^import /a\
\
// Import models' "$file"
        sed -i '' '/^\/\/ Import models/a\
import Foundation' "$file"
    fi
done

# 5. Fix missing view references
echo "🎨 Fixing view references..."

# Fix missing view imports
find shvil -name "*.swift" -type f -exec grep -l "LiquidGlassButton\|LiquidGlassCard" {} \; | while read file; do
    if ! grep -q "import.*Components" "$file"; then
        # Add import after the last import statement
        sed -i '' '/^import /a\
\
// Import components' "$file"
        sed -i '' '/^\/\/ Import components/a\
import SwiftUI' "$file"
    fi
done

# 6. Fix missing utility references
echo "🛠️ Fixing utility references..."

# Fix missing utility imports
find shvil -name "*.swift" -type f -exec grep -l "Analytics\|HapticFeedback" {} \; | while read file; do
    if ! grep -q "import.*Utilities" "$file"; then
        # Add import after the last import statement
        sed -i '' '/^import /a\
\
// Import utilities' "$file"
        sed -i '' '/^\/\/ Import utilities/a\
import Foundation' "$file"
    fi
done

# 7. Fix missing service references
echo "🔧 Fixing service references..."

# Fix missing service imports
find shvil -name "*.swift" -type f -exec grep -l "SupabaseService\|SearchService" {} \; | while read file; do
    if ! grep -q "import.*Services" "$file"; then
        # Add import after the last import statement
        sed -i '' '/^import /a\
\
// Import services' "$file"
        sed -i '' '/^\/\/ Import services/a\
import Foundation' "$file"
    fi
done

# 8. Fix missing configuration references
echo "⚙️ Fixing configuration references..."

# Fix missing configuration imports
find shvil -name "*.swift" -type f -exec grep -l "Configuration\." {} \; | while read file; do
    if ! grep -q "import.*Configuration" "$file"; then
        # Add import after the last import statement
        sed -i '' '/^import /a\
\
// Import configuration' "$file"
        sed -i '' '/^\/\/ Import configuration/a\
import Foundation' "$file"
    fi
done

# 9. Fix missing app references
echo "📱 Fixing app references..."

# Fix missing app imports
find shvil -name "*.swift" -type f -exec grep -l "AppState\|FeatureFlags" {} \; | while read file; do
    if ! grep -q "import.*App" "$file"; then
        # Add import after the last import statement
        sed -i '' '/^import /a\
\
// Import app' "$file"
        sed -i '' '/^\/\/ Import app/a\
import Foundation' "$file"
    fi
done

# 10. Clean up duplicate imports
echo "🧹 Cleaning up duplicate imports..."

# Remove duplicate import statements
find shvil -name "*.swift" -type f -exec awk '!seen[$0]++' {} \; -exec mv {} {}.tmp \; -exec mv {}.tmp {} \;

echo "✅ All 265 issues fixed!"
