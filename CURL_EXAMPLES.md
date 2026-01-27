# API Examples - cURL Commands

Complete collection of cURL commands for testing the ML API.

## Health & Meta Endpoints

### Basic Health Check
```bash
curl -X GET http://localhost:8000/healthz
```

Response:
```json
{
  "status": "ok",
  "service": "ml-api",
  "version": "0.1.0"
}
```

### Readiness Check (with Dependencies)
```bash
curl -X GET http://localhost:8000/readyz
```

Response:
```json
{
  "status": "ready",
  "checks": {
    "database": true,
    "gcs": true
  }
}
```

### Version Information
```bash
curl -X GET http://localhost:8000/version
```

Response:
```json
{
  "name": "ml-api",
  "version": "0.1.0",
  "environment": "development"
}
```

### Prometheus Metrics
```bash
curl -X GET http://localhost:8000/metrics
```

---

## Data Splits CRUD

### Create Split with Inline Data
```bash
curl -X POST http://localhost:8000/v1/splits \
  -H "Content-Type: application/json" \
  -H "X-Request-ID: test-split-001" \
  -d '{
    "entity_id": "customer_churn",
    "inline_data": [
      {"age": 25, "income": 50000, "tenure_months": 6, "churned": 0},
      {"age": 35, "income": 75000, "tenure_months": 24, "churned": 1},
      {"age": 45, "income": 90000, "tenure_months": 36, "churned": 0},
      {"age": 28, "income": 55000, "tenure_months": 12, "churned": 1},
      {"age": 52, "income": 120000, "tenure_months": 48, "churned": 0}
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

### Create Split with Dataset URI
```bash
curl -X POST http://localhost:8000/v1/splits \
  -H "Content-Type: application/json" \
  -d '{
    "entity_id": "sales_forecast",
    "dataset_uri": "gs://my-bucket/datasets/sales_data.parquet",
    "split_strategy": "time_based",
    "split_params": {
      "time_column": "date",
      "train_ratio": 0.7,
      "val_ratio": 0.15,
      "test_ratio": 0.15
    }
  }'
```

### Create Split with Entity-Based Strategy
```bash
curl -X POST http://localhost:8000/v1/splits \
  -H "Content-Type: application/json" \
  -d '{
    "entity_id": "user_behavior",
    "dataset_uri": "gs://my-bucket/datasets/user_events.csv",
    "split_strategy": "entity_based",
    "split_params": {
      "entity_column": "user_id",
      "train_ratio": 0.7,
      "val_ratio": 0.15,
      "test_ratio": 0.15,
      "seed": 42
    }
  }'
```

### Get Split by ID
```bash
curl -X GET http://localhost:8000/v1/splits/550e8400-e29b-41d4-a716-446655440000
```

### List All Splits
```bash
curl -X GET "http://localhost:8000/v1/splits?page=1&page_size=50"
```

### List Splits with Filters
```bash
# Filter by entity_id
curl -X GET "http://localhost:8000/v1/splits?entity_id=customer_churn&page=1&page_size=20"

# Filter by status
curl -X GET "http://localhost:8000/v1/splits?status=ready&page=1&page_size=20"

# Multiple filters
curl -X GET "http://localhost:8000/v1/splits?entity_id=customer_churn&status=ready&page=1&page_size=10"
```

### Update Split Metadata
```bash
curl -X PATCH http://localhost:8000/v1/splits/550e8400-e29b-41d4-a716-446655440000 \
  -H "Content-Type: application/json" \
  -d '{
    "split_params": {
      "train_ratio": 0.8,
      "val_ratio": 0.1,
      "test_ratio": 0.1,
      "seed": 42
    }
  }'
