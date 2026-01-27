# PyPI Setup & Publishing Guide

Complete guide to set up and publish `ml-api` to PyPI.

## Prerequisites

1. **PyPI Account**
   - Create account at https://pypi.org/account/register/
   - Verify email address

2. **Test PyPI Account** (for testing)
   - Create account at https://test.pypi.org/account/register/

3. **GitHub Repository**
   - Repository must be public for PyPI trusted publishing
   - Admin access to repository settings

## Setup Options

### Option 1: Trusted Publishing (Recommended) ⭐

No API tokens needed! More secure and easier to manage.

#### Step 1: Configure PyPI Trusted Publishing

1. Go to https://pypi.org/manage/account/publishing/

2. Click "Add a new pending publisher"

3. Fill in the form:
   ```
   PyPI Project Name: ml-api
   Owner: yourusername
   Repository name: ml-api
   Workflow name: publish.yml
   Environment name: (leave blank)
   ```

4. Click "Add"

#### Step 2: Create First Release

Since the project doesn't exist on PyPI yet, you need to create the first release manually:

```bash
# Build the package
poetry build

# Upload to PyPI (will prompt for username/password or token)
poetry publish

# OR use twine
pip install twine
twine upload dist/*
```

After the first manual upload, all subsequent releases will use trusted publishing automatically.

#### Step 3: Verify Setup

1. Create a test release on GitHub
2. Check the "Publish to PyPI" workflow runs successfully
3. Verify package appears on PyPI

### Option 2: API Token

If you prefer using API tokens or can't use trusted publishing:

#### Step 1: Create PyPI API Token

1. Go to https://pypi.org/manage/account/token/
2. Create a token with scope: "Entire account" or specific to "ml-api"
3. Copy the token (starts with `pypi-`)

#### Step 2: Add Token to GitHub Secrets

1. Go to your repository on GitHub
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Name: `PYPI_API_TOKEN`
5. Value: Paste your PyPI token
6. Click "Add secret"

#### Step 3: Test PyPI Token (Optional)

For testing before production:

1. Create Test PyPI token: https://test.pypi.org/manage/account/token/
2. Add as `TEST_PYPI_API_TOKEN` in GitHub secrets

## Publishing Workflow

### Automated Release (After Setup)

1. **Update Code & Tests**
   ```bash
   # Make your changes
   git add .
   git commit -m "feat: add new feature"
   git push
   ```

2. **Bump Version**
   - Go to: Actions → "Version Bump" → "Run workflow"
   - Select bump type (patch, minor, major)
   - Review and merge the created PR

3. **Create GitHub Release**
   - Go to: Releases → "Create a new release"
   - Tag: `v0.2.0` (use the version from previous step)
   - Title: `v0.2.0`
   - Description: Copy from CHANGELOG.md
   - Click "Publish release"

4. **Automatic Publication**
   - GitHub Actions will automatically:
     - Run tests
     - Build package
     - Publish to PyPI
     - Build and push Docker images

5. **Verify**
   ```bash
   # Check PyPI
   pip install --upgrade ml-api

   # Verify version
   python -c "import app; print(app.__version__)"
   ```

### Manual Publishing (Local)

For emergency releases or troubleshooting:

```bash
# 1. Bump version
poetry version patch  # or minor, major

# 2. Update __init__.py
echo "__version__ = \"$(poetry version -s)\"" > app/__init__.py

# 3. Update CHANGELOG.md
# (manually edit)

# 4. Build
poetry build

# 5. Check package
twine check dist/*

# 6. Upload to Test PyPI (optional)
twine upload --repository testpypi dist/*

# 7. Test installation
pip install --index-url https://test.pypi.org/simple/ ml-api

# 8. Upload to PyPI
poetry publish
# OR
twine upload dist/*

# 9. Tag and push
git tag v$(poetry version -s)
git push --tags
```

## First Time Setup Checklist

- [ ] PyPI account created and verified
- [ ] Test PyPI account created (optional)
- [ ] Repository is public on GitHub
- [ ] Choose publishing method (trusted or token)
- [ ] If using trusted publishing:
  - [ ] Pending publisher configured on PyPI
  - [ ] First manual upload completed
- [ ] If using API token:
  - [ ] PyPI token created
  - [ ] Token added to GitHub secrets as `PYPI_API_TOKEN`
  - [ ] Test PyPI token added (optional)
