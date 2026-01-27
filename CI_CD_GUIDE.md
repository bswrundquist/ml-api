# CI/CD Guide

Complete guide to the Continuous Integration and Continuous Deployment setup for ml-api.

## Overview

This project uses **GitHub Actions** for automated testing, building, and publishing to PyPI.

### Workflows

1. **CI** (`.github/workflows/ci.yml`) - Runs on every push/PR
2. **Publish** (`.github/workflows/publish.yml`) - Runs on releases
3. **Version Bump** (`.github/workflows/version-bump.yml`) - Manual version management

## CI Workflow

**Trigger**: Push to `main` or `develop`, Pull Requests

**Jobs**:

### 1. Lint & Format Check
- Black formatting
- Ruff linting
- mypy type checking

### 2. Test (Matrix)
- Tests on Python 3.10, 3.11, 3.12
- PostgreSQL 15 + Redis 7 services
- Full test suite with coverage
- Coverage report to Codecov

### 3. Security Scan
- Safety (dependency vulnerabilities)
- Bandit (security linting)

### 4. Build
- Package building
- Metadata validation
- Artifact upload

### 5. Docker
- Docker image build
- Image testing

## Publish Workflow

**Trigger**: GitHub Release published

**Jobs**:

### 1. Build and Publish to PyPI
- Version extraction from tag
- Test suite execution
- Package building
- PyPI publication (trusted publishing or token)
- Release notes generation

### 2. Docker Image Publishing
- Multi-architecture builds (amd64, arm64)
- Push to GitHub Container Registry
- Optional Docker Hub publishing
- Version tagging (latest, semver)

### 3. Notification
- Success notification with links

## Version Bump Workflow

**Trigger**: Manual dispatch

**Inputs**:
- `version`: patch, minor, major, prerelease
- `prerelease_type`: alpha, beta, rc

**Process**:
1. Bumps version in `pyproject.toml`
2. Updates `app/__init__.py`
3. Updates `CHANGELOG.md`
4. Creates Pull Request

## Setup Instructions

### 1. GitHub Repository Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/ml-api.git
cd ml-api

# Push to your repository
git remote set-url origin https://github.com/yourusername/ml-api.git
git push -u origin main
```

### 2. Enable GitHub Actions

1. Go to repository Settings → Actions → General
2. Set "Workflow permissions" to "Read and write permissions"
3. Enable "Allow GitHub Actions to create and approve pull requests"

### 3. Configure Secrets

Go to Settings → Secrets and variables → Actions

**Required Secrets**:

For PyPI publishing (choose one method):

**Option A: Trusted Publishing** (Recommended)
- No secrets needed!
- Follow PyPI setup in `PYPI_SETUP.md`

**Option B: API Token**
- `PYPI_API_TOKEN`: Your PyPI API token
- `TEST_PYPI_API_TOKEN`: Test PyPI token (optional)

**Optional Secrets**:
- `DOCKERHUB_USERNAME`: Docker Hub username
- `DOCKERHUB_TOKEN`: Docker Hub access token
- `CODECOV_TOKEN`: Codecov token (for private repos)

### 4. Configure Branch Protection

Settings → Branches → Add rule for `main`:

- [x] Require a pull request before merging
- [x] Require status checks to pass before merging
  - Select: `lint`, `test`, `build`
- [x] Require branches to be up to date before merging
- [x] Do not allow bypassing the above settings

### 5. Test the CI Pipeline

```bash
# Create a test branch
git checkout -b test-ci

# Make a small change
echo "# Test CI" >> README.md

# Commit and push
git add README.md
git commit -m "test: CI pipeline"
git push origin test-ci

# Create Pull Request on GitHub
# Verify all checks pass
```

## Release Process

### Automated Release (Recommended)

#### Step 1: Bump Version

1. Go to **Actions** → **Version Bump**
2. Click **Run workflow**
3. Select version bump type (e.g., `minor` for 0.1.0 → 0.2.0)
4. Click **Run workflow**

This creates a PR with:
- Updated version in `pyproject.toml`
- Updated `app/__init__.py`
- Updated `CHANGELOG.md`

#### Step 2: Review and Merge PR

1. Review the version bump PR
2. Ensure CHANGELOG.md has all changes since last release
3. Wait for CI to pass
4. Merge the PR

#### Step 3: Create GitHub Release

1. Go to **Releases** → **Draft a new release**
2. Click **Choose a tag** → Create new tag: `v0.2.0`
3. **Release title**: `v0.2.0`
4. **Description**: Copy from CHANGELOG.md
5. Click **Publish release**

#### Step 4: Automatic Publication

The publish workflow will automatically:
- ✅ Run full test suite
- ✅ Build package
- ✅ Publish to PyPI
- ✅ Build Docker images (multi-arch)
- ✅ Push to GitHub Container Registry
- ✅ Attach artifacts to release

#### Step 5: Verify

```bash
# Check PyPI
pip install --upgrade ml-api
python -c "import app; print(app.__version__)"  # Should show 0.2.0

# Check Docker
docker pull ghcr.io/yourusername/ml-api:0.2.0
docker pull ghcr.io/yourusername/ml-api:latest
```

### Manual Release (Emergency)

```bash
# 1. Bump version
poetry version patch
NEW_VERSION=$(poetry version -s)

# 2. Update __init__.py
echo "__version__ = \"$NEW_VERSION\"" > app/__init__.py

# 3. Update CHANGELOG.md
# Edit manually

