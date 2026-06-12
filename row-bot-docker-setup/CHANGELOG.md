# Changelog

All notable changes to the Row-Bot Docker Setup will be documented in this file.

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

## [0.6.2] - 2026-05-29

**Status:** Production-ready. Pure Docker volumes, tested upgrade path, disaster recovery procedures.

### Added

- 🔒 **Pure Docker Volumes (v0.6.0+)** — Production-ready architecture
  - Migrated from host bind mounts to Docker-managed volumes
  - Eliminates permission issues and portability concerns
  - Volumes now live in `/var/lib/docker/volumes/` (host-independent)
  - Zero data loss on container restarts, upgrades, or rebuilds
  - Works identically on any Docker host (macOS, Linux, Windows, cloud)

- 📚 **Migration Guide** — MIGRATION.md for upgrading from v0.5.x
  - Step-by-step instructions for existing users
  - Backup procedures before migration
  - Troubleshooting common migration issues
  - Verification checklist for successful migration

- 🛡️ **Disaster Recovery Procedures** — Tested and documented
  - Full volume backup command examples
  - Reliable restore procedures with ownership fixes
  - Tested on real recovery scenarios
  - Documented in CLAUDE.md and MIGRATION.md

- 🚀 **Safe Upgrade Path** — Proven Thoth version upgrades
  - Documented how to upgrade Thoth without risking data
  - Volumes persist across image rebuilds and version changes
  - No permission issues or data loss during upgrades

### Changed

- 🔧 **CLAUDE.md** — Updated with new volume architecture
  - Clarified pure Docker volumes vs old bind mounts
  - Added upgrade instructions for Thoth versions
  - Added disaster recovery section with examples
  - Added troubleshooting for permission and symlink issues
  - Marked v0.5.x approaches as deprecated

- 📝 **Environment Configuration** (.env.example)
  - Clarified that THOTH_DATA_DIR/THOTH_WORKSPACE_DIR are deprecated
  - Added notes about Docker volume location and inspection
  - Added backup command examples for reference

### Fixed

- 🐛 **Permission Issues on Data Restore**
  - Documented ownership fix: `chown -R 1000:1000 /data`
  - Applies automatically during clean restore procedure
  - Prevents "Permission denied" errors after migrations

- 🔗 **Developer Studio Path Access**
  - Symlink recreation procedure documented
  - Can be made automatic in future versions
  - Workaround provided for manual recreation

### Verified

- ✅ Thoth v3.23.1 upgrade from v3.22.0 (data persists)
- ✅ Container restarts preserve all data in volumes
- ✅ Docker upgrades don't affect volume integrity
- ✅ Backup/restore cycle tested and working
- ✅ All required utilities (git, nano, jq, etc.) in runtime
- ✅ Multi-machine portability of volumes

---

## [0.6.1] - 2026-05-27

**Status:** UX redesign complete. Single entry point (./setup.sh), unified configuration panel, smart defaults with visibility. CLI-only execution enforced.

### Added

- ✨ **Smart Defaults with Visibility UX** — Redesigned setup flow for clarity
  - Single entry point: `./setup.sh` handles all detection and decisions
  - Unified "DETECTED CONFIGURATION" panel showing all findings at once
  - One decision point: "Apply this configuration? [Y/n]"
  - If user declines: shows customization help path (edit .env manually) with link to docs
  - Graceful exit with guidance instead of forcing adoption

- 🔒 **Terminal-Only Enforcement** — Explicit requirements for proper execution
  - SKILL.md: Added `requires_terminal: true` metadata flag
  - SKILL.md: Prominent warning that web/desktop Claude cannot run this skill
  - SKILL.md: Compatibility table showing supported environments (Aider, Claude Code CLI, VS Code, OpenCode, bash)
  - scripts/setup.sh: Context detection check — blocks if not in interactive TTY
  - Clear error message with multiple compatible execution options

### Changed

