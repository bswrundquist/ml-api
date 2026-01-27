# Migration Guide: Poetry to uv

This guide helps you migrate from Poetry to uv for dependency management.

## Why uv?

- **10-100x faster** than pip and pip-tools
- **Drop-in replacement** for pip
- **Faster dependency resolution**
- **Better caching**
- **Single binary** - no Python required to install

## Installation

### Install uv

```bash
# macOS and Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"

# With pip
pip install uv

# With pipx
pipx install uv

# With Homebrew
brew install uv
```

## Migration Steps

### 1. Remove Poetry Files (Optional)

```bash
# Remove poetry lock file
rm poetry.lock

# Uninstall poetry (if you want)
pip uninstall poetry
```

### 2. Create Virtual Environment with uv

```bash
# Create virtual environment
uv venv

# Activate it
source .venv/bin/activate  # macOS/Linux
# or
.venv\Scripts\activate  # Windows
```

### 3. Install Dependencies

```bash
# Install the base project (without ML libraries)
uv pip install -e .

# Install with ML libraries (CatBoost, XGBoost, LightGBM, SHAP, etc.)
uv pip install -e ".[ml]"

# Install with development dependencies
uv pip install -e ".[dev]"

# Install everything (base + ML + dev)
uv pip install -e ".[all]"
```

**Note**: ML libraries are now optional to avoid compatibility issues with newer Python versions. If you need the ML features, install with `.[ml]`.

### 4. Generate Lock File (Optional)

```bash
# Generate requirements.txt for reproducible installs
uv pip compile pyproject.toml -o requirements.txt

# For development dependencies
uv pip compile pyproject.toml --extra dev -o requirements-dev.txt
```

### 5. Build Package (Optional)

```bash
# Build wheel and source distribution
uv build

# This creates:
# - dist/ml_api-0.1.0-py3-none-any.whl
# - dist/ml_api-0.1.0.tar.gz
```

## Command Comparison

### Package Management

| Poetry | uv |
|--------|-----|
| `poetry install` | `uv pip install -e .` |
| `poetry add package` | `uv pip install package` |
| `poetry remove package` | `uv pip uninstall package` |
| `poetry update` | `uv pip install -e . --upgrade` |
| `poetry show` | `uv pip list` |
| `poetry run python script.py` | `uv run python script.py` |
| `poetry run pytest` | `uv run pytest` |

### Virtual Environment

| Poetry | uv |
|--------|-----|
| `poetry shell` | `source .venv/bin/activate` |
| `poetry env info` | `which python` (after activation) |
| `poetry env remove` | `rm -rf .venv` |

### Building & Publishing

| Poetry | uv |
|--------|-----|
| `poetry build` | `uv build` |
| `poetry publish` | `uv publish` |

## Running the Application

### Development

```bash
# Old (Poetry)
poetry run uvicorn app.main:app --reload

# New (uv)
mlapi serve --reload

# Or directly
uv run uvicorn app.main:app --reload
```

### Production

```bash
# Old (Poetry)
poetry run uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4

# New (uv) - Using CLI
mlapi serve --host 0.0.0.0 --port 8000 --workers 4

# Or directly
uv run uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
```

## Updated pyproject.toml Structure

The main changes in `pyproject.toml`:

### Before (Poetry)

```toml
[tool.poetry]
name = "ml-api"
version = "0.1.0"

[tool.poetry.dependencies]
python = "^3.10"
fastapi = "^0.109.0"

[tool.poetry.group.dev.dependencies]
pytest = "^7.4.4"

[tool.poetry.scripts]
mlapi = "cli.main:app"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

### After (uv/PEP 621)

```toml
[project]
name = "ml-api"
version = "0.1.0"
requires-python = ">=3.10"
dependencies = [
    "fastapi>=0.109.0",
    # Core dependencies only
]

[project.optional-dependencies]
ml = [
    # ML libraries are now optional
    "catboost>=1.2.2",
    "xgboost>=2.0.3",
    # ...
]

dev = [
    "pytest>=7.4.4",
    # ...
]

all = [
    "ml-api[ml,dev]",
]

[project.scripts]
mlapi = "cli.main:app"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["app", "cli"]
```

## New CLI Deployment Features

The project now includes a powerful `mlapi serve` command with extensive deployment options:

```bash
# Basic usage
mlapi serve

# Development mode
mlapi serve --reload --log-level debug

# Production with multiple workers
mlapi serve --workers 4 --port 8000

# With SSL
mlapi serve --ssl-keyfile key.pem --ssl-certfile cert.pem

# Behind reverse proxy
mlapi serve --proxy-headers --forwarded-allow-ips="127.0.0.1,10.0.0.0/8"

# With resource limits
mlapi serve --workers 4 --limit-concurrency 1000 --limit-max-requests 10000
```

### Available Options

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
- `--timeout-keep-alive`: Keep-alive timeout in seconds

Run `mlapi serve --help` for all options.

## CI/CD Updates

If you have CI/CD pipelines, update them:

### GitHub Actions Example

```yaml
# Before
- name: Install dependencies
  run: |
    pip install poetry
    poetry install

# After
- name: Install uv
  uses: astral-sh/setup-uv@v1

- name: Install dependencies
  run: uv pip install -e ".[dev]"
```

### Docker Example

```dockerfile
# Before
FROM python:3.11
RUN pip install poetry
COPY pyproject.toml poetry.lock ./
RUN poetry install --no-dev

# After
FROM python:3.11
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv
COPY pyproject.toml ./
RUN uv pip install --system -e .
```

## Troubleshooting

### "Module not found" errors

Make sure your virtual environment is activated:

```bash
source .venv/bin/activate
```

### Slow dependency resolution

uv is much faster, but if you experience issues:

```bash
# Clear cache
uv cache clean

# Reinstall
uv pip install -e . --reinstall
```

### Import errors in CLI

Make sure the package is installed in editable mode:

```bash
uv pip install -e .
```

## Benefits

After migration, you'll experience:

- **Faster installs**: 10-100x faster than Poetry
- **Better caching**: Shared cache across projects
- **Simpler workflows**: Standard Python packaging (PEP 621)
- **Less disk space**: More efficient dependency storage
- **Better compatibility**: Works with standard pip ecosystem

## Getting Help

- uv documentation: https://github.com/astral-sh/uv
- PEP 621 (project metadata): https://peps.python.org/pep-0621/
- Report issues: Create an issue in the project repository