# 4. Commit
git add pyproject.toml app/__init__.py CHANGELOG.md
git commit -m "chore: bump version to $NEW_VERSION"
git push

# 5. Tag
git tag v$NEW_VERSION
git push --tags

# 6. Build and publish
poetry build
poetry publish  # or: twine upload dist/*

# 7. Create GitHub release (optional but recommended)
```

## Pre-Release Testing

### Test on Test PyPI

```bash
# Trigger manual workflow
# Actions → Publish to PyPI → Run workflow
# Check: "Publish to Test PyPI instead of PyPI"

# Test installation
pip install --index-url https://test.pypi.org/simple/ \
  --extra-index-url https://pypi.org/simple/ \
  ml-api
```

### Local CI Simulation

```bash
# Run full CI pipeline locally
make ci

# Individual steps
make lint        # Linting
make test-cov    # Tests with coverage
make build       # Package building
make docker-build # Docker image
```

## Monitoring

### GitHub Actions Dashboard

- View all workflows: https://github.com/yourusername/ml-api/actions
- Check specific run details
- Download artifacts
- View logs

### PyPI Package

- Package page: https://pypi.org/project/ml-api/
- Download statistics
- Version history

### Docker Images

- GHCR: https://github.com/yourusername/ml-api/pkgs/container/ml-api
- Docker Hub: https://hub.docker.com/r/yourusername/ml-api

### Codecov

- Coverage reports: https://codecov.io/gh/yourusername/ml-api
- Coverage trends
- File-level coverage

## Troubleshooting

### CI Failures

**Tests failing**:
```bash
# Run tests locally
make test

# With coverage
make test-cov

# Verbose
poetry run pytest -vv
```

**Linting failures**:
```bash
# Check locally
make lint

# Auto-fix
make format
make ruff-fix
```

**Type checking failures**:
```bash
# Run mypy locally
make mypy

# Fix type issues in code
```

### Publish Failures

**PyPI upload fails - "File already exists"**:
- You can't re-upload the same version to PyPI
- Bump version and try again
- Delete old builds: `make clean`

**PyPI authentication fails**:
- Check `PYPI_API_TOKEN` secret is set correctly
- Or verify trusted publishing is configured
- Ensure token hasn't expired

**Tests fail in publish workflow**:
- Tests must pass before publishing
- Fix the issue and create a new release
- Or revert the problematic commit

### Docker Build Failures

**Build fails in CI**:
```bash
# Test locally
make docker-build

# Check Dockerfile syntax
docker build --no-cache -t ml-api:test .

# Run container
docker run --rm ml-api:test python -c "import app; print('OK')"
```

**Multi-arch build fails**:
- Usually due to platform-specific dependencies
- Check if all dependencies support both amd64 and arm64
- May need to add platform-specific build steps

### Version Bump Failures

**PR creation fails**:
- Check workflow has write permissions
- Verify "Allow GitHub Actions to create PRs" is enabled

**Merge conflicts**:
- Manually resolve conflicts in `pyproject.toml`
- Update `app/__init__.py` with correct version
- Update `CHANGELOG.md`

## Best Practices

### Commit Messages

Follow conventional commits:

```
feat: add new feature
fix: bug fix
docs: documentation update
chore: maintenance task
test: test updates
refactor: code refactoring
perf: performance improvement
ci: CI/CD changes
```

### Branch Strategy

- `main`: Production-ready code
- `develop`: Integration branch (optional)
- `feature/xxx`: Feature branches
- `fix/xxx`: Bug fix branches
- `hotfix/xxx`: Urgent fixes

### Pull Requests

- Create PR for all changes
- Wait for CI to pass
- Get at least one review (if team)
- Squash and merge or rebase

### Versioning

Follow Semantic Versioning:

- **Patch** (0.1.X): Bug fixes, no new features
- **Minor** (0.X.0): New features, backward compatible
- **Major** (X.0.0): Breaking changes

Pre-releases:
- `0.2.0-alpha.1`: Early testing
- `0.2.0-beta.1`: Feature complete, testing
- `0.2.0-rc.1`: Release candidate

### CHANGELOG

Keep CHANGELOG.md updated:

- Add entries as you make changes
- Group by: Added, Changed, Fixed, Deprecated, Removed, Security
- Include PR/issue links
- Update before each release

## Maintenance

### Regular Tasks

**Weekly**:
- Review open PRs
- Check CI status
- Review dependabot alerts

**Monthly**:
- Update dependencies: `make update`
- Review and update documentation
- Check for security updates: `make security`

**Per Release**:
- Review CHANGELOG
- Test on Test PyPI
- Verify all checks pass
- Update documentation if needed

### Dependency Updates

```bash
# Update all dependencies
make update

# Or manually
poetry update

# Check for outdated packages
poetry show --outdated

# Update specific package
poetry update package-name
```

### Security Updates

```bash
# Check for vulnerabilities
make security

# Or individually
poetry run safety check
poetry run bandit -r app/ cli/
```

## Resources

- GitHub Actions Docs: https://docs.github.com/actions
- Poetry Publishing: https://python-poetry.org/docs/libraries/
- PyPI Trusted Publishing: https://docs.pypi.org/trusted-publishers/
- Semantic Versioning: https://semver.org/
- Conventional Commits: https://www.conventionalcommits.org/

## Support

For CI/CD issues:
- Check workflow runs: https://github.com/yourusername/ml-api/actions
- Review this guide
- Create an issue: https://github.com/yourusername/ml-api/issues
