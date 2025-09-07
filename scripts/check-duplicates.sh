#!/bin/bash

# Duplicate Code Detection Script for Shvil
# This script identifies duplicate code patterns in the Swift codebase

echo "🔍 Shvil Duplicate Code Detection"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
DUPLICATE_FUNCTIONS=0
DUPLICATE_PATTERNS=0
SIMILAR_FILES=0

echo "🔧 Checking for duplicate functions..."

# Find all Swift files
find shvil -name "*.swift" -type f | while read -r file1; do
    # Extract function names from file1
    grep -n "func " "$file1" | while read -r line1; do
        func_name1=$(echo "$line1" | sed -n 's/.*func \([a-zA-Z_][a-zA-Z0-9_]*\).*/\1/p')
        if [[ -n "$func_name1" ]]; then
            # Check if same function exists in other files
            find shvil -name "*.swift" -type f | while read -r file2; do
                if [[ "$file1" != "$file2" ]]; then
                    if grep -q "func $func_name1" "$file2"; then
                        echo -e "${YELLOW}⚠️  Duplicate function '$func_name1' found in:${NC}"
                        echo -e "   ${file1}"
                        echo -e "   ${file2}"
                        DUPLICATE_FUNCTIONS=$((DUPLICATE_FUNCTIONS + 1))
                    fi
                fi
            done
        fi
    done
done

echo ""
echo "📝 Checking for duplicate code patterns..."

# Check for common duplicate patterns
echo "Checking for duplicate error handling patterns..."
if grep -r "catch.*Error" shvil --include="*.swift" | wc -l | grep -q "2"; then
    echo -e "${YELLOW}⚠️  Multiple error handling patterns found${NC}"
    DUPLICATE_PATTERNS=$((DUPLICATE_PATTERNS + 1))
fi

echo "Checking for duplicate UI patterns..."
if grep -r "VStack\|HStack\|ZStack" shvil --include="*.swift" | wc -l | grep -q "10"; then
    echo -e "${YELLOW}⚠️  Multiple similar UI patterns found${NC}"
    DUPLICATE_PATTERNS=$((DUPLICATE_PATTERNS + 1))
fi

echo "Checking for duplicate color definitions..."
if grep -r "Color\." shvil --include="*.swift" | wc -l | grep -q "20"; then
    echo -e "${YELLOW}⚠️  Multiple hardcoded color definitions found${NC}"
    DUPLICATE_PATTERNS=$((DUPLICATE_PATTERNS + 1))
fi

echo "Checking for duplicate spacing values..."
if grep -r "padding\|spacing" shvil --include="*.swift" | wc -l | grep -q "15"; then
    echo -e "${YELLOW}⚠️  Multiple hardcoded spacing values found${NC}"
    DUPLICATE_PATTERNS=$((DUPLICATE_PATTERNS + 1))
fi

echo ""
echo "📁 Checking for similar files..."

# Check for files with similar content
find shvil -name "*.swift" -type f | while read -r file1; do
    find shvil -name "*.swift" -type f | while read -r file2; do
        if [[ "$file1" != "$file2" ]]; then
            # Compare file sizes and content similarity
            size1=$(wc -c < "$file1")
            size2=$(wc -c < "$file2")
            
            # If files are similar in size, check content similarity
            if [[ $((size1 - size2)) -lt 100 ]] && [[ $((size2 - size1)) -lt 100 ]]; then
                # Use diff to check similarity (simplified)
                if diff -q "$file1" "$file2" > /dev/null 2>&1; then
                    echo -e "${RED}❌ Identical files found:${NC}"
                    echo -e "   ${file1}"
                    echo -e "   ${file2}"
                    SIMILAR_FILES=$((SIMILAR_FILES + 1))
                fi
            fi
        fi
    done
done

echo ""
echo "🎯 Duplicate Code Summary"
echo "========================"
echo -e "Duplicate functions: ${YELLOW}$DUPLICATE_FUNCTIONS${NC}"
echo -e "Duplicate patterns: ${YELLOW}$DUPLICATE_PATTERNS${NC}"
echo -e "Similar files: ${YELLOW}$SIMILAR_FILES${NC}"

if [[ $DUPLICATE_FUNCTIONS -eq 0 ]] && [[ $DUPLICATE_PATTERNS -eq 0 ]] && [[ $SIMILAR_FILES -eq 0 ]]; then
    echo -e "\n${GREEN}✅ No duplicate code detected!${NC}"
    exit 0
else
    echo -e "\n${YELLOW}⚠️  Duplicate code detected. Consider refactoring.${NC}"
    exit 1
fi
