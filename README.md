# agent-skills

A personal, curated library of skills for AI agents.

This is not a bulk collection. Every skill here is one I personally use, have read in full,
and have vetted before publishing. Quality and honesty over quantity.

Skills follow the [Agent Skills](https://agentskills.io) open format and are compatible
with any agent that supports the standard — Claude Code, Cursor, GitHub Copilot, Codex,
Gemini CLI, and others.

## Install a skill

```bash
npx skills@latest add jp-cruz/agent-skills/<skill-name>
```

Or install globally to share across all your projects:

```bash
npx skills@latest add jp-cruz/agent-skills/<skill-name> --global
```

---

## Skills

| Skill | Description | Version | Install |
|-------|-------------|---------|---------|
| [thoth-docker-setup](./thoth-docker-setup/) | Production-ready Docker Compose setup for Thoth with cross-platform support (macOS, Windows, Linux). Includes automated environment detection, multi-provider LLM integration (Ollama, OpenRouter, OpenAI, Anthropic), persistent volumes, and comprehensive troubleshooting documentation. Security-hardened with non-root execution and pinned base images. | v0.5.0 | `npx skills@latest add jp-cruz/agent-skills/thoth-docker-setup` |
| [legionforge-claude-obsidian](./legionforge-claude-obsidian/) | Complete session context initialization system for Claude Code and Desktop. Three-layer context loading (automatic, on-demand via MCP, selective by domain). Provider-independent, crash-safe, cross-platform. Includes setup wizard, verification protocol, and recovery tools. | v0.1.0-alpha | `npx skills@latest add jp-cruz/agent-skills/legionforge-claude-obsidian` |
| [fact-checker](./fact-checker/) | Systematic fact verification with temporal reasoning and search result validity checks. Flags claims that fall outside model knowledge cutoff with recommended follow-up paths. Forked from [Shubhamsaboo/awesome-llm-apps](https://github.com/Shubhamsaboo/awesome-llm-apps/tree/main/awesome_agent_skills/fact-checker). | v1.1.0 | `npx skills@latest add jp-cruz/agent-skills/fact-checker` |

---

## Security & Audit Policy

Skills are executable instructions injected into agent context. A poorly written or
malicious skill can cause unintended agent behavior — including prompt injection,
tool misuse, or data leakage.

Every skill in this repo has been:

- **Read in full** — no blind forks or bulk imports
- **Reviewed for prompt injection patterns** — instructions that could hijack agent behavior
- **Checked for scope creep** — skills should do one thing and state it clearly
- **Attribution verified** — forked skills credit the original author and link to the source

If you spot an issue with any skill, please [open an issue](../../issues). I'd rather know.

> Skills are provided as-is under MIT license. Review before installing.
> I am not responsible for how your agent interprets or applies these instructions
> in your specific environment.

---

## Suggestions

Have a skill you think belongs here? [Open an issue](../../issues) and make the case.
I'm not accepting PRs, but genuine suggestions are welcome. I'll evaluate, audit, and
credit you if I add it. Thank you! - Jp Cruz

---

## License

MIT — see individual skill directories for attribution on forked work.
