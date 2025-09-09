#!/bin/bash

# Script to replace DesignTokens with Constants throughout the project
# Following Landmarks patterns for consistency

echo "🔄 Updating DesignTokens to Constants..."

# Find all Swift files and replace DesignTokens with Constants
find shvil -name "*.swift" -type f -exec sed -i '' 's/DesignTokens\.Spacing\.xs/Constants.spacingXS/g' {} \;
find shvil -name "*.swift" -type f -exec sed -i '' 's/DesignTokens\.Spacing\.sm/Constants.spacingSM/g' {} \;
find shvil -name "*.swift" -type f -exec sed -i '' 's/DesignTokens\.Spacing\.md/Constants.spacingMD/g' {} \;
find shvil -name "*.swift" -type f -exec sed -i '' 's/DesignTokens\.Spacing\.lg/Constants.spacingLG/g' {} \;
find shvil -name "*.swift" -type f -exec sed -i '' 's/DesignTokens\.Spacing\.xl/Constants.spacingXL/g' {} \;
find shvil -name "*.swift" -type f -exec sed -i '' 's/DesignTokens\.Spacing\.xxl/Constants.spacingXXL/g' {} \;
find shvil -name "*.swift" -type f -exec sed -i '' 's/DesignTokens\.Spacing\.xxxl/Constants.spacingXXXL/g' {} \;

# Replace corner radius
find shvil -name "*.swift" -type f -exec sed -i '' 's/DesignTokens\.CornerRadius\.xs/Constants.spacingXS/g' {} \;
find shvil -name "*.swift" -type f -exec sed -i '' 's/DesignTokens\.CornerRadius\.sm/Constants.spacingSM/g' {} \;
find shvil -name "*.swift" -type f -exec sed -i '' 's/DesignTokens\.CornerRadius\.md/Constants.spacingMD/g' {} \;
find shvil -name "*.swift" -type f -exec sed -i '' 's/DesignTokens\.CornerRadius\.lg/Constants.spacingLG/g' {} \;
find shvil -name "*.swift" -type f -exec sed -i '' 's/DesignTokens\.CornerRadius\.xl/Constants.cornerRadius/g' {} \;
find shvil -name "*.swift" -type f -exec sed -i '' 's/DesignTokens\.CornerRadius\.xxl/Constants.cornerRadius/g' {} \;

# Replace standard padding
find shvil -name "*.swift" -type f -exec sed -i '' 's/DesignTokens\.Spacing\.md/Constants.standardPadding/g' {} \;

echo "✅ Constants update complete!"
