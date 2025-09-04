# Shvil Development Makefile
# Provides convenient commands for database operations and development tasks

.PHONY: help install seed-dev reset-dev health-check migrate status

# Default target
help:
	@echo "Shvil Development Commands:"
	@echo ""
	@echo "Database Operations:"
	@echo "  seed-dev      - Seed development database with sample data"
	@echo "  reset-dev     - Reset development database (WARNING: destroys all data)"
	@echo "  health-check  - Check database and API health"
	@echo "  migrate       - Apply database migrations"
	@echo "  status        - Show database status and table counts"
	@echo ""
	@echo "Development:"
	@echo "  install       - Install dependencies and setup environment"
	@echo "  build         - Build the iOS project"
	@echo "  test          - Run tests"
	@echo "  format        - Format Swift code"
	@echo "  lint          - Lint Swift code"
	@echo ""
	@echo "Documentation:"
	@echo "  docs          - Generate documentation"
	@echo "  api-docs      - Generate API documentation"

# Check if required tools are installed
check-tools:
	@command -v supabase >/dev/null 2>&1 || { echo "Supabase CLI not found. Install with: npm install -g supabase"; exit 1; }
	@command -v psql >/dev/null 2>&1 || { echo "PostgreSQL client not found. Install PostgreSQL."; exit 1; }

# Install dependencies and setup environment
install: check-tools
	@echo "Installing dependencies..."
	@if [ ! -f .env ]; then \
		echo "Creating .env file from template..."; \
		cp environment.example .env; \
		echo "Please edit .env with your actual values"; \
	fi
	@echo "Environment setup complete!"

# Seed development database
seed-dev: check-tools
	@echo "Seeding development database..."
	@if [ -f .env ]; then \
		. .env && supabase db reset --linked; \
		. .env && psql "$$SUPABASE_URL" -f scripts/seed_dev.sql; \
		echo "Development database seeded successfully!"; \
	else \
		echo "Error: .env file not found. Run 'make install' first."; \
		exit 1; \
	fi

# Reset development database (WARNING: destroys all data)
reset-dev: check-tools
	@echo "WARNING: This will destroy all data in the development database!"
	@read -p "Are you sure? Type 'yes' to continue: " confirm && [ "$$confirm" = "yes" ]
	@if [ -f .env ]; then \
		. .env && supabase db reset --linked; \
		echo "Development database reset successfully!"; \
	else \
		echo "Error: .env file not found. Run 'make install' first."; \
		exit 1; \
	fi

# Check database and API health
health-check: check-tools
	@echo "Checking database health..."
	@if [ -f .env ]; then \
		. .env && psql "$$SUPABASE_URL" -c "SELECT public.health_check();"; \
	else \
		echo "Error: .env file not found. Run 'make install' first."; \
		exit 1; \
	fi

# Apply database migrations
migrate: check-tools
	@echo "Applying database migrations..."
	@if [ -f .env ]; then \
		. .env && supabase db push; \
		echo "Migrations applied successfully!"; \
	else \
		echo "Error: .env file not found. Run 'make install' first."; \
		exit 1; \
	fi

# Show database status and table counts
status: check-tools
	@echo "Database Status:"
	@if [ -f .env ]; then \
		. .env && psql "$$SUPABASE_URL" -c "SELECT public.get_system_metrics();"; \
		echo ""; \
		echo "Table Counts:"; \
		. .env && psql "$$SUPABASE_URL" -c "SELECT schemaname, tablename, n_tup_ins + n_tup_upd + n_tup_del as row_count FROM pg_stat_user_tables WHERE schemaname = 'public' ORDER BY tablename;"; \
	else \
		echo "Error: .env file not found. Run 'make install' first."; \
		exit 1; \
	fi

# Build the iOS project
build:
	@echo "Building iOS project..."
	@xcodebuild -project shvil.xcodeproj -scheme shvil -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
test:
	@echo "Running tests..."
	@xcodebuild -project shvil.xcodeproj -scheme shvil -destination 'platform=iOS Simulator,name=iPhone 16' test

# Format Swift code
format:
	@echo "Formatting Swift code..."
	@swiftformat .

# Lint Swift code
lint:
	@echo "Linting Swift code..."
	@swiftformat --lint .

# Generate documentation
docs:
	@echo "Generating documentation..."
	@mkdir -p docs/generated
	@echo "Documentation generation not yet implemented"

# Generate API documentation
api-docs:
	@echo "Generating API documentation..."
	@mkdir -p docs/api
	@echo "API documentation generation not yet implemented"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@xcodebuild clean -project shvil.xcodeproj -scheme shvil
	@rm -rf DerivedData
	@echo "Clean complete!"

# Full development setup
setup: install migrate seed-dev
	@echo "Development setup complete!"
	@echo "Run 'make health-check' to verify everything is working"
