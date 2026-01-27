# Changelog: Poetry to uv Migration

## Summary

Successfully migrated from Poetry to uv for faster, more efficient dependency management and added a comprehensive CLI for API deployment.

## What Changed

### 1. Package Management (Poetry → uv)

**Before:**
```bash
poetry install
poetry add package
poetry run command
```

**After:**
```bash
uv pip install -e .
uv pip install package
uv run command
```

### 2. pyproject.toml Structure

- ✅ Converted from Poetry format to PEP 621 standard
- ✅ Changed build backend from `poetry-core` to `hatchling`
- ✅ Made ML libraries optional to improve compatibility
- ✅ Added package configuration for wheel building

**Key Changes:**
- `[tool.poetry]` → `[project]`
- `[tool.poetry.dependencies]` → `dependencies = [...]`
- `[tool.poetry.group.dev.dependencies]` → `[project.optional-dependencies]`
- Added `[tool.hatch.build.targets.wheel]` to specify packages

### 3. New CLI Deployment Command

Added `mlapi serve` command with extensive options:

```bash
mlapi serve --workers 4 --port 8000
```

**Available Options:**
- `--host, -h`: Bind host (default: 0.0.0.0)
- `--port, -p`: Bind port (default: 8000)
- `--workers, -w`: Number of worker processes
- `--reload, -r`: Enable auto-reload for development
- `--log-level, -l`: Set log level
- `--access-log/--no-access-log`: Control access logging
- `--proxy-headers`: Enable proxy header support
- `--forwarded-allow-ips`: Trusted IPs for proxy headers
- `--ssl-keyfile`: Path to SSL key file
- `--ssl-certfile`: Path to SSL certificate file
- `--limit-concurrency`: Max concurrent connections
- `--limit-max-requests`: Max requests before worker restart
- `--timeout-keep-alive`: Keep-alive timeout

### 4. Optional Dependencies

ML libraries are now optional to avoid Python version compatibility issues:

```bash
# Base install (API only)
uv pip install -e .

# With ML libraries
uv pip install -e ".[ml]"

# With dev tools
uv pip install -e ".[dev]"

# Everything
uv pip install -e ".[all]"
```

**ML Libraries (optional):**
- CatBoost
- XGBoost
- LightGBM
- SHAP
- Optuna
- scikit-learn

## Benefits

### Speed Improvements
- **10-100x faster** package installation
- **Faster** dependency resolution
- **Instant** virtual environment creation

### Developer Experience
- **Simpler** commands and workflow
- **Better** compatibility with standard Python tooling
- **More flexible** dependency management
- **Easier** CI/CD integration

### Deployment
- **Comprehensive** CLI with all uvicorn options
- **Easy** production deployment configuration
- **Built-in** SSL support
- **Proxy-aware** for reverse proxy setups

## Migration Steps

1. **Install uv:**
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

2. **Create virtual environment:**
   ```bash
   uv venv
   source .venv/bin/activate
   ```

3. **Install dependencies:**
   ```bash
   uv pip install -e ".[all]"
   ```

4. **Test the setup:**
   ```bash
   uv run mlapi --help
   uv run mlapi serve --help
   ```

5. **Start the API:**
   ```bash
   # Development
   uv run mlapi serve --reload

   # Production
   uv run mlapi serve --workers 4 --port 8000
   ```

## Documentation Updates

### New Files
- ✅ `MIGRATION_UV.md` - Complete migration guide
- ✅ `UV_COMMANDS.md` - Quick reference for uv commands
- ✅ `CHANGELOG_UV_MIGRATION.md` - This file

### Updated Files
- ✅ `pyproject.toml` - Converted to PEP 621 format
- ✅ `README.md` - Updated installation and usage instructions
- ✅ `cli/main.py` - Added serve command with deployment options

## Command Reference

### Installation
```bash
# Old (Poetry)
poetry install

# New (uv)
uv pip install -e .
```

### Running Commands
```bash
# Old (Poetry)
poetry run uvicorn app.main:app --reload

# New (uv)
uv run mlapi serve --reload
```

### Building
```bash
# Old (Poetry)
poetry build

# New (uv)
uv build
```

### Testing
```bash
# Old (Poetry)
poetry run pytest

# New (uv)
uv run pytest
```

## Breaking Changes

### None!

The API code itself hasn't changed. Only the tooling and deployment method have been improved.

### Migration Required For:
- CI/CD pipelines (update to use uv instead of poetry)
- Docker builds (update to use uv)
- Developer setup (follow new installation steps)

## Examples

### Development Setup
```bash
# Clone and setup
git clone <repo>
cd ml-api
curl -LsSf https://astral.sh/uv/install.sh | sh
uv venv
source .venv/bin/activate
uv pip install -e ".[dev]"

# Run with auto-reload
uv run mlapi serve --reload --log-level debug
```

### Production Deployment
```bash
# Basic
uv run mlapi serve --workers 4 --port 8000

# With SSL and proxy
uv run mlapi serve \
  --workers 4 \
  --port 8443 \
  --ssl-keyfile /path/to/key.pem \
  --ssl-certfile /path/to/cert.pem \
  --proxy-headers \
  --forwarded-allow-ips="127.0.0.1,10.0.0.0/8"

# With resource limits
uv run mlapi serve \
  --workers 4 \
  --limit-concurrency 1000 \
  --limit-max-requests 10000
```

### Docker Example
```dockerfile
FROM python:3.11-slim

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# Copy project files
WORKDIR /app
COPY pyproject.toml .
COPY app/ ./app/
COPY cli/ ./cli/

# Install dependencies
RUN uv pip install --system -e .

# Run the API
CMD ["mlapi", "serve", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
```

## Troubleshooting

### "command not found: mlapi"
**Solution:** Either activate your venv or use `uv run`:
```bash
source .venv/bin/activate
# or
uv run mlapi serve
```

### Import errors
**Solution:** Install in editable mode:
```bash
uv pip install -e .
```

### ML library compatibility issues
**Solution:** ML libraries are now optional. Install only if needed:
```bash
uv pip install -e ".[ml]"
```

## Next Steps

1. ✅ Update CI/CD pipelines to use uv
2. ✅ Update Docker images to use uv
3. ✅ Update deployment scripts to use `mlapi serve`
4. ✅ Train team on new commands

## Questions?

- See `MIGRATION_UV.md` for detailed migration guide
- See `UV_COMMANDS.md` for command reference
- See `README.md` for updated documentation
- Run `mlapi serve --help` for all deployment options

## Feedback

If you encounter any issues:
1. Check the migration guide: `MIGRATION_UV.md`
2. Check uv docs: https://github.com/astral-sh/uv
3. Open an issue in the project repository
