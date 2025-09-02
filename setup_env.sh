#!/bin/bash

# Setup environment variables for Shvil development
# This script sets up the Supabase configuration securely

echo "🔧 Setting up Shvil development environment..."

# Set Supabase configuration
export SUPABASE_URL="https://lnniqqjaslpyljtcmkmf.supabase.co"
export SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxubmlxcWphc2xweWxqdGNta21mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY2NzE2MzcsImV4cCI6MjA3MjI0NzYzN30.mYHsTvpfr-jEhGnwbwt1-qw0ybdi0M_RFmsnQyIbLE0"

echo "✅ Environment variables set:"
echo "   SUPABASE_URL: $SUPABASE_URL"
echo "   SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY:0:20}..."

echo ""
echo "🚀 You can now run the app in Xcode with proper Supabase configuration!"
echo "   The app will automatically use these environment variables."
echo ""
echo "⚠️  Remember: These variables are only set for this terminal session."
echo "   To make them permanent, add them to your shell profile."
