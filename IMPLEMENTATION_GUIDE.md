# ML API Implementation Guide

This document provides a complete overview of the production-grade ML API project structure and implementation status.

## ✅ Completed Files

### Core Infrastructure
- ✅ `pyproject.toml` - Poetry dependencies and project configuration
- ✅ `.env.example` - Environment variable template
- ✅ `app/core/config.py` - Pydantic Settings configuration
- ✅ `app/core/logging.py` - Structured logging with request_id correlation
- ✅ `app/core/exceptions.py` - Custom exceptions and error handlers
- ✅ `app/core/telemetry.py` - Prometheus metrics

### Database
- ✅ `app/db/base.py` - SQLAlchemy base configuration
- ✅ `app/db/session.py` - Async session management
- ✅ `app/db/models/split.py` - DataSplit model
- ✅ `app/db/models/experiment.py` - Experiment model
- ✅ `app/db/models/trial.py` - Trial model
- ✅ `app/db/models/model_registry.py` - ModelRegistry model
- ✅ `app/db/migrations/env.py` - Alembic environment
- ✅ `app/db/migrations/script.py.mako` - Migration template
- ✅ `alembic.ini` - Alembic configuration

### Schemas (Pydantic)
- ✅ `app/schemas/split.py` - Data split schemas
- ✅ `app/schemas/experiment.py` - Experiment schemas
- ✅ `app/schemas/model_registry.py` - Model registry schemas
- ✅ `app/schemas/predict.py` - Prediction schemas
- ✅ `app/schemas/importance.py` - Feature importance schemas

### Services - Training
- ✅ `app/services/training/dataset_io.py` - Polars-first data I/O
- ✅ `app/services/training/preprocess.py` - Polars-based preprocessing
- ✅ `app/services/training/dispatcher.py` - Model dispatcher with match/case
- ✅ `app/services/training/catboost_trainer.py` - CatBoost trainer (default)
- ✅ `app/services/training/xgboost_trainer.py` - XGBoost trainer
- ✅ `app/services/training/lightgbm_trainer.py` - LightGBM trainer

### Services - Business Logic
- ✅ `app/services/split_service.py` - Data split service

### API
- ✅ `app/main.py` - FastAPI application
- ✅ `app/clients.py` - GCS client
- ✅ `app/api/routes/health.py` - Health check endpoints
- ✅ `app/api/routes/splits.py` - Data split CRUD endpoints

### CLI
- ✅ `cli/main.py` - Typer CLI entry point

### Deployment
- ✅ `Dockerfile` - Container image
- ✅ `docker-compose.yml` - Local development stack
- ✅ `README.md` - Comprehensive documentation

## 📝 Remaining Files to Implement

### Services - Business Logic

#### `app/services/experiment_service.py`
```python
"""Experiment service with Optuna integration."""
# Responsibilities:
# - Create experiment records
# - Enqueue background jobs for training
# - Load train/val data from split
# - Run Optuna study with trials
# - Save best model to GCS
# - Create model registry entry
# - Update experiment status
```

#### `app/services/predict_service.py`
```python
"""Prediction service."""
# Responsibilities:
# - Load model from GCS by selector (model_id, experiment_id, or stage)
# - Load preprocessing artifacts
# - Apply preprocessing to input instances (Polars)
# - Run inference (convert to pandas if needed)
# - Apply postprocessing
# - Return predictions with metadata
```

#### `app/services/importance_service.py`
```python
"""Feature importance service with SHAP."""
# Responsibilities:
# - Load model from GCS
# - Compute SHAP values (TreeExplainer for tree models)
# - Fallback to native feature importance
# - Return global importance ranking
# - Optional per-instance explanations
```

#### `app/services/model_registry_service.py`
```python
"""Model registry service."""
# Responsibilities:
# - List models by stage/experiment
# - Promote models (staging → production)
# - Archive models
# - Safe delete with artifact cleanup option
```

### Services - Training Components

#### `app/services/training/artifact_io.py`
```python
"""Model artifact I/O to/from GCS."""
# Responsibilities:
# - Save model binary + metadata to GCS
# - Load model binary + metadata from GCS
# - Save/load preprocessing artifacts
# - Save/load postprocessing configs
# - Save model signature (expected schema)
# - Versioned artifact paths
```

#### `app/services/training/postprocess.py`
```python
"""Postprocessing operations."""
# Responsibilities:
# - Classification: threshold application, label mapping
# - Regression: clipping, rounding, unit transforms
# - Store postprocess config for reproducibility
```