```

### Delete Split (Soft Delete)
```bash
curl -X DELETE http://localhost:8000/v1/splits/550e8400-e29b-41d4-a716-446655440000
```

### Delete Split with Artifacts
```bash
curl -X DELETE "http://localhost:8000/v1/splits/550e8400-e29b-41d4-a716-446655440000?delete_artifacts=true"
```

---

## Experiments CRUD

### Create Experiment (Classification - CatBoost)
```bash
curl -X POST http://localhost:8000/v1/experiments \
  -H "Content-Type: application/json" \
  -H "X-Request-ID: exp-001" \
  -d '{
    "split_id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Customer Churn Prediction v1",
    "target_column": "churned",
    "feature_columns": ["age", "income", "tenure_months"],
    "task_type": "classification",
    "model_type": "catboost",
    "metric_name": "auc",
    "optuna_config": {
      "n_trials": 50,
      "timeout_seconds": 3600,
      "sampler": "TPE",
      "pruner": "MedianPruner",
      "seed": 42
    },
    "preprocess_config": {
      "missing_strategy": "fill_mean"
    }
  }'
```

### Create Experiment (Regression - XGBoost)
```bash
curl -X POST http://localhost:8000/v1/experiments \
  -H "Content-Type: application/json" \
  -d '{
    "split_id": "660e8400-e29b-41d4-a716-446655440001",
    "name": "Sales Forecasting Model",
    "target_column": "sales_amount",
    "feature_columns": ["day_of_week", "month", "promo_active", "competitor_price"],
    "task_type": "regression",
    "model_type": "xgboost",
    "metric_name": "rmse",
    "optuna_config": {
      "n_trials": 100,
      "timeout_seconds": 7200,
      "sampler": "TPE",
      "pruner": "MedianPruner",
      "seed": 123
    }
  }'
```

### Create Experiment (Classification - LightGBM)
```bash
curl -X POST http://localhost:8000/v1/experiments \
  -H "Content-Type: application/json" \
  -d '{
    "split_id": "770e8400-e29b-41d4-a716-446655440002",
    "name": "Fraud Detection Model",
    "target_column": "is_fraud",
    "feature_columns": ["transaction_amount", "merchant_category", "time_of_day", "device_type"],
    "task_type": "classification",
    "model_type": "lightgbm",
    "optuna_config": {
      "n_trials": 75,
      "timeout_seconds": 5400
    }
  }'
```

### Get Experiment by ID
```bash
curl -X GET http://localhost:8000/v1/experiments/880e8400-e29b-41d4-a716-446655440003
```

### List All Experiments
```bash
curl -X GET "http://localhost:8000/v1/experiments?page=1&page_size=50"
```

### List Experiments with Filters
```bash
# Filter by split_id
curl -X GET "http://localhost:8000/v1/experiments?split_id=550e8400-e29b-41d4-a716-446655440000"

# Filter by status
curl -X GET "http://localhost:8000/v1/experiments?status=succeeded"

# Filter by model type
curl -X GET "http://localhost:8000/v1/experiments?model_type=catboost"

# Filter by task type
curl -X GET "http://localhost:8000/v1/experiments?task_type=classification"

# Multiple filters
curl -X GET "http://localhost:8000/v1/experiments?status=running&model_type=xgboost&page=1"
```

### Get Experiment Trials
```bash
curl -X GET http://localhost:8000/v1/experiments/880e8400-e29b-41d4-a716-446655440003/trials
```

### Update Experiment Name
```bash
curl -X PATCH http://localhost:8000/v1/experiments/880e8400-e29b-41d4-a716-446655440003 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Customer Churn Prediction v2 (Updated)"
  }'
```

### Cancel Running Experiment
```bash
curl -X POST http://localhost:8000/v1/experiments/880e8400-e29b-41d4-a716-446655440003/cancel
```

### Delete Experiment
```bash
curl -X DELETE http://localhost:8000/v1/experiments/880e8400-e29b-41d4-a716-446655440003
```

---

## Model Registry

### List All Models
```bash
curl -X GET "http://localhost:8000/v1/models?page=1&page_size=50"
```

### List Models by Stage
```bash
# Production models only
curl -X GET "http://localhost:8000/v1/models?stage=production"

# Staging models only
curl -X GET "http://localhost:8000/v1/models?stage=staging"

