#!/bin/bash

# Script to fix all import statements after project restructure
echo "🔧 Fixing import statements..."

# Fix DesignTokens imports - they're now in Views/Modifiers/Theme.swift
find shvil -name "*.swift" -type f -exec sed -i '' 's/import.*DesignTokens//g' {} \;

# Fix DependencyContainer imports - it's now in App/
find shvil -name "*.swift" -type f -exec sed -i '' 's/import.*DependencyContainer//g' {} \;

# Fix UnifiedLocationManager imports - it's now in Services/
find shvil -name "*.swift" -type f -exec sed -i '' 's/import.*UnifiedLocationManager//g' {} \;

# Fix Constants imports - it's now in Model/
find shvil -name "*.swift" -type f -exec sed -i '' 's/import.*Constants//g' {} \;

# Fix FlexibleHeader imports - it's now in Views/Modifiers/
find shvil -name "*.swift" -type f -exec sed -i '' 's/import.*FlexibleHeader//g' {} \;

# Fix ReadabilityOverlay imports - it's now in Views/Components/
find shvil -name "*.swift" -type f -exec sed -i '' 's/import.*ReadabilityOverlay//g' {} \;

echo "✅ Import fixes complete!"