#### `app/services/training/optuna_runner.py`
```python
"""Optuna study runner."""
# Responsibilities:
# - Create Optuna study with config (sampler, pruner, seed)
# - Define objective function
# - Run trials with trainer
# - Log each trial to database
# - Return best trial and model
# - Handle pruning and failures
```

### API Routes

#### `app/api/routes/experiments.py`
```python
"""Experiment CRUD endpoints."""
# Endpoints:
# - POST /v1/experiments - Create and start experiment
# - GET /v1/experiments/{id} - Get experiment details
# - GET /v1/experiments - List experiments
# - PATCH /v1/experiments/{id} - Update experiment
# - DELETE /v1/experiments/{id} - Delete experiment
# - GET /v1/experiments/{id}/trials - List trials
# - POST /v1/experiments/{id}/cancel - Cancel experiment
```

#### `app/api/routes/models.py`
```python
"""Model registry endpoints."""
# Endpoints:
# - GET /v1/models - List models
# - GET /v1/models/{id} - Get model details
# - POST /v1/models/{id}/promote - Promote to stage
# - POST /v1/models/{id}/archive - Archive model
# - DELETE /v1/models/{id} - Delete model
```

#### `app/api/routes/predict.py`
```python
"""Prediction endpoint."""
# Endpoints:
# - POST /v1/predict - Make predictions
```

#### `app/api/routes/importance.py`
```python
"""Feature importance endpoint."""
# Endpoints:
# - POST /v1/importance - Get feature importance
```

#### `app/api/deps.py`
```python
"""Dependency injection providers."""
# Providers:
# - get_db() - Database session
# - get_gcs_client() - GCS client
# - get_settings() - Settings
# - get_experiment_service()
# - get_predict_service()
# - etc.
```

### Background Workers

#### `app/workers/__init__.py`
```python
"""Worker initialization."""
```

#### `app/workers/worker.py`
```python
"""Arq worker configuration and settings."""
# Configuration:
# - Redis connection
# - Task functions
# - Concurrency settings
# - Job timeout
# - Retry policy
```

#### `app/workers/tasks.py`
```python
"""Background task definitions."""
# Tasks:
# - run_experiment(experiment_id) - Run Optuna study
# - cancel_experiment(experiment_id) - Cancel running experiment
```

### CLI Commands

#### `cli/commands/__init__.py`
```python
"""CLI commands module."""
```

#### `cli/commands/db.py`
```python
"""Database CLI commands."""
# Commands:
# - init - Initialize database
# - migrate - Create migration
# - upgrade - Apply migrations
# - downgrade - Rollback migrations
# - reset - Reset database (dev only)
```

#### `cli/commands/splits.py`
```python
"""Data split CLI commands."""
# Commands:
# - create - Create split
# - read - Get split details
# - list - List splits
# - update - Update split
# - delete - Delete split
```

#### `cli/commands/experiments.py`
```python
"""Experiment CLI commands."""
# Commands:
# - create - Create experiment
# - read - Get experiment details
# - list - List experiments
# - run - Manually run experiment
# - cancel - Cancel experiment
# - delete - Delete experiment
```

#### `cli/commands/models.py`
```python
"""Model registry CLI commands."""
# Commands:
# - list - List models
# - read - Get model details
# - promote - Promote model
# - archive - Archive model
# - delete - Delete model
```

#### `cli/commands/maintenance.py`
```python
"""Maintenance and utility CLI commands."""
# Commands:
# - gcs verify - Verify GCS connectivity
# - seed demo-data - Seed demo data
# - cleanup-artifacts - Clean up orphaned GCS artifacts
# - export-metrics - Export metrics report
```

### Tests

#### `tests/conftest.py`
```python
"""Pytest fixtures and configuration."""
# Fixtures:
# - test_db - Test database session
# - test_client - FastAPI test client
# - fake_gcs_client - In-memory GCS mock
# - sample_data - Sample datasets
```

#### `tests/unit/test_dispatcher.py`
```python
"""Test model dispatcher."""
# Tests:
# - Test dispatch to CatBoost
# - Test dispatch to XGBoost
# - Test dispatch to LightGBM
# - Test invalid model type
# - Test invalid task type
```

#### `tests/unit/test_preprocessing.py`
```python
"""Test preprocessing logic."""
# Tests:
# - Test missing value handling
# - Test categorical encoding
# - Test column ordering
# - Test type casting
# - Test apply preprocessing
```

#### `tests/unit/test_dataset_io.py`
```python
"""Test dataset I/O."""
# Tests:
# - Test load from GCS
# - Test load from local file
# - Test load from records
# - Test save to GCS
# - Test random split
# - Test time-based split
# - Test entity-based split
# - Test polars_to_pandas conversion logging
```

