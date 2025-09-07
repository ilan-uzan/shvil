#!/bin/bash

# Dead Code Detection Script for Shvil
# This script identifies potentially unused code in the Swift codebase

echo "🔍 Shvil Dead Code Detection"
echo "=============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
TOTAL_FILES=0
UNUSED_FILES=0
UNUSED_FUNCTIONS=0
UNUSED_VARIABLES=0

echo "📁 Checking for unused files..."

# Find all Swift files
find shvil -name "*.swift" -type f | while read -r file; do
    TOTAL_FILES=$((TOTAL_FILES + 1))
    
    # Get filename without path and extension
    filename=$(basename "$file" .swift)
    
    # Skip test files and main app file
    if [[ "$filename" == *"Test"* ]] || [[ "$filename" == "shvilApp" ]]; then
        continue
    fi
    
    # Check if file is imported anywhere
    if ! grep -r "import.*$filename" shvil --include="*.swift" | grep -v "$file" > /dev/null 2>&1; then
        # Check if it's a main file (ContentView, AppState, etc.)
        if [[ "$filename" != "ContentView" ]] && [[ "$filename" != "AppState" ]] && [[ "$filename" != "DependencyContainer" ]]; then
            echo -e "${YELLOW}⚠️  Potentially unused file: $file${NC}"
            UNUSED_FILES=$((UNUSED_FILES + 1))
        fi
    fi
done

echo ""
echo "🔧 Checking for unused functions..."

# Find all public functions and check if they're used
find shvil -name "*.swift" -type f | while read -r file; do
    # Extract public function names
    grep -n "public func\|func.*public" "$file" | while read -r line; do
        func_name=$(echo "$line" | sed -n 's/.*func \([a-zA-Z_][a-zA-Z0-9_]*\).*/\1/p')
        if [[ -n "$func_name" ]]; then
            # Check if function is called anywhere
            if ! grep -r "$func_name(" shvil --include="*.swift" | grep -v "$file" > /dev/null 2>&1; then
                echo -e "${YELLOW}⚠️  Potentially unused function: $func_name in $file${NC}"
                UNUSED_FUNCTIONS=$((UNUSED_FUNCTIONS + 1))
            fi
        fi
    done
done

echo ""
echo "📊 Checking for unused variables..."

# Find all @Published properties and check if they're used
find shvil -name "*.swift" -type f | while read -r file; do
    # Extract @Published property names
    grep -n "@Published.*var" "$file" | while read -r line; do
        var_name=$(echo "$line" | sed -n 's/.*var \([a-zA-Z_][a-zA-Z0-9_]*\).*/\1/p')
        if [[ -n "$var_name" ]]; then
            # Check if variable is referenced anywhere
            if ! grep -r "\\.$var_name\|$var_name\s*=" shvil --include="*.swift" | grep -v "$file" > /dev/null 2>&1; then
                echo -e "${YELLOW}⚠️  Potentially unused variable: $var_name in $file${NC}"
                UNUSED_VARIABLES=$((UNUSED_VARIABLES + 1))
            fi
        fi
    done
done

echo ""
echo "🎯 Dead Code Summary"
echo "==================="
echo -e "Total files checked: ${GREEN}$TOTAL_FILES${NC}"
echo -e "Potentially unused files: ${YELLOW}$UNUSED_FILES${NC}"
echo -e "Potentially unused functions: ${YELLOW}$UNUSED_FUNCTIONS${NC}"
echo -e "Potentially unused variables: ${YELLOW}$UNUSED_VARIABLES${NC}"

if [[ $UNUSED_FILES -eq 0 ]] && [[ $UNUSED_FUNCTIONS -eq 0 ]] && [[ $UNUSED_VARIABLES -eq 0 ]]; then
    echo -e "\n${GREEN}✅ No dead code detected!${NC}"
    exit 0
else
    echo -e "\n${YELLOW}⚠️  Dead code detected. Review the items above.${NC}"
    exit 1
fi