- 📖 **README.md** — Flattened setup instructions
  - Removed 3-path setup methods table (Quick/Detailed/Intelligent confusion)
  - Single "Quick Start" section: just `./setup.sh`
  - Demoted `preflight-check.sh` and `disk-check.sh` to "Advanced Options" section
  - Moved "Disk Space Planning" section later in README (after troubleshooting)
  - Consolidated "Common Commands" sections (removed duplicate)
  
- 🧪 **scripts/preflight-check.sh** — Windows WSL2 text reduction
  - WSL-not-installed explanation: reduced from ~15 lines to ~6 lines
  - WSL1-upgrade explanation: reduced from ~10 lines to ~6 lines
  - Removed early exit after opening PowerShell — assessment continues
  - Added guidance: "re-run ./scripts/preflight-check.sh after restart"

- ⚙️ **scripts/disk-check.sh** — Added `--export-only` flag
  - `--export-only`: exports detection variables, prints nothing (used by setup.sh)
  - Semantic clarification: `--quiet` remains for backward compat (same behavior)
  - Standalone `./scripts/disk-check.sh` (no flags): full detailed output as before

### Why These Changes

User feedback: Setup process had implicit decision saturation (3-path README table) even though explicit prompts were minimal. Users debated which script to run before starting anything. Solution: Single entry point that shows analysis openly, not buried in `--quiet` output. "Apply this? [Y/n]" replaces scattered decisions.

---

## [0.6.0] - 2026-05-27

**Status:** Storage intelligence added. Disk management tools fully functional.

### Added

- ✨ `scripts/disk-check.sh` — Drive detection, speed testing, storage recommendation engine
  - Detects OS, identifies mounted volumes
  - Classifies external drives (Thunderbolt, USB) with connection types
  - Tests drive speed (~3 sec per candidate)
  - Analyzes Docker storage usage
  - Exports recommendations for setup.sh to consume
- 🧹 `scripts/thoth-maintenance.sh` — Interactive cleanup and archival
  - Disk usage reporting (current footprint)
  - Docker cleanup: build cache, stopped containers, dangling images
  - Log truncation, workspace archival
  - Automated cron scheduling (weekly)
- 📖 `references/DISK_MANAGEMENT.md` — Complete storage management guide
  - Why Thoth grows (memory.db, threads.db, caches)
  - Space timeline estimates (by use case)
  - External drive recommendations (Thunderbolt > USB-C > USB-A)
  - How to move data to external drive
  - Docker data-root relocation (all platforms)
  - Cleanup and archival strategies
- ⚙️ **Disk Space Planning section** in README.md with size estimates
- 🌐 **Claude Code CLI recommendation** in SKILL.md with install instructions

### Changed

- `scripts/preflight-check.sh` — Added Windows WSL2 prerequisite check
  - Detects if WSL is installed (required for Docker Desktop on Windows)
  - Verifies WSL version is 2, not 1 (WSL1 is too slow for Docker)
  - Checks Docker Desktop backend configuration
  - If WSL missing: explains why it's critical, offers to launch PowerShell installer
  - If WSL1 only: shows upgrade command
  - If Docker not using WSL2: shows exact steps to enable in Docker Settings
- `scripts/setup.sh` — Integrated disk-check.sh assessment
  - Now calls disk-check.sh before Docker checks
  - Shows storage warnings if space constrained
  - Interactively prompts to use recommended external drive
  - Auto-updates .env paths if user approves
  - Added maintenance tool to "Next steps" output
- `.env.example` — Disk space warning and external drive examples
- `SKILL.md` — Version bumped to 0.6.0, added Claude Code CLI section

### Why These Changes

Thoth's memory system grows 1–3 GB/week. Mac Mini M4 users with 256GB drives hit disk constraints quickly. The updates provide:
1. **Early warning:** disk-check.sh runs at setup time
2. **Smart recommendations:** detects external drives, suggests best location
3. **Proactive guidance:** .env.example and README warn users upfront
4. **Ongoing maintenance:** thoth-maintenance.sh offers cleanup and archival
5. **User-friendly:** interactive prompts in setup.sh, no manual .env editing needed

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
