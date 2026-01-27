.PHONY: help install test lint format clean build publish docker run

# Variables
PYTHON := poetry run python
PYTEST := poetry run pytest
BLACK := poetry run black
RUFF := poetry run ruff
MYPY := poetry run mypy

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install dependencies with Poetry
	poetry install

install-dev: ## Install dependencies including dev dependencies
	poetry install --with dev

update: ## Update dependencies
	poetry update

lock: ## Update poetry.lock
	poetry lock --no-update

# Development
dev: ## Run development server
	poetry run uvicorn app.main:app --reload --port 8000

worker: ## Run background worker
	poetry run arq app.workers.worker.WorkerSettings

shell: ## Open Python shell with project context
	poetry run python

# Database
db-upgrade: ## Run database migrations
	poetry run alembic upgrade head

db-downgrade: ## Rollback last migration
	poetry run alembic downgrade -1

db-migrate: ## Create new migration
	@read -p "Enter migration message: " message; \
	poetry run alembic revision --autogenerate -m "$$message"

db-reset: ## Reset database (WARNING: destructive)
	poetry run alembic downgrade base
	poetry run alembic upgrade head

# Testing
test: ## Run tests
	$(PYTEST) tests/ -v

test-cov: ## Run tests with coverage
	$(PYTEST) tests/ --cov=app --cov=cli --cov-report=html --cov-report=term

test-watch: ## Run tests in watch mode
	$(PYTEST) tests/ -v --looponfail

test-fast: ## Run tests without slow tests
	$(PYTEST) tests/ -v -m "not slow"

test-unit: ## Run unit tests only
	$(PYTEST) tests/unit/ -v

test-integration: ## Run integration tests only
	$(PYTEST) tests/integration/ -v

# Code Quality
lint: ## Run all linters
	$(RUFF) check app/ cli/ tests/
	$(BLACK) --check app/ cli/ tests/
	$(MYPY) app/ cli/

format: ## Format code with Black
	$(BLACK) app/ cli/ tests/

format-check: ## Check code formatting
	$(BLACK) --check app/ cli/ tests/

ruff: ## Run Ruff linter
	$(RUFF) check app/ cli/ tests/

ruff-fix: ## Fix Ruff issues automatically
	$(RUFF) check --fix app/ cli/ tests/

mypy: ## Run type checker
	$(MYPY) app/ cli/

security: ## Run security checks
	poetry run bandit -r app/ cli/
	poetry run safety check

pre-commit: ## Run pre-commit hooks
	poetry run pre-commit run --all-files

pre-commit-install: ## Install pre-commit hooks
	poetry run pre-commit install

# Build & Publish
clean: ## Clean build artifacts
	rm -rf dist/ build/ *.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name "*.coverage" -delete
	rm -rf htmlcov/ .pytest_cache/ .mypy_cache/ .ruff_cache/

build: clean ## Build package
	poetry build

publish-test: build ## Publish to Test PyPI
	poetry publish -r testpypi

publish: build ## Publish to PyPI
	poetry publish

check-package: build ## Check package before publishing
	poetry run twine check dist/*

version-patch: ## Bump patch version
	poetry version patch
	@echo "New version: $$(poetry version -s)"

version-minor: ## Bump minor version
	poetry version minor
	@echo "New version: $$(poetry version -s)"

version-major: ## Bump major version
	poetry version major
	@echo "New version: $$(poetry version -s)"

# Docker
docker-build: ## Build Docker image
	docker build -t ml-api:latest .

docker-run: ## Run Docker container
	docker run -p 8000:8000 --env-file .env ml-api:latest

docker-compose-up: ## Start all services with docker-compose
	docker-compose up -d

docker-compose-down: ## Stop all services
	docker-compose down

docker-compose-logs: ## View docker-compose logs
	docker-compose logs -f

docker-compose-rebuild: ## Rebuild and restart services
	docker-compose down
	docker-compose build
	docker-compose up -d

# CLI
cli-version: ## Show CLI version
	poetry run mlapi version

cli-splits-list: ## List data splits
	poetry run mlapi splits list

cli-experiments-list: ## List experiments
	poetry run mlapi experiments list

cli-models-list: ## List models
	poetry run mlapi models list

# GCS
gcs-verify: ## Verify GCS connectivity
	poetry run mlapi gcs verify

# Monitoring
logs: ## Tail application logs
	tail -f logs/app.log

metrics: ## View Prometheus metrics
	curl http://localhost:8000/metrics

health: ## Check health endpoint
	curl http://localhost:8000/healthz

ready: ## Check readiness endpoint
	curl http://localhost:8000/readyz

# Documentation
docs-serve: ## Serve documentation locally (if using mkdocs)
	@echo "Documentation in README.md and docs/"

changelog: ## Update CHANGELOG.md
	@echo "Please update CHANGELOG.md manually"

# All-in-one commands
all: install lint test build ## Install, lint, test, and build

ci: lint test-cov build ## Run CI pipeline locally

release-patch: version-patch changelog build ## Release patch version
	@echo "Version bumped to $$(poetry version -s)"
	@echo "Next steps:"
	@echo "1. Update CHANGELOG.md"
	@echo "2. git add -A && git commit -m 'chore: bump version to $$(poetry version -s)'"
	@echo "3. git tag v$$(poetry version -s)"
	@echo "4. git push && git push --tags"
	@echo "5. Create GitHub release"

release-minor: version-minor changelog build ## Release minor version
	@echo "Version bumped to $$(poetry version -s)"
	@echo "Follow release-patch next steps"

release-major: version-major changelog build ## Release major version
	@echo "Version bumped to $$(poetry version -s)"
	@echo "Follow release-patch next steps"

# Setup
setup: install db-upgrade pre-commit-install ## Complete project setup
	@echo "Setup complete! Next steps:"
	@echo "1. Copy .env.example to .env and configure"
	@echo "2. Start services: make docker-compose-up"
	@echo "3. Run server: make dev"

setup-dev: setup ## Setup for development
	@echo "Development environment ready!"

# Cleanup
clean-all: clean ## Clean everything including virtual env
	poetry env remove --all
	rm -rf .venv/

reset: clean-all install setup ## Complete reset and reinstall
	@echo "Project reset complete!"
