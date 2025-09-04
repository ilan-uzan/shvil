#!/bin/bash

# Shvil Environment Setup Script
# This script helps you securely set up your environment variables

echo "🔐 Shvil Environment Setup"
echo "=========================="
echo ""

# Check if .env file exists
if [ -f ".env" ]; then
    echo "⚠️  WARNING: .env file already exists!"
    echo "   This file contains sensitive information and should not be committed to git."
    echo ""
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 1
    fi
fi

echo "Creating .env file..."
echo ""

# Create .env file with secure permissions
touch .env
chmod 600 .env

echo "# Shvil Environment Variables" > .env
echo "# DO NOT COMMIT THIS FILE TO GIT" >> .env
echo "# Copy this file and fill in your actual values" >> .env
echo "" >> .env

# Supabase Configuration
echo "Enter your Supabase configuration:"
read -p "Supabase URL (e.g., https://abcdefg.supabase.co): " SUPABASE_URL
read -p "Supabase Anon Key: " SUPABASE_ANON_KEY

echo "SUPABASE_URL=$SUPABASE_URL" >> .env
echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> .env
echo "" >> .env

# OpenAI Configuration
echo ""
echo "Enter your OpenAI configuration:"
read -p "OpenAI API Key (starts with sk-): " OPENAI_API_KEY

# Validate OpenAI key format
if [[ ! $OPENAI_API_KEY =~ ^sk- ]]; then
    echo "⚠️  WARNING: OpenAI API key should start with 'sk-'"
    echo "   Please verify your key is correct."
fi

echo "OPENAI_API_KEY=$OPENAI_API_KEY" >> .env

echo ""
echo "✅ Environment setup complete!"
echo ""
echo "🔒 Security Notes:"
echo "   - Your .env file has been created with restricted permissions (600)"
echo "   - The .env file is already in .gitignore and will not be committed"
echo "   - Never share your API keys or commit them to version control"
echo "   - If you need to share this project, use the environment.example file instead"
echo ""
echo "🚀 Next steps:"
echo "   1. Verify your keys are correct by running the app"
echo "   2. If you see configuration errors, check your .env file"
echo "   3. For production deployment, set these as environment variables in your deployment platform"
echo ""
