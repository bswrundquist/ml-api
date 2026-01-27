# Release Guide

This document describes the release process for ml-api.

## Overview

We use semantic versioning (SemVer) and automated GitHub Actions workflows for releases.

### Version Format

```
MAJOR.MINOR.PATCH[-PRERELEASE]
```

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)
- **PRERELEASE**: alpha, beta, rc (optional)

Examples:
- `0.1.0` - Initial release
- `0.2.0` - New features
- `0.2.1` - Bug fix
- `1.0.0-beta.1` - Pre-release
- `1.0.0` - Production release

## Release Process

### Automated Release (Recommended)

#### 1. Bump Version

Use the GitHub Actions workflow to bump the version:

```bash
# Go to: Actions > Version Bump > Run workflow
# Select version bump type: patch, minor, major, prepatch, preminor, premajor, prerelease
```

This will:
- Create a new branch
- Bump version in `pyproject.toml`
- Update `app/__init__.py` with new version
- Update `CHANGELOG.md`
- Create a pull request

#### 2. Review and Merge PR

- Review the version bump PR
- Verify CHANGELOG.md has all relevant changes
- Ensure CI passes
- Merge the PR to main

#### 3. Create GitHub Release

```bash
# Go to: Releases > Create a new release
# Tag: v0.1.0 (must start with 'v')
# Title: v0.1.0
# Description: Copy from CHANGELOG.md
# Click "Publish release"
```

This will automatically:
- Run the full test suite
- Build the package
- Publish to PyPI (using trusted publishing or API token)
- Build and push Docker images to GHCR
- Attach distribution files to the release

### Manual Release (Alternative)

#### 1. Update Version

```bash
# Bump version with Poetry
poetry version patch  # or minor, major

# Update __init__.py
NEW_VERSION=$(poetry version -s)
echo "__version__ = \"$NEW_VERSION\"" > app/__init__.py
```

#### 2. Update CHANGELOG.md

Add a new version entry:

```markdown
## [0.2.0] - 2024-01-27

### Added
- New feature X
- New feature Y

### Changed
- Updated behavior of Z

### Fixed
- Bug fix for issue #123
```

#### 3. Commit and Tag

```bash
git add pyproject.toml app/__init__.py CHANGELOG.md
git commit -m "chore: release v0.2.0"
git tag v0.2.0
git push origin main --tags
```

#### 4. Create GitHub Release

Go to GitHub Releases and create a new release with the tag.

## PyPI Setup

### Option 1: Trusted Publishing (Recommended)

Set up PyPI trusted publishing (no API tokens needed):

1. Go to https://pypi.org/manage/account/publishing/
2. Add new publisher:
   - **PyPI Project Name**: `ml-api`
   - **Owner**: `yourusername`
   - **Repository name**: `ml-api`
   - **Workflow name**: `publish.yml`
   - **Environment name**: (leave blank)

### Option 2: API Token

If not using trusted publishing:

1. Create PyPI API token: https://pypi.org/manage/account/token/
2. Add to GitHub Secrets as `PYPI_API_TOKEN`
3. For Test PyPI, create token and add as `TEST_PYPI_API_TOKEN`

## Pre-release Testing

### Test on Test PyPI

```bash
# Trigger manual workflow
# Go to: Actions > Publish to PyPI > Run workflow
# Select "Publish to Test PyPI"
```

Install from Test PyPI:

```bash
pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple/ ml-api
```

### Local Testing

```bash
# Build locally
poetry build

# Test installation
pip install dist/ml_api-0.1.0-py3-none-any.whl

# Verify import
python -c "import app; print(app.__version__)"

# Test CLI
mlapi version
```

## Docker Images

Docker images are automatically published to:

- GitHub Container Registry: `ghcr.io/yourusername/ml-api:0.1.0`
- Docker Hub (optional): `yourusername/ml-api:0.1.0`

Tags created:
- `latest` (for releases from main branch)
- `0.1.0` (exact version)
- `0.1` (minor version)
- `0` (major version)

### Docker Hub Setup (Optional)

Add secrets to GitHub:
- `DOCKERHUB_USERNAME`: Your Docker Hub username
- `DOCKERHUB_TOKEN`: Docker Hub access token

## Release Checklist

### Pre-release

- [ ] All tests passing on main branch
- [ ] CHANGELOG.md updated with all changes
- [ ] Documentation updated (if needed)
- [ ] Version bumped appropriately
- [ ] Breaking changes documented
- [ ] Migration guide written (if breaking changes)

### Release

- [ ] Version bump PR merged
- [ ] GitHub release created with proper tag
- [ ] PyPI publication successful
- [ ] Docker images published
- [ ] Release notes complete

### Post-release

- [ ] Verify package on PyPI: https://pypi.org/project/ml-api/
- [ ] Test installation: `pip install ml-api`
- [ ] Verify Docker image: `docker pull ghcr.io/yourusername/ml-api:latest`
- [ ] Update documentation site (if applicable)
- [ ] Announce release (social media, blog, etc.)

## Hotfix Releases

For urgent bug fixes:

1. Create hotfix branch from latest release tag:
   ```bash
   git checkout -b hotfix/0.1.1 v0.1.0
   ```

2. Fix the bug and commit

3. Bump patch version:
   ```bash
   poetry version patch
   ```

4. Update CHANGELOG.md

5. Merge to main and create release

## Rollback

If a release has issues:

1. **Do not delete PyPI releases** (not allowed)
2. Release a new patch version with the fix
3. Update documentation to warn about the problematic version
4. Mark Docker images as deprecated if needed

## Version Bump Examples

### Patch Release (Bug Fixes)

```bash
# Current: 0.1.0
poetry version patch
# New: 0.1.1
```

### Minor Release (New Features)

```bash
# Current: 0.1.1
poetry version minor
# New: 0.2.0
```

### Major Release (Breaking Changes)

```bash
# Current: 0.2.0
poetry version major
# New: 1.0.0
```

### Pre-release

```bash
# Current: 0.2.0
poetry version preminor beta
# New: 0.3.0-beta.1

poetry version prerelease
# New: 0.3.0-beta.2
```

## Troubleshooting

### PyPI Upload Fails

**Error**: "File already exists"
- PyPI doesn't allow re-uploading the same version
- Bump version and try again

**Error**: "Invalid credentials"
- Check PYPI_API_TOKEN secret
- Verify trusted publishing setup

### Docker Build Fails

- Check Dockerfile syntax
- Verify all dependencies install correctly
- Test locally: `docker build -t ml-api:test .`

### Tests Fail in CI

- Run tests locally first: `poetry run pytest`
- Check if all dependencies are in pyproject.toml
- Verify environment variables are set

## Support

For release issues:
- Create an issue: https://github.com/yourusername/ml-api/issues
- Check workflow runs: https://github.com/yourusername/ml-api/actions
- Review previous releases: https://github.com/yourusername/ml-api/releases
