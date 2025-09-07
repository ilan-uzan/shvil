#!/bin/bash

# Script to migrate AppleColors to DesignTokens in Swift files
# Usage: ./scripts/migrate-apple-colors.sh

echo "Starting AppleColors to DesignTokens migration..."

# Find all Swift files that contain AppleColors
files=$(find shvil -name "*.swift" -type f -exec grep -l "AppleColors\|AppleSpacing\|AppleTypography\|AppleCornerRadius\|AppleShadows\|AppleAnimations" {} \;)

for file in $files; do
    echo "Migrating $file..."
    
    # Create backup
    cp "$file" "$file.backup"
    
    # Replace AppleColors with DesignTokens
    sed -i '' 's/AppleColors\.background/DesignTokens.Surface.background/g' "$file"
    sed -i '' 's/AppleColors\.textPrimary/DesignTokens.Text.primary/g' "$file"
    sed -i '' 's/AppleColors\.textSecondary/DesignTokens.Text.secondary/g' "$file"
    sed -i '' 's/AppleColors\.textTertiary/DesignTokens.Text.tertiary/g' "$file"
    sed -i '' 's/AppleColors\.brandPrimary/DesignTokens.Brand.primary/g' "$file"
    sed -i '' 's/AppleColors\.surfaceSecondary/DesignTokens.Surface.secondary/g' "$file"
    sed -i '' 's/AppleColors\.surfaceTertiary/DesignTokens.Surface.tertiary/g' "$file"
    sed -i '' 's/AppleColors\.glassLight/DesignTokens.Glass.light/g' "$file"
    sed -i '' 's/AppleColors\.glassMedium/DesignTokens.Glass.medium/g' "$file"
    sed -i '' 's/AppleColors\.glassInnerHighlight/DesignTokens.Glass.innerHighlight/g' "$file"
    
    # Replace AppleSpacing with DesignTokens.Spacing
    sed -i '' 's/AppleSpacing\.xs/DesignTokens.Spacing.xs/g' "$file"
    sed -i '' 's/AppleSpacing\.sm/DesignTokens.Spacing.sm/g' "$file"
    sed -i '' 's/AppleSpacing\.md/DesignTokens.Spacing.md/g' "$file"
    sed -i '' 's/AppleSpacing\.lg/DesignTokens.Spacing.lg/g' "$file"
    sed -i '' 's/AppleSpacing\.xl/DesignTokens.Spacing.xl/g' "$file"
    
    # Replace AppleTypography with DesignTokens.Typography
    sed -i '' 's/AppleTypography\.caption1/DesignTokens.Typography.caption1/g' "$file"
    sed -i '' 's/AppleTypography\.body/DesignTokens.Typography.body/g' "$file"
    sed -i '' 's/AppleTypography\.bodyEmphasized/DesignTokens.Typography.bodyEmphasized/g' "$file"
    sed -i '' 's/AppleTypography\.title/DesignTokens.Typography.title/g' "$file"
    sed -i '' 's/AppleTypography\.title1/DesignTokens.Typography.title/g' "$file"
    sed -i '' 's/AppleTypography\.title3/DesignTokens.Typography.title3/g' "$file"
    sed -i '' 's/AppleTypography\.headline/DesignTokens.Typography.headline/g' "$file"
    
    # Replace AppleCornerRadius with DesignTokens.CornerRadius
    sed -i '' 's/AppleCornerRadius\.sm/DesignTokens.CornerRadius.sm/g' "$file"
    sed -i '' 's/AppleCornerRadius\.md/DesignTokens.CornerRadius.md/g' "$file"
    sed -i '' 's/AppleCornerRadius\.lg/DesignTokens.CornerRadius.lg/g' "$file"
    sed -i '' 's/AppleCornerRadius\.xl/DesignTokens.CornerRadius.xl/g' "$file"
    
    # Replace AppleShadows with DesignTokens.Shadow
    sed -i '' 's/AppleShadows\.light/DesignTokens.Shadow.light/g' "$file"
    sed -i '' 's/AppleShadows\.medium/DesignTokens.Shadow.medium/g' "$file"
    sed -i '' 's/AppleShadows\.heavy/DesignTokens.Shadow.heavy/g' "$file"
    
    # Replace AppleAnimations with DesignTokens.Animation
    sed -i '' 's/AppleAnimations\.spring/DesignTokens.Animation.spring/g' "$file"
    sed -i '' 's/AppleAnimations\.standard/DesignTokens.Animation.standard/g' "$file"
    
    echo "Completed $file"
done

echo "Migration completed! Backup files created with .backup extension."
echo "Please review the changes and test the app before removing backup files."