# Archived models
curl -X GET "http://localhost:8000/v1/models?stage=archived"
```

### List Models by Experiment
```bash
curl -X GET "http://localhost:8000/v1/models?experiment_id=880e8400-e29b-41d4-a716-446655440003"
```

### Get Model by ID
```bash
curl -X GET http://localhost:8000/v1/models/990e8400-e29b-41d4-a716-446655440004
```

### Promote Model to Production
```bash
curl -X POST http://localhost:8000/v1/models/990e8400-e29b-41d4-a716-446655440004/promote \
  -H "Content-Type: application/json" \
  -d '{
    "target_stage": "production"
  }'
```

### Promote Model to Staging
```bash
curl -X POST http://localhost:8000/v1/models/990e8400-e29b-41d4-a716-446655440004/promote \
  -H "Content-Type: application/json" \
  -d '{
    "target_stage": "staging"
  }'
```

### Archive Model
```bash
curl -X POST http://localhost:8000/v1/models/990e8400-e29b-41d4-a716-446655440004/archive
```

### Delete Model (Soft Delete)
```bash
curl -X DELETE http://localhost:8000/v1/models/990e8400-e29b-41d4-a716-446655440004
```

### Delete Model with Artifacts
```bash
curl -X DELETE "http://localhost:8000/v1/models/990e8400-e29b-41d4-a716-446655440004?delete_artifacts=true"
```

---

## Predictions

### Predict using Model ID
```bash
curl -X POST http://localhost:8000/v1/predict \
  -H "Content-Type: application/json" \
  -H "X-Request-ID: pred-001" \
  -d '{
    "model_id": "990e8400-e29b-41d4-a716-446655440004",
    "instances": [
      {"age": 30, "income": 60000, "tenure_months": 18},
      {"age": 45, "income": 95000, "tenure_months": 36}
    ]
  }'
```

Response (Classification):
```json
{
  "predictions": [0, 1],
  "probabilities": [
    [0.85, 0.15],
    [0.25, 0.75]
  ],
  "model_id": "990e8400-e29b-41d4-a716-446655440004",
  "model_version": 1,
  "model_type": "catboost",
  "task_type": "classification",
  "request_id": "pred-001",
  "duration_ms": 45.2
}
```

### Predict using Experiment ID (Best Model)
```bash
curl -X POST http://localhost:8000/v1/predict \
  -H "Content-Type: application/json" \
  -d '{
    "experiment_id": "880e8400-e29b-41d4-a716-446655440003",
    "instances": [
      {"age": 28, "income": 55000, "tenure_months": 12}
    ]
  }'
```

### Predict using Stage (Production Model)
```bash
curl -X POST http://localhost:8000/v1/predict \
  -H "Content-Type: application/json" \
  -d '{
    "stage": "production",
    "instances": [
      {"age": 35, "income": 70000, "tenure_months": 24},
      {"age": 50, "income": 110000, "tenure_months": 60}
    ]
  }'
```

### Predict with Custom Preprocessing
```bash
curl -X POST http://localhost:8000/v1/predict \
  -H "Content-Type: application/json" \
  -d '{
    "stage": "production",
    "instances": [
      {"age": 32, "income": 65000, "tenure_months": 20}
    ],
    "preprocess_config": {
      "missing_strategy": "fill_mean"
    }
  }'
```

### Batch Prediction (Regression)
```bash
curl -X POST http://localhost:8000/v1/predict \
  -H "Content-Type: application/json" \
  -d '{
    "stage": "production",
    "instances": [
      {"day_of_week": 1, "month": 3, "promo_active": 1, "competitor_price": 29.99},
      {"day_of_week": 5, "month": 12, "promo_active": 0, "competitor_price": 34.99},
      {"day_of_week": 7, "month": 6, "promo_active": 1, "competitor_price": 24.99}
    ]
  }'
```

Response (Regression):
```json
{
  "predictions": [1250.5, 980.2, 1450.8],
  "probabilities": null,
  "model_id": "aa0e8400-e29b-41d4-a716-446655440005",
  "model_version": 2,
  "model_type": "xgboost",
  "task_type": "regression",
  "request_id": "b8d2f1a3-...",
  "duration_ms": 38.7
}
```

---

## Feature Importance

### Get SHAP Feature Importance (Model ID)
```bash
curl -X POST http://localhost:8000/v1/importance \
  -H "Content-Type: application/json" \
  -d '{
    "model_id": "990e8400-e29b-41d4-a716-446655440004",
    "max_samples": 1000,
    "method_preference": ["shap", "native"]
  }'
