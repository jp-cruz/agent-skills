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
credit you if I add it.

---

## License

MIT — see individual skill directories for attribution on forked work.
