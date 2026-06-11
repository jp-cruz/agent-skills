# Security Policy

## Reporting Security Vulnerabilities

If you discover a security vulnerability in the Thoth Docker Template, please **do not** open a public issue. Instead:

1. **Email:** security@legionforge.org with subject `[SECURITY] Thoth Docker Template`
2. **Include:**
   - Description of the vulnerability
   - Steps to reproduce (if applicable)
   - Potential impact
   - Suggested fix (if available)

3. **Timeline:** We aim to respond within 48 hours and provide an update within 7 days

## Security Considerations

### Container Isolation

This project uses Docker to provide security isolation:

- **Non-root user**: Thoth runs as `thoth` user (UID 1000), not root
- **Limited filesystem**: Container only has access to mounted volumes
- **Network isolation**: Configurable networking (bridge or host mode)
- **Secrets management**: API keys stored via system keyring, not in code

### Secrets Management

- **Never commit API keys** to the repository
- **Use platform-specific keyring**:
  - macOS: Keychain
  - Windows: Credential Manager
  - Linux: Secret Service
- **Configuration via environment variables** (.env file, not committed)

### Supply Chain Security

This project maintains:

- ✅ Pinned Docker base image (Python 3.11-slim)
- ✅ Dependency locking (requirements.txt)
- ✅ No hardcoded credentials or internal IPs
- ✅ Signed commits (recommended for contributors)

**Future enhancements:**
- SBOM generation (CycloneDX/SPDX)
- SLSA3 provenance tracking
- Sigstore signing for releases

### Dependencies

The project depends on:

1. **External:**
   - Docker / Docker Desktop / Docker Engine
   - Ollama (for local LLM inference)
   - Python 3.11 (in container)

2. **Python packages:**
   - See `docker/Dockerfile` for pip dependencies
   - All installed from PyPI with version constraints in requirements.txt

3. **System utilities:**
   - Git, curl, nano, jq, vim-tiny (all from official Debian repositories)

## Vulnerability Disclosure

When a vulnerability is reported and fixed:

1. We will create a security patch
2. Affected users will be notified
3. A security advisory will be published
4. The vulnerability will be added to the changelog

## Security Best Practices

### For Users

- **Keep Docker updated** — Run `docker --version` and update Docker Desktop regularly
- **Use environment variables** — Store API keys in `.env`, never in code
- **Review configurations** — Audit your `.env` file before sharing
- **Monitor logs** — Check `docker-compose logs` for unexpected warnings

### For Contributors

- **No secrets in code** — Never commit API keys, tokens, or passwords
- **Use `.env.example`** — Template for configuration, never the actual `.env`
- **Test locally** — Verify no sensitive data is logged
- **Sign commits** — Use `git commit -S` for verified commits

## Supported Versions

| Version | Status | Security Updates |
|---------|--------|------------------|
| 0.1.x   | Current | Yes |
| < 0.1   | N/A | N/A |

The latest version will receive security updates. We recommend upgrading to the latest version for security patches.

## Known Limitations

1. **Ollama warning on startup** — Expected when Ollama not running; not a security issue
2. **macOS Keychain access** — Requires user permission on first keyring access
3. **Windows Credential Manager** — Requires explicit opt-in configuration

## Security Roadmap

- [ ] SBOM generation (CycloneDX)
- [ ] SLSA3 provenance with GitHub Actions
- [ ] Sigstore code signing
- [ ] Automated dependency scanning (Dependabot)
- [ ] Security advisories process

## License

This security policy applies to the Thoth Docker Template project and is provided as-is.

For the Thoth project itself, see [Thoth Security Policy](https://github.com/siddsachar/Thoth/security).

---

**Last updated:** 2026-05-25