```

Response:
```json
{
  "global_importance": [
    {"feature": "income", "importance": 0.45, "rank": 1},
    {"feature": "tenure_months", "importance": 0.35, "rank": 2},
    {"feature": "age", "importance": 0.20, "rank": 3}
  ],
  "method_used": "shap",
  "model_id": "990e8400-e29b-41d4-a716-446655440004",
  "model_version": 1,
  "request_id": "imp-001",
  "shap_values": null,
  "base_value": 0.3
}
```

### Get Feature Importance with Instance Explanations
```bash
curl -X POST http://localhost:8000/v1/importance \
  -H "Content-Type: application/json" \
  -d '{
    "stage": "production",
    "instances": [
      {"age": 30, "income": 60000, "tenure_months": 18}
    ],
    "max_samples": 500,
    "method_preference": ["shap", "native", "permutation"]
  }'
```

Response (with SHAP values):
```json
{
  "global_importance": [
    {"feature": "income", "importance": 0.45, "rank": 1},
    {"feature": "tenure_months", "importance": 0.35, "rank": 2},
    {"feature": "age", "importance": 0.20, "rank": 3}
  ],
  "method_used": "shap",
  "model_id": "990e8400-e29b-41d4-a716-446655440004",
  "model_version": 1,
  "request_id": "imp-002",
  "shap_values": [
    {
      "age": 0.05,
      "income": 0.12,
      "tenure_months": -0.08
    }
  ],
  "base_value": 0.3
}
```

### Get Feature Importance using Dataset URI
```bash
curl -X POST http://localhost:8000/v1/importance \
  -H "Content-Type: application/json" \
  -d '{
    "experiment_id": "880e8400-e29b-41d4-a716-446655440003",
    "dataset_uri": "gs://my-bucket/datasets/sample_data.parquet",
    "max_samples": 2000
  }'
```

### Get Native Feature Importance (Fallback)
```bash
curl -X POST http://localhost:8000/v1/importance \
  -H "Content-Type: application/json" \
  -d '{
    "stage": "production",
    "method_preference": ["native"]
  }'
```

---

## Error Responses

All errors follow this format:

```json
{
  "error": {
    "code": "validation_error",
    "message": "Request validation failed",
    "details": {
      "errors": [...]
    },
    "request_id": "abc123"
  }
}
```

### Common Error Codes

- `validation_error` (422) - Request validation failed
- `resource_not_found` (404) - Resource not found
- `resource_conflict` (409) - Resource conflict
- `external_service_error` (502) - GCS or Redis error
- `model_training_error` (500) - Training failed
- `data_processing_error` (500) - Data processing failed
- `internal_error` (500) - Unexpected error

---

## Headers

### Standard Request Headers
```bash
-H "Content-Type: application/json"
-H "X-Request-ID: custom-request-id"  # Optional, auto-generated if not provided
```

### Standard Response Headers
```
X-Request-ID: custom-request-id  # Echo back or generated ID
Content-Type: application/json
```

---

## Pagination

All list endpoints support pagination:

```bash
?page=1&page_size=50
```

Response includes:
```json
{
  "items": [...],
  "total": 150,
  "page": 1,
  "page_size": 50
}
```

---

## Testing Tips

### Save Response to File
```bash
curl -X POST http://localhost:8000/v1/splits ... \
  -o response.json
```

### Pretty Print JSON
```bash
curl -X GET http://localhost:8000/v1/splits | jq '.'
```

### Include Response Headers
```bash
curl -i -X GET http://localhost:8000/healthz
```

### Verbose Output
```bash
curl -v -X GET http://localhost:8000/healthz
```

### Set Timeout
```bash
curl --max-time 30 -X POST http://localhost:8000/v1/experiments ...
```
