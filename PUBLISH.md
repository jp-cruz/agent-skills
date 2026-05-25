# Publishing to agent-skills Repository

This guide documents how to publish the `thoth-docker-setup` skill to https://github.com/jp-cruz/agent-skills.

## Pre-Publication Checklist

- [ ] All tests pass on macOS, Windows, and Linux
- [ ] Code is reviewed for security
- [ ] Documentation is complete and accurate
- [ ] No hardcoded paths or internal IPs remain (check with grep)
- [ ] Version number updated in skill-manifest.json
- [ ] CHANGELOG updated with new features
- [ ] No sensitive information in any files

### Security Pre-Flight

```bash
# Check for internal IPs
git diff --staged | grep -E "10\.[0-9]+\.[0-9]+|192\.168\.|172\.16-31\."

# Check for SSH keys or credentials
git diff --staged | grep -E "id_rsa|id_ed25519|password|token|api.?key"

# Check for hardcoded paths
git diff --staged | grep -E "/Users/dylan|/home/dylan|C:\\Users\\dylan"
```

All checks should return nothing.

## Repository Structure

```
agent-skills/
├── thoth-docker-setup/           # This skill
│   ├── docker/
│   │   ├── Dockerfile
│   │   └── docker-compose.yml
│   ├── .env.example
│   ├── .dockerignore
│   ├── .gitignore
│   ├── setup.sh
│   ├── setup.bat
│   ├── README.md
│   ├── CLAUDE.md
│   ├── SKILL.md
│   ├── UTILITIES_ANALYSIS.md
│   ├── skill-manifest.json
│   └── PUBLISH.md (this file)
├── SKILLS.md                      # Index of all skills (update this)
├── README.md                       # Repository README
└── [other-skills]/
```

## Publishing Steps

### 1. Prepare the Repository

Clone the agent-skills repository:
```bash
git clone https://github.com/jp-cruz/agent-skills
cd agent-skills
```

### 2. Add the Skill

Create the skill directory and copy files:
```bash
mkdir -p thoth-docker-setup/docker
cp -r /Volumes/MAC_MINI_1TB/thoth_docker_template/* thoth-docker-setup/
```

### 3. Update Repository Index

Edit `SKILLS.md` in the repository root to add:

```markdown
## thoth-docker-setup

Production-ready Docker Compose setup for Thoth with cross-platform support (macOS, Windows, Linux).

- **Location:** `thoth-docker-setup/`
- **Status:** Stable
- **Platforms:** macOS, Windows, Linux
- **Quick Start:** 
  ```bash
  cd thoth-docker-setup
  ./setup.sh  # or setup.bat on Windows
  docker-compose up -d
  ```
- **Documentation:** [README.md](thoth-docker-setup/README.md)
```

### 4. Create Commit

```bash
git add thoth-docker-setup/
git commit -m "Add thoth-docker-setup skill

Provides production-ready Docker Compose setup for Thoth:

Features:
- Cross-platform support (macOS/Windows/Linux)
- Parameterized configuration via .env
- Automated setup scripts with validation
- Comprehensive documentation
- Essential utilities (nano, vim, jq, etc.)
- Persistent data volumes
- Ollama integration

This skill enables safe, reliable Thoth deployments with minimal configuration."
```

### 5. Push to Remote

```bash
git push -u origin main
```

## Versioning

Follow semantic versioning:

- **MAJOR** (1.0.0 → 2.0.0) — Breaking changes to Dockerfile or docker-compose.yml structure
- **MINOR** (1.0.0 → 1.1.0) — New features (e.g., new utilities, new environment variables)
- **PATCH** (1.0.0 → 1.0.1) — Bug fixes, documentation, minor improvements

Current version: **1.0.0**

To update version:
1. Edit `skill-manifest.json` and update `version`
2. Update `CHANGELOG.md` in the skill directory
3. Create git tag: `git tag thoth-docker-setup/v1.0.0`

## Changelog Template

Create `CHANGELOG.md` in the skill directory:

```markdown
# Changelog — thoth-docker-setup

All notable changes to this project will be documented in this file.

## [1.0.0] - 2024-05-25

### Added
- Initial release with full Docker Compose setup
- Cross-platform support (macOS, Windows, Linux)
- Automated setup scripts (setup.sh, setup.bat)
- Environment-based configuration (.env)
- Essential utilities: nano, vim-tiny, jq, less, file, tree, unzip
- Comprehensive documentation (README, CLAUDE, SKILL)
- Multi-machine deployment support
- Data persistence and backup guides

### Features
- Non-root user execution (security best practice)
- Ollama integration for LLM access
- Persistent data volumes with bind mounts
- Configurable port and paths
- Troubleshooting guides for all platforms

### Documentation
- 350+ line README with platform-specific setup
- Developer guide (CLAUDE.md) for future iterations
- Detailed utilities analysis and rationale
- Architecture documentation

## [Unreleased]

### Planned
- Multi-stage Dockerfile for smaller images
- Docker Buildkit optimization
- Health check configuration
- Kubernetes manifests
- GitHub Actions CI/CD pipeline
```

## Marketing the Skill

### On GitHub

Add to agent-skills `README.md`:

```markdown
### 🐳 [thoth-docker-setup](thoth-docker-setup/)

Production-ready Docker Compose for Thoth across macOS, Windows, and Linux.

**Features:**
- Fully parameterized configuration
- Cross-platform setup scripts
- Ollama integration
- Persistent data volumes
- Essential development utilities

**One-liner:** `cd thoth-docker-setup && ./setup.sh && docker-compose up -d`
```

### Documentation

Ensure these are visible:
- README.md — Primary documentation
- SKILL.md — Feature overview
- CLAUDE.md — Developer guide
- UTILITIES_ANALYSIS.md — Detailed tool rationale

### Example Usage

Add to agent-skills `README.md` examples section:

```markdown
## Example: Deploy Thoth with Docker

```bash
# Clone and setup
git clone https://github.com/jp-cruz/agent-skills
cd agent-skills/thoth-docker-setup

# Automated setup (validates prerequisites)
./setup.sh

# Customize if needed
vim .env

# Start Thoth
docker-compose up -d

# Access at http://localhost:8080
```

To stop:
```bash
docker-compose stop
```

To access container shell:
```bash
docker-compose exec thoth bash
```
```

## Maintenance After Publishing

### Monitoring

- Watch for issues in GitHub Issues
- Track usage and feedback
- Monitor Docker Hub for Thoth updates (consider pinning to specific commit vs. "latest")

### Updates

When Thoth is updated:
1. Update the git commit hash in Dockerfile
2. Test on all platforms
3. Update version in skill-manifest.json
4. Update CHANGELOG.md
5. Create new commit and push

Example:
```dockerfile
RUN git clone https://github.com/siddsachar/Thoth.git . && \
    git checkout abc1234 && \  # Update this hash
    chown -R thoth:thoth /app
```

### Handling Issues

**Issue: X doesn't work on platform Y**
1. Reproduce on that platform
2. Debug using tools provided (nano, jq, curl, etc.)
3. Document fix in README troubleshooting
4. Patch Dockerfile if needed
5. Release patch version

**Issue: New utility needed**
1. Add to Dockerfile with rationale
2. Document in UTILITIES_ANALYSIS.md
3. Update SKILL.md
4. Release minor version

**Issue: Breaking change needed**
1. Document migration path clearly
2. Update all examples
3. Release major version
4. Announce in CHANGELOG

## Automated Testing (Future)

Consider adding to agent-skills `.github/workflows/`:

```yaml
name: Test thoth-docker-setup

on: [push, pull_request]

jobs:
  build:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [macos-latest, ubuntu-latest, windows-latest]
    steps:
      - uses: actions/checkout@v3
      - name: Test setup on ${{ matrix.os }}
        run: |
          cd thoth-docker-setup
          if [[ "${{ matrix.os }}" == "windows-latest" ]]; then
            setup.bat
          else
            ./setup.sh
          fi
      - name: Build Docker image
        run: |
          cd thoth-docker-setup
          docker-compose build --no-cache
      - name: Run basic tests
        run: |
          cd thoth-docker-setup
          docker-compose up -d
          docker-compose exec thoth nano --version
          docker-compose exec thoth jq --version
          docker-compose logs thoth
          docker-compose down
```

## Support

For issues with the skill:
1. Check README.md troubleshooting
2. Check UTILITIES_ANALYSIS.md for utility details
3. Open GitHub issue with:
   - Platform (macOS/Windows/Linux)
   - Docker version
   - Error message
   - Setup script output
   - docker-compose logs

## References

- [Thoth GitHub](https://github.com/siddsachar/Thoth)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Ollama Documentation](https://github.com/ollama/ollama)
- [agent-skills Repository](https://github.com/jp-cruz/agent-skills)
