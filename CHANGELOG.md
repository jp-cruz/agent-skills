# Changelog

All notable changes to the Thoth Docker Template will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned

- SBOM generation (CycloneDX format)
- SLSA3 provenance tracking via GitHub Actions
- Sigstore code signing for releases
- Web-based configuration UI
- Automated Ollama startup detection
- Multi-provider cost calculator
- Kubernetes manifests
- Helm charts

---

## [0.5.0] - 2026-05-25

**Status:** Feature-complete, tested on macOS Tahoe. Linux and Windows validation pending.

### Added

- ✨ **Complete Docker Compose setup** for Thoth across macOS, Windows, and Linux
- 📚 **Comprehensive documentation**:
  - README.md with quick start and troubleshooting
  - GETTING_STARTED.md for complete beginners (9-step guide)
  - DOCKER_GUIDE_FOR_BEGINNERS.md with Docker education and installation
  - DOCKER_COMPOSE_EXPLAINED.md with technical deep-dive
  - SETUP_WORKFLOW.md comparing 3-tier setup methods
  - UTILITIES_ANALYSIS.md justifying included utilities
  - QUESTIONNAIRE_SYSTEM.md for intelligent configuration (20 questions)

- 🔧 **Automation scripts**:
  - `setup.sh` — One-command setup with prerequisite validation
  - `check-docker.sh` — Docker installation verification with helpful errors
  - `preflight-check.sh` — Environment detection and recommendations
  - `setup.bat` — Windows equivalent setup

- 🐳 **Docker configuration**:
  - Fully parameterized docker-compose.yml for cross-platform support
  - Python 3.11-slim Dockerfile with development utilities
  - Optimized .dockerignore for smaller build context
  - Platform-specific .env.example templates

- 🛡️ **Security features**:
  - Non-root container execution (thoth user, UID 1000)
  - Platform-specific keyring integration (Keychain/Credential Manager/Secret Service)
  - No hardcoded secrets, credentials, or internal IPs
  - Docker base image pinned to specific version

- 🧰 **Development utilities included**:
  - nano (1.5 MB) — Configuration editing
  - jq (2 MB) — JSON processing for Ollama API debugging
  - vim-tiny (2 MB) — Vi implementation for power users
  - git, curl, less, file, tree, unzip — Standard development tools

- 📋 **Multi-tier setup workflow**:
  - Quick setup (1 min): `./setup.sh`
  - Detailed setup (2 min): `./preflight-check.sh` for custom configuration
  - Intelligent setup (3-5 min): Agent-skill for AI-guided configuration

- 🎯 **Environment detection**:
  - Automatic OS detection (macOS, Windows, Linux)
  - LLM backend detection (Ollama, LM Studio, vLLM, llama.cpp, GPT4All)
  - Python environment validation
  - Secrets management detection
  - Port availability checking

- 🔌 **Multi-provider support**:
  - Ollama (local inference)
  - OpenAI (cloud)
  - Anthropic Claude (cloud)
  - OpenRouter (multi-model proxy)
  - Groq (fast inference)
  - LM Studio (local)
  - Configuration examples for all providers

- 📊 **Cross-platform networking**:
  - macOS/Windows: `host.docker.internal` for host access
  - Linux: Configurable (localhost, custom IP, or host network)
  - Volume binding for data persistence

- ✅ **Comprehensive validation**:
  - 9-category validation suite (all passing)
  - File integrity checks
  - Script syntax validation
  - Docker configuration validation
  - Security and compliance checks
  - Documentation quality verification
  - Cross-platform compatibility tests

### Documentation

- README.md with quick start, commands, troubleshooting
- GETTING_STARTED.md for step-by-step setup
- DOCKER_GUIDE_FOR_BEGINNERS.md with installation for all platforms
- CLAUDE.md with development guide
- SKILL.md with skill definition
- QUESTIONNAIRE_SYSTEM.md with 20-question configuration system
- QUESTIONNAIRE_SUMMARY.md with question checklist
- AGENT_QUESTIONNAIRE_IMPLEMENTATION.md with agent skill integration
- VALIDATION_REPORT.md with complete test results
- READY_FOR_PUBLICATION.md with publication checklist

### Files

- Total: 25+ files
- Documentation: 19 markdown files (~4,000 lines)
- Automation: 4 shell scripts
- Configuration: 4 YAML/JSON files
- Tests: Comprehensive validation suite

---

## [0.0.1] - 2026-05-21

### Initial Development

- Started project based on Jeli Docker experience
- Created initial docker-compose.yml
- Created basic setup scripts
- Documented architecture and design decisions

---

## Upgrade Path

### From 0.0.1 to 0.1.0

No breaking changes. Existing installations can be updated:

```bash
# Pull latest
git pull origin main

# Rebuild image
docker-compose build --no-cache

# Restart container
docker-compose up -d
```

---

## Security Releases

For security vulnerability fixes, see [SECURITY.md](SECURITY.md).

---

## Future Roadmap

### v0.2.0 (Q3 2026)

- [ ] Web-based configuration UI
- [ ] Automated Ollama detection and startup
- [ ] Cost calculator for multi-provider setup
- [ ] Enhanced error recovery and self-healing

### v0.3.0 (Q4 2026)

- [ ] SBOM generation (CycloneDX/SPDX)
- [ ] SLSA3 provenance tracking
- [ ] Sigstore code signing
- [ ] Kubernetes support

### v1.0.0 (Target: 2027)

- Full enterprise support
- Production-grade documentation
- Extensive platform testing
- Security compliance (SLSA3, Sigstore, SBOM)

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute.

---

**Latest:** [0.5.0] - 2026-05-25 (macOS Tahoe tested, Linux/Windows pending)  
**Next:** [0.6.0] - TBD (Linux validation)
**Target:** [1.0.0] - 2026-06-30 (all platforms validated)
