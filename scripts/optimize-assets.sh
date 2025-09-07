#!/bin/bash

# Asset Optimization Script for Shvil
# This script optimizes assets for better performance and smaller bundle size

echo "🎨 Shvil Asset Optimization"
echo "============================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
TOTAL_ASSETS=0
OPTIMIZED_ASSETS=0
CONVERTED_ASSETS=0
REMOVED_ASSETS=0

echo "📁 Analyzing assets..."

# Check Assets.xcassets
if [[ -d "shvil/Assets.xcassets" ]]; then
    echo "Found Assets.xcassets directory"
    
    # Count total assets
    TOTAL_ASSETS=$(find shvil/Assets.xcassets -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" | wc -l)
    echo -e "Total image assets: ${GREEN}$TOTAL_ASSETS${NC}"
    
    # Check for PNG files that could be converted to PDF
    echo ""
    echo "🔍 Checking for PNG files that could be converted to PDF..."
    find shvil/Assets.xcassets -name "*.png" | while read -r file; do
        filename=$(basename "$file" .png)
        echo -e "${YELLOW}⚠️  Consider converting to PDF: $file${NC}"
        echo -e "   Use: File → Export → PDF for vector graphics"
        CONVERTED_ASSETS=$((CONVERTED_ASSETS + 1))
    done
    
    # Check for oversized images
    echo ""
    echo "📏 Checking for oversized images..."
    find shvil/Assets.xcassets -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" | while read -r file; do
        size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
        if [[ $size -gt 100000 ]]; then # 100KB
            echo -e "${YELLOW}⚠️  Large image file: $file (${size} bytes)${NC}"
            echo -e "   Consider optimizing or using smaller resolution"
        fi
    done
    
    # Check for missing dark mode variants
    echo ""
    echo "🌙 Checking for missing dark mode variants..."
    find shvil/Assets.xcassets -name "*.colorset" | while read -r colorset; do
        if [[ ! -d "$colorset/dark" ]]; then
            echo -e "${YELLOW}⚠️  Missing dark mode variant: $colorset${NC}"
        fi
    done
    
    # Check for unused assets
    echo ""
    echo "🗑️  Checking for potentially unused assets..."
    find shvil/Assets.xcassets -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" | while read -r file; do
        filename=$(basename "$file" .png | sed 's/\.jpg$//' | sed 's/\.jpeg$//')
        if ! grep -r "$filename" shvil --include="*.swift" > /dev/null 2>&1; then
            echo -e "${YELLOW}⚠️  Potentially unused asset: $file${NC}"
            REMOVED_ASSETS=$((REMOVED_ASSETS + 1))
        fi
    done
else
    echo -e "${RED}❌ Assets.xcassets directory not found${NC}"
fi

echo ""
echo "🔧 Optimization recommendations..."

# Check if SF Symbols are being used
echo "Checking SF Symbols usage..."
if grep -r "Image(systemName:" shvil --include="*.swift" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ SF Symbols are being used${NC}"
else
    echo -e "${YELLOW}⚠️  Consider using SF Symbols for simple icons${NC}"
fi

# Check for hardcoded image names
echo "Checking for hardcoded image references..."
if grep -r "Image(\"" shvil --include="*.swift" > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Hardcoded image references found${NC}"
    echo -e "   Consider using Asset Catalog references"
fi

# Check for missing @2x and @3x variants
echo "Checking for missing resolution variants..."
find shvil/Assets.xcassets -name "*.png" | while read -r file; do
    filename=$(basename "$file" .png)
    dirname=$(dirname "$file")
    
    if [[ ! -f "$dirname/$filename@2x.png" ]] && [[ ! -f "$dirname/$filename@3x.png" ]]; then
        echo -e "${YELLOW}⚠️  Missing @2x/@3x variants: $file${NC}"
    fi
done

echo ""
echo "📊 Asset Optimization Summary"
echo "============================="
echo -e "Total assets: ${GREEN}$TOTAL_ASSETS${NC}"
echo -e "Assets to convert: ${YELLOW}$CONVERTED_ASSETS${NC}"
echo -e "Potentially unused: ${YELLOW}$REMOVED_ASSETS${NC}"

echo ""
echo "💡 Optimization Tips"
echo "==================="
echo "1. Convert simple graphics to PDF vectors"
echo "2. Use SF Symbols for icons when possible"
echo "3. Optimize images for target resolution"
echo "4. Add dark mode variants for colors"
echo "5. Remove unused assets"
echo "6. Use Asset Catalog for all images"
echo "7. Consider using WebP for complex images"

if [[ $TOTAL_ASSETS -gt 0 ]]; then
    echo -e "\n${GREEN}✅ Asset analysis complete!${NC}"
    exit 0
else
    echo -e "\n${YELLOW}⚠️  No assets found to optimize${NC}"
    exit 1
fi
