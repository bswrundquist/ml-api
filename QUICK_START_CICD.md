# Quick Start: CI/CD & PyPI Publishing

Get your ml-api project from code to PyPI in 5 steps.

## Prerequisites

✅ GitHub repository (public)
✅ PyPI account
✅ Poetry installed locally

## Step 1: Initial Setup (5 minutes)

### A. Clone and Configure

```bash
# Clone your repository
git clone https://github.com/yourusername/ml-api.git
cd ml-api

# Install dependencies
make install
# OR: poetry install

# Create .env file
cp .env.example .env
# Edit .env with your settings
```

### B. Update Project Metadata

Edit `pyproject.toml`:

```toml
[tool.poetry]
name = "ml-api"  # Your package name (must be unique on PyPI)
authors = ["Your Name <your.email@example.com>"]
homepage = "https://github.com/yourusername/ml-api"
repository = "https://github.com/yourusername/ml-api"
```

### C. Verify Locally

```bash
# Run tests
make test

# Check linting
make lint

# Build package
make build
```

## Step 2: Configure GitHub (3 minutes)

### A. Enable Actions

1. Go to your repo: Settings → Actions → General
2. Set **Workflow permissions**: "Read and write permissions"
3. Enable: "Allow GitHub Actions to create and approve pull requests"

### B. Set Branch Protection (Optional but Recommended)

Settings → Branches → Add rule for `main`:
- ✅ Require pull request before merging
- ✅ Require status checks: `lint`, `test`, `build`

## Step 3: PyPI Setup (5 minutes)

**Choose ONE method:**

### Option A: Trusted Publishing ⭐ Recommended

No API tokens needed!

1. **First, create the package on PyPI manually**:
   ```bash
   poetry build
   poetry publish
   # Enter your PyPI username and password
   ```

2. **Configure trusted publishing**:
   - Go to: https://pypi.org/manage/account/publishing/
   - Click "Add a new pending publisher"
   - Fill in:
     - **PyPI Project Name**: `ml-api`
     - **Owner**: `yourusername` (your GitHub username)
     - **Repository**: `ml-api`
     - **Workflow name**: `publish.yml`
     - **Environment**: (leave blank)
   - Click "Add"

Done! Future releases will publish automatically.

### Option B: API Token

1. Create PyPI token: https://pypi.org/manage/account/token/
2. Copy the token (starts with `pypi-`)
3. Add to GitHub: Settings → Secrets → New secret
   - Name: `PYPI_API_TOKEN`
   - Value: Paste your token

## Step 4: First Release (2 minutes)

### A. Bump Version

Go to: **Actions** → **Version Bump** → **Run workflow**

- Select version type: `patch` (or `minor`, `major`)
- Click "Run workflow"

This creates a PR with updated version.

### B. Merge PR

1. Review the PR created by the workflow
2. Wait for CI to pass (✓ lint, ✓ test, ✓ build)
3. Merge the PR

### C. Create GitHub Release

1. Go to: **Releases** → **Draft a new release**
2. Click "Choose a tag" → Type: `v0.1.0` → "Create new tag"
3. **Title**: `v0.1.0`
4. **Description**:
   ```markdown
   ## What's Changed
   - Initial release with core functionality

   ## Installation
   ```bash
   pip install ml-api
   ```
   ```
5. Click "Publish release"

## Step 5: Verify (1 minute)

The publish workflow runs automatically. Within ~5 minutes:

```bash
# Install from PyPI
pip install ml-api

# Verify
python -c "import app; print(app.__version__)"
# Should print: 0.1.0
```

**Check**:
- PyPI: https://pypi.org/project/ml-api/
- GitHub Container Registry: https://github.com/yourusername/ml-api/pkgs/container/ml-api
- GitHub Actions: https://github.com/yourusername/ml-api/actions

🎉 **Done!** Your package is now on PyPI!

---

## Future Releases

### Regular Release Workflow

1. **Make changes** and commit to main
2. **Run Version Bump** workflow (Actions → Version Bump)
3. **Merge the PR** created by the workflow
4. **Create GitHub Release** with the new tag
5. **Automatic publish** to PyPI ✨

### Quick Commands

```bash
# Local development
make dev              # Run dev server
make test            # Run tests
make lint            # Check code quality

# Release preparation
make version-patch   # Bump patch version (0.1.0 → 0.1.1)
make version-minor   # Bump minor version (0.1.0 → 0.2.0)
make version-major   # Bump major version (0.1.0 → 1.0.0)

# Build & publish
make build           # Build package
make publish-test    # Publish to Test PyPI
make publish         # Publish to PyPI
```

---

## Troubleshooting

### "Package already exists" on PyPI

**Problem**: Version 0.1.0 already exists.

**Solution**: Bump version and try again:
```bash
make version-patch  # Changes to 0.1.1
make build
make publish
```

### CI Tests Failing

**Solution**: Run tests locally first:
```bash
make test-cov
# Fix any failures
git commit -am "fix: tests"
git push
```

### PyPI Authentication Failed

**Trusted Publishing**:
- Verify you've added the pending publisher on PyPI
- Ensure you did the first manual upload

**API Token**:
- Check `PYPI_API_TOKEN` secret is set correctly
- Verify token hasn't expired

### Docker Build Failed

**Solution**: Test locally:
```bash
make docker-build
# Check for errors
# Fix Dockerfile if needed
```

---

## Quick Reference

### Workflow Triggers

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| CI | Push/PR to main | Run tests, linting, build |
| Publish | GitHub Release | Publish to PyPI + Docker |
| Version Bump | Manual | Create version bump PR |

### GitHub Actions Status

Check at: https://github.com/yourusername/ml-api/actions

### PyPI Package Status

Check at: https://pypi.org/project/ml-api/

### Version Numbering

- **0.1.0 → 0.1.1**: Patch (bug fixes)
- **0.1.0 → 0.2.0**: Minor (new features)
- **0.1.0 → 1.0.0**: Major (breaking changes)

---

## Full Documentation

For detailed information, see:

- **PYPI_SETUP.md**: Complete PyPI setup guide
- **CI_CD_GUIDE.md**: Comprehensive CI/CD documentation
- **RELEASING.md**: Release process details
- **README.md**: Project overview and usage

---

## Support

**Issues?**
- Create an issue: https://github.com/yourusername/ml-api/issues
- Check Actions logs: https://github.com/yourusername/ml-api/actions
- Review workflow runs for error details

**Success?**
- Star the repo ⭐
- Share your package!
- Contribute improvements
