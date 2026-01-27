# uv Commands Quick Reference

This is a quick reference guide for common uv commands used in this project.

## Installation

```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
```

## Virtual Environment

```bash
# Create virtual environment
uv venv

# Create with specific Python version
uv venv --python 3.11

# Activate virtual environment
source .venv/bin/activate  # macOS/Linux
.venv\Scripts\activate     # Windows

# Deactivate
deactivate
```

## Package Management

```bash
# Install project in editable mode
uv pip install -e .

# Install with dev dependencies
uv pip install -e ".[dev]"

# Install a new package
uv pip install package-name

# Install specific version
uv pip install "package-name==1.2.3"

# Install from requirements.txt
uv pip install -r requirements.txt

# Uninstall a package
uv pip uninstall package-name

# List installed packages
uv pip list

# Show package details
uv pip show package-name

# Upgrade a package
uv pip install --upgrade package-name

# Upgrade all packages
uv pip install -e . --upgrade
```

## Building

```bash
# Build wheel and source distribution
uv build

# Build only wheel
uv build --wheel

# Build only source distribution
uv build --sdist

# Output is in dist/
# - dist/ml_api-0.1.0-py3-none-any.whl
# - dist/ml_api-0.1.0.tar.gz
```

## Publishing

```bash
# Publish to PyPI
uv publish

# Publish to Test PyPI
uv publish --publish-url https://test.pypi.org/legacy/

# Publish with token
uv publish --token $PYPI_TOKEN
```

## Lock Files

```bash
# Generate requirements.txt
uv pip compile pyproject.toml -o requirements.txt

# With dev dependencies
uv pip compile pyproject.toml --extra dev -o requirements-dev.txt

# Install from lock file
uv pip sync requirements.txt
```

## Running Commands

```bash
# Run Python script
uv run python script.py

# Run installed CLI tool
uv run mlapi serve --reload

# Run pytest
uv run pytest

# Run with coverage
uv run pytest --cov=app

# Format code
uv run black app/ cli/ tests/

# Lint
uv run ruff check app/ cli/ tests/

# Type check
uv run mypy app/ cli/
```

## This Project Specific Commands

```bash
# Initial setup (base API without ML libraries)
uv venv
source .venv/bin/activate
uv pip install -e .

# Install with ML libraries (recommended for full functionality)
uv pip install -e ".[ml]"

# Install with dev dependencies
uv pip install -e ".[dev]"

# Install everything (base + ML + dev)
uv pip install -e ".[all]"

# Run API (development)
uv run mlapi serve --reload --log-level debug

# Run API (production)
uv run mlapi serve --workers 4 --port 8000

# Run tests
uv run pytest

# Format and lint
uv run black app/ cli/ tests/
uv run ruff check app/ cli/ tests/

# Build package
uv build

# Check wheel contents
unzip -l dist/ml_api-0.1.0-py3-none-any.whl
```

### Optional Dependencies

The project uses optional dependency groups:

- **Base install** (`uv pip install -e .`): Core API, database, and serving functionality
- **ML extras** (`.[ml]`): CatBoost, XGBoost, LightGBM, SHAP, Optuna, scikit-learn
- **Dev extras** (`.[dev]`): Testing, linting, formatting tools
- **All extras** (`.[all]`): Everything (base + ML + dev)

Choose the appropriate install based on your needs:

```bash
# Just run the API server
uv pip install -e .

# Full ML functionality
uv pip install -e ".[ml]"

# Development work
uv pip install -e ".[dev]"

# Everything
uv pip install -e ".[all]"
```

## Cache Management

```bash
# Show cache info
uv cache dir

# Clear cache
uv cache clean

# Clear specific package from cache
uv cache clean package-name
```

## Useful Flags

```bash
# Install without cache
uv pip install --no-cache package-name

# Reinstall package
uv pip install --reinstall package-name

# Force reinstall (ignore installed packages)
uv pip install --force-reinstall package-name

# Install in system Python (not recommended)
uv pip install --system package-name

# Verbose output
uv pip install -v package-name

# Quiet output
uv pip install -q package-name
```

## Comparison with Poetry

| Task | Poetry | uv |
|------|--------|-----|
| Install project | `poetry install` | `uv pip install -e .` |
| Add dependency | `poetry add pkg` | `uv pip install pkg` then update `pyproject.toml` |
| Remove dependency | `poetry remove pkg` | `uv pip uninstall pkg` then update `pyproject.toml` |
| Run command | `poetry run cmd` | `uv run cmd` or just `cmd` if venv active |
| Build | `poetry build` | `uv build` |
| Publish | `poetry publish` | `uv publish` |
| Show packages | `poetry show` | `uv pip list` |
| Update packages | `poetry update` | `uv pip install -e . --upgrade` |

## Tips

1. **Always activate your virtual environment** before running commands (or use `uv run`)
2. **Update pyproject.toml manually** when adding/removing dependencies (unlike Poetry which does this automatically)
3. **Use `uv build`** instead of `python -m build` for faster builds
4. **uv is fast!** It's 10-100x faster than pip/poetry for most operations
5. **Cache is shared** across projects, saving disk space and time

## Troubleshooting

### Package not found after install
```bash
# Make sure venv is activated
source .venv/bin/activate

# Or use uv run
uv run python
```

### Import errors
```bash
# Reinstall in editable mode
uv pip install -e .
```

### Slow performance
```bash
# Clear cache and retry
uv cache clean
uv pip install -e .
```

### Command not found: mlapi
```bash
# Install in editable mode
uv pip install -e .

# Ensure venv is activated
source .venv/bin/activate
```

## Resources

- [uv Documentation](https://github.com/astral-sh/uv)
- [uv GitHub](https://github.com/astral-sh/uv)
- [PEP 621 - Project Metadata](https://peps.python.org/pep-0621/)