#### `tests/integration/test_splits_api.py`
```python
"""Integration tests for splits API."""
# Tests:
# - Test create split with inline data
# - Test create split with URI
# - Test list splits
# - Test get split
# - Test update split
# - Test delete split
```

#### `tests/integration/test_experiments_api.py`
```python
"""Integration tests for experiments API."""
# Tests:
# - Test create experiment
# - Test list experiments
# - Test get experiment
# - Test get trials
# - Test cancel experiment
```

#### `tests/integration/test_predict_api.py`
```python
"""Integration tests for prediction API."""
# Tests:
# - Test predict with model_id
# - Test predict with experiment_id
# - Test predict with stage selector
# - Test classification probabilities
# - Test regression predictions
```

## 🔧 Implementation Priority

### Phase 1: Core Functionality (CRITICAL)
1. `app/services/training/artifact_io.py` - Model persistence
2. `app/services/training/optuna_runner.py` - Hyperparameter tuning
3. `app/services/training/postprocess.py` - Output processing
4. `app/services/experiment_service.py` - Experiment orchestration
5. `app/workers/tasks.py` & `app/workers/worker.py` - Background execution
6. `app/api/routes/experiments.py` - Experiment API

### Phase 2: Inference (HIGH PRIORITY)
7. `app/services/model_registry_service.py` - Model management
8. `app/services/predict_service.py` - Inference pipeline
9. `app/api/routes/models.py` - Model API
10. `app/api/routes/predict.py` - Prediction API

### Phase 3: Feature Importance (MEDIUM PRIORITY)
11. `app/services/importance_service.py` - SHAP integration
12. `app/api/routes/importance.py` - Importance API

### Phase 4: CLI & Tooling (MEDIUM PRIORITY)
13. `cli/commands/db.py` - Database CLI
14. `cli/commands/splits.py` - Splits CLI
15. `cli/commands/experiments.py` - Experiments CLI
16. `cli/commands/models.py` - Models CLI
17. `cli/commands/maintenance.py` - Utilities CLI

### Phase 5: Testing (HIGH PRIORITY)
18. `tests/conftest.py` - Test fixtures
19. Unit tests for core components
20. Integration tests for API endpoints

## 📚 Key Implementation Notes

### Polars-First Rule
- Use Polars for all data operations
- Convert to pandas ONLY at ML library boundaries
- Log every conversion with memory estimates
- Example in `dataset_io.py`: `polars_to_pandas()` and `pandas_to_polars()`

### Match/Case Dispatch
- Use Python 3.10+ match/case for task_type and model_type switching
- See `dispatcher.py` for implementation pattern
- Extend by adding new cases

### GCS Artifact Paths
- Consistent path structure: `{resource_type}/{id}/{artifact}`
- Examples:
  - `splits/{split_id}/train.parquet`
  - `experiments/{experiment_id}/best_model/model.cbm`
  - `models/{experiment_id}/v{version}/model.cbm`

### Logging Requirements
- Log start/end of all operations
- Include durations and key IDs
- Use `log_function_call()` and `log_function_result()`
- Log dataframe operations with `log_dataframe_info()`
- Log conversions with `log_conversion()`

### Background Job Strategy
- Use Arq (Redis-based queue) for production
- Implement clean job runner abstraction
- Support status polling and cancellation
- Store job_id with experiment for tracking

### Error Handling
- Use custom exception types from `app/core/exceptions.py`
- Return consistent error responses with request_id
- Soft delete by default, explicit flag for artifact deletion
- Log all exceptions with stack traces

## 🚀 Quick Start Implementation Template

For each new service/route, follow this pattern:

```python
"""Module description."""
from app.core.logging import get_logger, log_function_call, log_function_result
from app.core.exceptions import ResourceNotFoundError, ValidationError

logger = get_logger(__name__)


class MyService:
    """Service description."""

    async def my_operation(self, ...):
        """Operation description."""
        start_time = time.time()

        log_function_call(logger, "my_operation", key_id=...)

        try:
            # Implementation
            result = ...

            duration_ms = (time.time() - start_time) * 1000
            log_function_result(logger, "my_operation", duration_ms=duration_ms)

            return result

        except Exception as e:
            logger.error("my_operation_failed", error=str(e))
            raise
```

## 📞 Support

For questions or issues during implementation:
1. Review existing implementations in completed files
2. Check `README.md` for architecture details
3. Refer to this guide for file purposes
4. Follow logging and error handling patterns consistently