- [ ] Package metadata in pyproject.toml is correct
- [ ] LICENSE file exists
- [ ] README.md is complete
- [ ] CHANGELOG.md is initialized
- [ ] First release workflow tested

## Package Metadata Checklist

Ensure `pyproject.toml` has all required fields:

```toml
[tool.poetry]
name = "ml-api"                          # ✓ Package name on PyPI
version = "0.1.0"                        # ✓ Current version
description = "..."                      # ✓ Short description
authors = ["Name <email@example.com>"]   # ✓ Author info
license = "MIT"                          # ✓ License
readme = "README.md"                     # ✓ Readme file
homepage = "https://github.com/..."      # ✓ Project homepage
repository = "https://github.com/..."    # ✓ Source repository
keywords = [...]                         # ✓ Keywords for search
classifiers = [...]                      # ✓ PyPI classifiers
```

## Testing Before Release

### Local Testing

```bash
# Install in development mode
poetry install

# Run all tests
poetry run pytest

# Run type checking
poetry run mypy app/ cli/

# Run linting
poetry run black --check app/ cli/ tests/
poetry run ruff check app/ cli/ tests/

# Build package
poetry build

# Install from local build
pip install dist/ml_api-0.1.0-py3-none-any.whl

# Test CLI
mlapi --help
mlapi version
```

### Test PyPI Testing

```bash
# Upload to Test PyPI
poetry publish -r testpypi

# Create new virtual environment
python -m venv test-env
source test-env/bin/activate

# Install from Test PyPI
pip install --index-url https://test.pypi.org/simple/ \
  --extra-index-url https://pypi.org/simple/ \
  ml-api

# Test functionality
python -c "import app; print(app.__version__)"

# Clean up
deactivate
rm -rf test-env
```

## Common Issues & Solutions

### Issue: "Package already exists"

**Problem**: Trying to upload a version that already exists on PyPI.

**Solution**:
```bash
# Bump version and try again
poetry version patch
poetry build
poetry publish
```

### Issue: "Invalid credentials"

**Problem**: API token is incorrect or expired.

**Solution**:
- Verify token in GitHub secrets
- Create new token if expired
- Ensure token has correct scope

### Issue: "Trusted publishing failed"

**Problem**: GitHub Actions can't authenticate with PyPI.

**Solution**:
- Verify pending publisher configuration on PyPI
- Ensure workflow name matches exactly: `publish.yml`
- Check that repository is public
- Verify you've done the first manual upload

### Issue: "Package validation failed"

**Problem**: Package metadata is invalid.

**Solution**:
```bash
# Check package with twine
pip install twine
twine check dist/*

# Fix issues in pyproject.toml
# Rebuild
poetry build
```

### Issue: "Tests failing in CI"

**Problem**: Tests pass locally but fail in CI.

**Solution**:
- Check environment variables in workflow
- Verify all dependencies in pyproject.toml
- Test in clean environment locally
- Check Python version compatibility

## Monitoring Releases

### PyPI Package Page

- View: https://pypi.org/project/ml-api/
- Check download statistics
- Monitor for issues reported

### GitHub Releases

- View: https://github.com/yourusername/ml-api/releases
- Check workflow runs: https://github.com/yourusername/ml-api/actions

### Download Statistics

```bash
# Using pypistats (install: pip install pypistats)
pypistats recent ml-api
pypistats overall ml-api
```

## Security Best Practices

1. **Never commit tokens** to repository
2. **Use repository secrets** for sensitive data
3. **Rotate tokens** periodically
4. **Use trusted publishing** when possible (more secure)
5. **Enable 2FA** on PyPI account
6. **Scope tokens** to specific projects when possible
7. **Review permissions** regularly

## Resources

- PyPI: https://pypi.org/
- Test PyPI: https://test.pypi.org/
- Poetry Publishing: https://python-poetry.org/docs/libraries/#publishing-to-pypi
- Trusted Publishing Guide: https://docs.pypi.org/trusted-publishers/
- PyPI Classifiers: https://pypi.org/classifiers/
- Semantic Versioning: https://semver.org/

## Support

For PyPI-specific issues:
- PyPI Help: https://pypi.org/help/
- GitHub Discussions: https://github.com/pypi/warehouse/discussions
- Poetry Docs: https://python-poetry.org/docs/
