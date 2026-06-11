# Contributing to Thoth Docker Template

Thank you for your interest in contributing! This guide explains how to submit improvements.

## Quick Links

- **Issues:** Report bugs or request features via GitHub issues
- **Security:** See [SECURITY.md](SECURITY.md) for vulnerability reporting
- **Roadmap:** See [NEXT_STEPS.md](NEXT_STEPS.md) for planned enhancements

## Code of Conduct

This project is committed to providing a welcoming and inclusive environment. Please be respectful and constructive in all interactions.

## How to Contribute

### 1. Report Bugs

**Before creating an issue:**
- Check existing issues to avoid duplicates
- Test on the latest version
- Gather platform info (`uname -a`, `docker --version`, etc.)

**When reporting:**
- Describe the bug clearly
- Include steps to reproduce
- Share error messages (console output, logs)
- List your platform/environment

Example:
```
**Platform:** macOS 14.6 (Apple Silicon M4)
**Docker:** 29.2.1
**Error:** Port 8080 already in use

**Steps:**
1. Run ./setup.sh
2. Run docker-compose up -d
3. See: "Address already in use" error

**Expected:** Container starts on port 8080
**Actual:** Error about port conflict
```

### 2. Request Features

**When requesting a feature:**
- Explain the use case
- Describe the expected behavior
- Suggest implementation approach (if known)

Example:
```
**Feature:** Auto-start Ollama if not running
**Use case:** Users without Docker experience often forget to start Ollama
**Expected behavior:** setup.sh detects missing Ollama, offers to start it
```

### 3. Submit Pull Requests

**Before coding:**
- Fork the repository
- Create a feature branch: `git checkout -b feature/my-feature`
- Check [CLAUDE.md](CLAUDE.md) for development guidelines

**Code standards:**
- Bash scripts: Use `set -e` and check exit codes
- Docker: Keep Dockerfile minimal, comment non-obvious decisions
- Documentation: Update README.md if you change behavior

**Commit messages:**
```
Add feature: <short description>

- Explain what changed
- Explain why it's needed
- Reference issue numbers if applicable
```

**Before submitting:**
- Test on your platform
- Run `bash -n script.sh` to validate shell syntax
- Update documentation if needed
- Ensure no hardcoded secrets, IPs, or internal details

### 4. Improve Documentation

Documentation improvements are always welcome:

- Fix typos
- Clarify confusing sections
- Add examples
- Update troubleshooting guides
- Improve platform-specific instructions

## Testing Guidelines

### Local Testing (macOS/Linux)

```bash
# Syntax check
bash -n setup.sh
bash -n check-docker.sh
bash -n preflight-check.sh

# Docker validation
docker-compose config   # Validates YAML
docker-compose build    # Test image build (optional)
```

### Platform Testing

If you can, test on multiple platforms:
- **macOS:** Intel and Apple Silicon
- **Windows:** WSL2 backend
- **Linux:** Ubuntu/Debian and CentOS/RHEL variants

## Development Environment

### Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/thoth-docker-template.git
cd thoth-docker-template

# Create feature branch
git checkout -b feature/your-feature

# Install pre-commit hooks (optional)
# pip install pre-commit
# pre-commit install
```

### Making Changes

1. **For scripts:** Test each change with `bash -n script.sh`
2. **For docker-compose.yml:** Validate with `docker-compose config`
3. **For docs:** Preview locally (Markdown viewer)
4. **For Dockerfile:** Consider multi-stage builds for size optimization

### Commit Guidelines

```bash
# Sign commits (recommended)
git commit -S -m "Add feature: description"

# Avoid:
# - Commits with API keys or secrets
# - Large binary files
# - Unrelated changes (one feature per PR)
```

## Pull Request Process

1. **Fork and branch** — Create feature branch from `main`
2. **Code and commit** — Make changes with clear commit messages
3. **Test** — Run local validation tests
4. **Document** — Update README, CLAUDE.md if behavior changed
5. **Push** — `git push origin feature/your-feature`
6. **Create PR** — Describe what changed and why
7. **Review** — Address feedback from maintainers

## Areas for Contribution

### High Priority

- [ ] Windows (WSL2) validation and fixes
- [ ] Linux (Ubuntu/CentOS) validation and fixes
- [ ] Automated Ollama startup detection
- [ ] Web-based configuration UI

### Medium Priority

- [ ] Multi-provider cost calculator
- [ ] SBOM generation (CycloneDX)
- [ ] SLSA3 provenance tracking
- [ ] Sigstore code signing

### Low Priority

- [ ] Additional development utilities
- [ ] Extended documentation examples
- [ ] Kubernetes manifests
- [ ] Helm charts

## Code Review Process

All PRs go through code review:

- **Automated checks:** Syntax validation, security scan
- **Manual review:** One maintainer reviews for:
  - Code quality and style
  - Documentation accuracy
  - Platform compatibility
  - Security best practices

## Getting Help

- **Questions about contributing?** Open a discussion or issue
- **Need clarification?** Ask in the PR or issue
- **Security concern?** Email privately (see [SECURITY.md](SECURITY.md))

## Licensing

By contributing, you agree that your contributions will be licensed under the MIT License (see [LICENSE](LICENSE)).

---

Thank you for helping make Thoth Docker Template better! 🚀
