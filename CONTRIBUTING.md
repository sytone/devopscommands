# Contributing to DevOps Commands

First off, thank you for considering contributing to DevOps Commands! It's people like you that make this project better for everyone.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Pull Requests](#pull-requests)
- [Development Setup](#development-setup)
- [Commit Message Conventions](#commit-message-conventions)
- [CI/CD Pipeline](#cicd-pipeline)
- [Style Guide](#style-guide)

## Code of Conduct

This project and everyone participating in it is governed by our commitment to providing a welcoming and inclusive environment. Please be respectful and professional in all interactions.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the [issue list](https://github.com/sytone/devopscommands/issues) to see if the problem has already been reported. If it has and the issue is still open, add a comment to the existing issue instead of opening a new one.

When creating a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples to demonstrate the steps**
- **Describe the behavior you observed and what you expected to see**
- **Include PowerShell version and OS information**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Use a clear and descriptive title**
- **Provide a detailed description of the suggested enhancement**
- **Explain why this enhancement would be useful**
- **List any examples of how it would be used**

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following our [style guide](#style-guide)
3. **Add or update tests** as necessary
4. **Update documentation** to reflect your changes
5. **Follow the commit message conventions** (see below)
6. **Ensure the test suite passes** locally
7. **Submit your pull request**

## Development Setup

### Prerequisites

- PowerShell 5.1 or PowerShell Core 6+
- Required modules (install with the commands below):

```powershell
Install-Module PSake -Scope CurrentUser
Install-Module Pester -Scope CurrentUser
Install-Module PlatyPS -Scope CurrentUser
Install-Module SimpleSettings -Scope CurrentUser
Install-Module PSScriptAnalyzer -Scope CurrentUser
```

### Local Development Workflow

```powershell
# Clone your fork
git clone https://github.com/YOUR-USERNAME/devopscommands.git
cd devopscommands

# Create a feature branch
git checkout -b feature/your-feature-name

# Make your changes...

# Run linter
Invoke-ScriptAnalyzer -Path . -Recurse -Settings PSScriptAnalyzerSettings.psd1

# Build the module
Invoke-PSake psakefile.ps1 -taskList Build

# Run tests
Invoke-PSake psakefile.ps1 -taskList Test

# Commit your changes (see commit message conventions below)
git commit -m "feat: add new feature"

# Push to your fork
git push origin feature/your-feature-name

# Create a pull request on GitHub
```

## Commit Message Conventions

This project uses [Conventional Commits](https://www.conventionalcommits.org/) to enable automated versioning and changelog generation. The commit message format directly affects how the version number is bumped in CI/CD:

### Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types and Version Bumping

The commit type determines how the version is bumped:

- **Major version bump** (e.g., 1.5.3 → 2.0.0):
  ```
  feat!: remove deprecated function
  
  BREAKING CHANGE: The Use-VS2015 function has been removed
  ```

- **Minor version bump** (e.g., 1.5.3 → 1.6.0):
  ```
  feat: add support for Visual Studio 2026
  ```

- **Patch version bump** (e.g., 1.5.3 → 1.5.4):
  ```
  fix: correct path resolution in Use-VS2022
  docs: update README with new examples
  chore: update dependencies
  test: add tests for Clear-NugetCache
  refactor: simplify MSBuild argument handling
  ```

### Common Types

- **feat**: A new feature (minor version bump)
- **fix**: A bug fix (patch version bump)
- **docs**: Documentation only changes (patch version bump)
- **style**: Changes that don't affect code meaning (formatting, etc.) (patch version bump)
- **refactor**: Code change that neither fixes a bug nor adds a feature (patch version bump)
- **perf**: Performance improvements (patch version bump)
- **test**: Adding or updating tests (patch version bump)
- **chore**: Maintenance tasks, dependency updates (patch version bump)
- **ci**: Changes to CI/CD configuration (patch version bump)

### Examples

```
feat: add Install-MSBuildStructuredLogViewer command

fix: resolve issue with VS2022 environment variable detection

docs: add examples for Use-VS2019 command

feat(msbuild)!: change default platform to Any CPU

BREAKING CHANGE: The default platform has changed from x64 to Any CPU.
Users who need x64 builds must now specify it explicitly.

test: add comprehensive tests for Start-MsBuild

chore: update PlatyPS to version 2.0
```

### Scope

The scope is optional and can be used to specify which part of the codebase is affected:

- `msbuild` - MSBuild-related commands
- `vs` - Visual Studio environment commands
- `nuget` - NuGet-related commands
- `ci` - CI/CD pipeline
- `docs` - Documentation

## CI/CD Pipeline

This project uses GitHub Actions for continuous integration and deployment:

### Pull Request Checks

When you submit a pull request, the following checks run automatically:

1. **PSScriptAnalyzer** - Code quality and style checks
2. **Build** - Module build validation
3. **Tests** - All Pester tests must pass

All checks must pass before a pull request can be merged.

### Automated Versioning (Main Branch Only)

When code is merged to the `main` branch:

1. Version is automatically bumped based on commit messages
2. A Git tag is created for the new version
3. The module is published to PowerShell Gallery (if `PSGALLERY_API_KEY` secret is configured)
4. A GitHub release is created

### Skipping CI

If you need to skip CI (for example, for documentation-only changes that don't affect functionality), add `[skip ci]` to your commit message:

```
docs: fix typo in README [skip ci]
```

## Style Guide

### PowerShell Style

- Use **PascalCase** for function names (e.g., `Get-VisualStudioDetail`)
- Use **PascalCase** for parameters (e.g., `$ModuleName`)
- Use **camelCase** for local variables (e.g., `$currentVersion`)
- Follow the [PowerShell Practice and Style Guide](https://poshcode.gitbook.io/powershell-practice-and-style/)
- Run PSScriptAnalyzer and fix all errors before submitting

### Documentation

- Add comment-based help to all functions
- Include examples in function help
- Update README.md if adding new features
- Update docs/ folder markdown files using PlatyPS

### Testing

- Write Pester tests for new functionality
- Ensure all tests pass locally before submitting PR
- Aim for meaningful test coverage, not just high percentages

### File Organization

- Place public functions in `Public/`
- Place private/helper functions in `Private/`
- Place tests in `Tests/`
- Use `.tests.ps1` suffix for test files

## Questions?

If you have questions about contributing, feel free to:

- Open an issue with the `question` label
- Reach out to the maintainers

Thank you for contributing to DevOps Commands! 🎉
