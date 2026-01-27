# ML API - Production-Grade Machine Learning Service

A production-ready ML API service built with FastAPI, Polars, SQLAlchemy 2.0, and Google Cloud Storage for model training, hyperparameter tuning, and inference.

## Features

- **Data Splits**: CRUD operations for train/val/test splits with multiple strategies
- **Experiments**: Hyperparameter tuning with Optuna for CatBoost, XGBoost, and LightGBM
- **Model Registry**: Version management with staging/production promotion
- **Predictions**: Inference with preprocessing/postprocessing pipelines
- **Feature Importance**: SHAP explanations with fallback methods
- **Polars-First**: Primary dataframe operations use Polars with explicit pandas conversion
- **Observability**: Structured logging, request tracing, and Prometheus metrics
- **Background Jobs**: Async experiment execution with Arq (Redis-based)

## Architecture

### Tech Stack

- **API Framework**: FastAPI
- **Database**: PostgreSQL with async SQLAlchemy 2.0
- **Migrations**: Alembic
- **Data Processing**: Polars (primary), Pandas (boundary conversion only)
- **ML Libraries**: CatBoost (default), XGBoost, LightGBM
- **Hyperparameter Tuning**: Optuna
- **Storage**: Google Cloud Storage
- **Job Queue**: Arq (Redis-based)
- **CLI**: Typer
- **Logging**: Structlog with request_id correlation
- **Metrics**: Prometheus
- **Settings**: Pydantic Settings

### Polars-First Data Flow

```
Input Data (JSON/CSV/Parquet)
    ↓ (Polars)
Data Split (train/val/test)
    ↓ (Polars)
Preprocessing (feature engineering, encoding)
    ↓ (Polars → Pandas conversion logged)
Model Training (CatBoost/XGBoost/LightGBM)
    ↓
Model Artifacts → GCS
    ↓
Prediction Request
    ↓ (Polars)
Preprocessing (apply saved artifacts)
    ↓ (Polars → Pandas for model)
Inference
    ↓ (Polars)
Postprocessing
    ↓
Response
```

**Key Principle**: Use Polars for all data manipulation. Convert to pandas ONLY when a specific ML library requires it, and log every conversion with memory estimates.

### GCS Artifact Layout

```
gs://{bucket}/
  splits/
    {split_id}/
      train.parquet
      val.parquet
      test.parquet
  experiments/
    {experiment_id}/
      trials/
        {trial_id}/
          model.cbm (or .json for XGBoost/LightGBM)
      best_model/
        model.cbm
        preprocess.json
        postprocess.json
        metrics.json
        signature.json
  models/
    {experiment_id}/
      v{version}/
        model.cbm
        preprocess.json
        postprocess.json
        signature.json
```

## Installation

### Prerequisites

