# Repository Badges

Add these badges to the top of your README.md for a professional look.

## How to Use

1. Replace `yourusername` with your GitHub username
2. Replace `ml-api` with your repository name (if different)
3. Copy the badges you want to your README.md

## Available Badges

### CI/CD Status

```markdown
![CI](https://github.com/yourusername/ml-api/workflows/CI/badge.svg)
![Publish](https://github.com/yourusername/ml-api/workflows/Publish%20to%20PyPI/badge.svg)
```

### PyPI

```markdown
[![PyPI version](https://badge.fury.io/py/ml-api.svg)](https://badge.fury.io/py/ml-api)
[![PyPI - Python Version](https://img.shields.io/pypi/pyversions/ml-api)](https://pypi.org/project/ml-api/)
[![PyPI - Downloads](https://img.shields.io/pypi/dm/ml-api)](https://pypi.org/project/ml-api/)
```

### Code Quality

```markdown
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
[![Ruff](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/ruff/main/assets/badge/v2.json)](https://github.com/astral-sh/ruff)
[![codecov](https://codecov.io/gh/yourusername/ml-api/branch/main/graph/badge.svg)](https://codecov.io/gh/yourusername/ml-api)
```

### License & Documentation

```markdown
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Documentation](https://img.shields.io/badge/docs-latest-blue.svg)](https://github.com/yourusername/ml-api#readme)
```

### Docker

```markdown
[![Docker Image](https://img.shields.io/badge/docker-ghcr.io-blue)](https://github.com/yourusername/ml-api/pkgs/container/ml-api)
```

### Project Status

```markdown
[![Status](https://img.shields.io/badge/status-beta-orange)](https://github.com/yourusername/ml-api)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/yourusername/ml-api/graphs/commit-activity)
```

## Complete Badge Section for README

Add this to the top of your README.md (after the title):

```markdown
# ML API - Production-Grade Machine Learning Service

[![CI](https://github.com/yourusername/ml-api/workflows/CI/badge.svg)](https://github.com/yourusername/ml-api/actions)
[![PyPI version](https://badge.fury.io/py/ml-api.svg)](https://badge.fury.io/py/ml-api)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

A production-ready ML API service built with FastAPI, Polars, SQLAlchemy 2.0, and Google Cloud Storage.

[Installation](#installation) • [Documentation](#documentation) • [Quick Start](#quick-start) • [Contributing](#contributing)
```

## Customization

### Change Badge Color

Add `?color=YOUR_COLOR` to shields.io badges:

```markdown
![Custom Badge](https://img.shields.io/badge/status-beta-orange?color=blue)
```

### Custom Badges

Create custom badges at [shields.io](https://shields.io/):

```markdown
![Custom](https://img.shields.io/badge/label-message-color)
```

### Dynamic Badges

For real-time stats:

```markdown
<!-- GitHub stars -->
![GitHub stars](https://img.shields.io/github/stars/yourusername/ml-api?style=social)

<!-- GitHub forks -->
![GitHub forks](https://img.shields.io/github/forks/yourusername/ml-api?style=social)

<!-- Contributors -->
![Contributors](https://img.shields.io/github/contributors/yourusername/ml-api)

<!-- Last commit -->
![Last Commit](https://img.shields.io/github/last-commit/yourusername/ml-api)

<!-- Issues -->
![Issues](https://img.shields.io/github/issues/yourusername/ml-api)

<!-- Pull Requests -->
![PRs](https://img.shields.io/github/issues-pr/yourusername/ml-api)
```

## Setting Up Codecov Badge

1. Sign up at https://codecov.io/
2. Add your GitHub repository
3. Get your upload token
4. Add to GitHub secrets as `CODECOV_TOKEN`
5. Badge will automatically update after CI runs

## Example README Header

```markdown
<div align="center">

# 🚀 ML API

### Production-Grade Machine Learning Service

[![CI](https://github.com/yourusername/ml-api/workflows/CI/badge.svg)](https://github.com/yourusername/ml-api/actions)
[![PyPI version](https://badge.fury.io/py/ml-api.svg)](https://pypi.org/project/ml-api/)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
[![codecov](https://codecov.io/gh/yourusername/ml-api/branch/main/graph/badge.svg)](https://codecov.io/gh/yourusername/ml-api)

[Features](#features) • [Installation](#installation) • [Quick Start](#quick-start) • [Documentation](#documentation) • [Contributing](#contributing)

</div>

---
```

This creates a nice centered header with badges and navigation links!