- Python 3.10+ (Python 3.10-3.11 recommended for ML libraries compatibility)
- PostgreSQL 14+
- Redis 6+
- Google Cloud Platform account with GCS bucket
- [uv](https://github.com/astral-sh/uv) - Fast Python package installer

**Note**: ML libraries (CatBoost, XGBoost, LightGBM, SHAP) are optional. Install with `.[ml]` if needed.

### Setup

```bash
# Clone repository
git clone <repo-url>
cd ml-api

# Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create virtual environment and install dependencies
uv venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install the package with dependencies
uv pip install -e .

# Install with ML libraries (CatBoost, XGBoost, LightGBM, SHAP, etc.)
uv pip install -e ".[ml]"

# Install development dependencies
uv pip install -e ".[dev]"

# Install everything (base + ML + dev)
uv pip install -e ".[all]"

# Copy environment file
cp .env.example .env

# Edit .env with your configuration
vim .env
```

### Environment Configuration

Key settings in `.env`:

```bash
# Database
DATABASE_URL=postgresql+asyncpg://user:pass@localhost:5432/mlapi

# GCS
GCS_BUCKET=my-ml-artifacts
GCS_PROJECT_ID=my-project
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json

# Redis
REDIS_URL=redis://localhost:6379/0

# Model defaults
DEFAULT_MODEL_TYPE=catboost
DEFAULT_CLASSIFICATION_METRIC=auc
DEFAULT_REGRESSION_METRIC=rmse
```

### Database Migration

```bash
# Initialize database
mlapi db init

# Run migrations
alembic upgrade head

# Or use CLI
mlapi db upgrade
```

## Running the Service

### Development

```bash
# Start API server with auto-reload
mlapi serve --reload --log-level debug

# Or use uvicorn directly
uvicorn app.main:app --reload --port 8000
```

### Production

```bash
# Start with CLI (recommended)
mlapi serve --host 0.0.0.0 --port 8000 --workers 4

# With additional options
mlapi serve \
  --host 0.0.0.0 \
  --port 8000 \
  --workers 4 \
  --proxy-headers \
  --forwarded-allow-ips="127.0.0.1,10.0.0.0/8" \
  --limit-max-requests 1000

# With SSL
mlapi serve \
  --host 0.0.0.0 \
  --port 8443 \
  --workers 4 \
  --ssl-keyfile /path/to/key.pem \
  --ssl-certfile /path/to/cert.pem

# Or use uvicorn directly
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
```

### CLI Deployment Options

The `mlapi serve` command supports extensive configuration:

- `--host, -h`: Bind host (default: 0.0.0.0)
- `--port, -p`: Bind port (default: 8000)
- `--workers, -w`: Number of worker processes (default: 1)
- `--reload, -r`: Enable auto-reload for development
- `--log-level, -l`: Set log level (debug, info, warning, error, critical)
- `--access-log/--no-access-log`: Enable/disable access logs
- `--proxy-headers`: Enable proxy headers for reverse proxy setups
- `--forwarded-allow-ips`: Comma-separated IPs to trust for proxy headers
- `--ssl-keyfile`: Path to SSL key file
- `--ssl-certfile`: Path to SSL certificate file
- `--limit-concurrency`: Maximum number of concurrent connections
- `--limit-max-requests`: Maximum requests before worker restart
- `--timeout-keep-alive`: Keep-alive timeout in seconds (default: 5)

Run `mlapi serve --help` for all available options.

### Background Workers

Start Arq worker for background job processing:

```bash
# Start worker
arq app.workers.worker.WorkerSettings
```

### Docker Compose (Optional)

```bash
docker-compose up -d
```

## API Endpoints

### Health & Meta

- `GET /healthz` - Basic health check
- `GET /readyz` - Readiness check (DB + GCS connectivity)
- `GET /version` - Version information
- `GET /metrics` - Prometheus metrics

### Data Splits

- `POST /v1/splits` - Create a new data split
- `GET /v1/splits/{split_id}` - Get split details
- `GET /v1/splits` - List splits (with filters & pagination)
- `PATCH /v1/splits/{split_id}` - Update split metadata
- `DELETE /v1/splits/{split_id}` - Delete split (soft delete)

### Experiments

- `POST /v1/experiments` - Create and start experiment
- `GET /v1/experiments/{experiment_id}` - Get experiment details
- `GET /v1/experiments` - List experiments
- `PATCH /v1/experiments/{experiment_id}` - Update experiment
- `DELETE /v1/experiments/{experiment_id}` - Delete experiment
- `GET /v1/experiments/{experiment_id}/trials` - List trials
- `POST /v1/experiments/{experiment_id}/cancel` - Cancel running experiment

### Models

- `GET /v1/models` - List models (filter by stage)
- `GET /v1/models/{model_id}` - Get model details
- `POST /v1/models/{model_id}/promote` - Promote to production
- `POST /v1/models/{model_id}/archive` - Archive model
- `DELETE /v1/models/{model_id}` - Delete model

### Predictions

- `POST /v1/predict` - Make predictions

### Feature Importance

- `POST /v1/importance` - Get feature importance

## Example API Calls

### Create Data Split

```bash
curl -X POST http://localhost:8000/v1/splits \
  -H "Content-Type: application/json" \
  -d '{
    "entity_id": "customer_churn",
    "inline_data": [
      {"age": 25, "income": 50000, "churned": 0},
      {"age": 35, "income": 75000, "churned": 1}
    ],
    "split_strategy": "random",
    "split_params": {
      "train_ratio": 0.7,
      "val_ratio": 0.15,
      "test_ratio": 0.15,
      "seed": 42
    }
  }'
```

### Create Experiment

```bash
curl -X POST http://localhost:8000/v1/experiments \
  -H "Content-Type: application/json" \
  -d '{
    "split_id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Customer Churn Model v1",
    "target_column": "churned",
    "feature_columns": ["age", "income"],
    "task_type": "classification",
    "model_type": "catboost",
    "metric_name": "auc",
    "optuna_config": {
      "n_trials": 50,
      "timeout_seconds": 3600,
      "sampler": "TPE",
      "pruner": "MedianPruner",
      "seed": 42
    }
  }'
```

### Make Prediction

```bash
curl -X POST http://localhost:8000/v1/predict \
  -H "Content-Type: application/json" \
  -d '{
    "stage": "production",
    "instances": [
      {"age": 30, "income": 60000},
      {"age": 45, "income": 90000}
    ]
  }'
```

### Get Feature Importance

```bash
curl -X POST http://localhost:8000/v1/importance \
  -H "Content-Type: application/json" \
  -d '{
    "stage": "production",
    "max_samples": 1000,
    "method_preference": ["shap", "native"]
  }'
```

## CLI Usage

```bash
# Serve the API
mlapi serve --workers 4 --port 8000

# Show version
mlapi version

# See all commands
mlapi --help
```

## Logging & Observability

### Structured Logging

All logs include:
- `request_id`: Correlation ID for request tracing
- `service`: Service name
- `environment`: Current environment
- Contextual fields: `entity_id`, `split_id`, `experiment_id`, `trial_id`, `model_id`

### Log Lifecycle Events

Major operations log:
- Start: `{operation}_started`
- Completion: `{operation}_completed` with duration
- Failure: `{operation}_failed` with error details

### Dataframe Logging

All dataframe operations log:
- Rows and columns
- Schema summary
- Memory estimates
- Conversions between Polars ↔ Pandas

### Metrics

Prometheus metrics available at `/metrics`:
- HTTP request counts and durations
- Job execution stats
- Prediction counts
- Training metrics

## Testing

```bash
# Run all tests
uv run pytest

# Run with coverage
uv run pytest --cov=app --cov-report=html

# Run specific test file
uv run pytest tests/test_splits.py

# Run integration tests
uv run pytest tests/integration/
```

## Development

### Code Quality

```bash
# Format code
uv run black app/ cli/ tests/

# Lint
uv run ruff check app/ cli/ tests/

# Type checking
uv run mypy app/ cli/
```

### Adding a New Model Type

1. Create trainer in `app/services/training/{model}_trainer.py`
2. Implement `ModelTrainer` protocol
3. Add case to `dispatcher.py`
4. Add enum value to `ModelType` in `app/db/models/experiment.py`
5. Add tests

## Troubleshooting

### GCS Connection Issues

```bash
# Verify credentials
mlapi gcs verify

# Check bucket permissions
gsutil ls gs://{bucket-name}
```

### Database Connection Issues

```bash
# Test connection
mlapi db init

# Check migrations
alembic current
alembic history
```

### Worker Issues

```bash
# Check Redis connection
redis-cli ping

# Monitor worker logs
arq app.workers.worker.WorkerSettings --verbose
```

## CI/CD & Publishing

This project includes complete CI/CD automation powered by **uv** for fast, efficient builds and deployments.

### Quick Start

1. **Add PyPI Token to GitHub Secrets**
   - See **[GITHUB_SECRETS_SETUP.md](GITHUB_SECRETS_SETUP.md)** for detailed instructions
   - Add `PYPI_API_TOKEN` secret to your repository

2. **Create a Release**
   ```bash
   # Via GitHub CLI
   gh release create v0.1.0 --title "Release v0.1.0" --notes "Initial release"

   # Or via GitHub web UI: Releases → Draft a new release
   ```

3. **Automatic Publishing**
   - GitHub Actions automatically builds and publishes to PyPI
   - Docker images published to GitHub Container Registry
   - Release notes updated with installation instructions

### Documentation

- **[GITHUB_SECRETS_SETUP.md](GITHUB_SECRETS_SETUP.md)** - PyPI token setup (start here!)
- **[CICD_UV_MIGRATION.md](CICD_UV_MIGRATION.md)** - Complete CI/CD guide
- **[MIGRATION_UV.md](MIGRATION_UV.md)** - Migration from Poetry to uv
- **[UV_COMMANDS.md](UV_COMMANDS.md)** - Quick reference for uv commands

### Automated Features

- ✅ **Continuous Integration**: Automated testing, linting, and building on every PR (powered by uv)
- ✅ **Automated Publishing**: One-click releases to PyPI using GitHub secrets
- ✅ **Docker Images**: Multi-architecture builds to GitHub Container Registry
- ✅ **Version Management**: Automated version bumping with PR creation
- ✅ **Security Scanning**: Dependency and code security checks
- ✅ **Fast Builds**: 10-100x faster builds with uv

### Installation from PyPI

Once published:

```bash
# Using uv (recommended)
uv pip install ml-api

# Or using pip
pip install ml-api
```

### Development Tools

```bash
# Build the package
uv build

# Install in editable mode
uv pip install -e .

# Run tests
uv run pytest

# Format code
uv run black app/ cli/ tests/

# Lint
uv run ruff check app/ cli/ tests/
```

## License

MIT

## Contributors

ML Platform Team
