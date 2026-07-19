<div align="center">

# Project Prospector

**Discover, catalog, and rank everything you've built or sketched on a machine** — a Claude Code + Grok multi-agent skill for filesystem project discovery with tiered novelty and leverage ranking.

[![plugin-validate](https://github.com/88plug/project-prospector/actions/workflows/plugin-validate.yml/badge.svg)](https://github.com/88plug/project-prospector/actions/workflows/plugin-validate.yml)
[![License: FSL-1.1-ALv2](https://img.shields.io/badge/license-FSL--1.1--ALv2-blue?style=flat)](LICENSE)
[![Docs](https://img.shields.io/badge/docs-online-2ea44f?style=flat)](https://88plug.github.io/project-prospector/)
[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-8A2BE2?style=flat)](https://github.com/88plug/claude-code-plugins)
[![DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/88plug/project-prospector)

</div>

## Install

### Claude Code

```text
/plugin marketplace add 88plug/claude-code-plugins
/plugin install project-prospector@88plug
```

### Grok Build

```text
grok plugin marketplace add 88plug/claude-code-plugins
grok plugin install project-prospector@88plug --trust
```


## Quickstart

Ask in plain language — no command to memorize:

```text
What have I built on this laptop? Rank my projects by which ideas are most original.
```

You get a tiered ranking, strongest idea first, with `[idea]` / `[LIVE]` / `[dormant]` tags and an evidence-anchored one-liner for each entry:

```text
Tier S — genius
  benchie [LIVE] — predicts engine latency without launching it
    (perfmodel/roofline.py), 72 commits this week.

Tier A — elegant, high-leverage
  searxng-mcp — token-efficient self-hosted search for agents; dual-IP failover.

Dormant
  old-scraper — last real commit pre-cutoff; cosmetic touch since.
```

## What it does

Project Prospector is a Claude Code + Grok plugin and skill that discovers, catalogs, and ranks *your own* work across a machine. Half-finished repos, one-off scripts, dormant ideas, running services, notes, and research artifacts land in one S–D tiered ranking by idea novelty and leverage — not polish, not lines of code.

It runs a two-pass, parallel, read-only multi-agent sweep, then synthesizes one ranking:

1. **Catalog pass** — clusters the filesystem into themed groups (crypto, homelab, AI tooling — not alphabetical). Each cluster gets a read-only explorer agent that reads READMEs, runs `git log` since the cutoff, and judges non-git dirs by file mtimes.
2. **Blind-spot pass** — a second wave of agents hits places a plain directory walk misses (transcripts, other agent CLIs, live services, research artifacts, beyond-home paths).
3. **Synthesize** — de-duplicates, separates idea quality from execution state, and emits an evidence-anchored S–D ranking with optional alternative lenses.

A half-built concept with a novel core can outrank a polished CRUD app. The name is the intent: prospect a messy filesystem for the few strong ideas buried in it.

## Features

| Feature | What it does |
| --- | --- |
| Two-pass multi-agent sweep | Catalog clusters in parallel, then blind-spot agents for coverage |
| Novelty / leverage ranking | S–D tiers on idea quality, not finish state or LOC |
| Idea / LIVE / dormant tags | Separates insight quality from execution state on every entry |
| Evidence-anchored rationale | Paths, commit counts, and numbers verified against disk |
| Time window + scope | Relative cutoffs, theme/dir roots, and path exclusions honored by every agent |
| Read-only by design | Inspect only — never edits, moves, deletes, commits, or starts services |
| Alternative lenses | Initiative clustering, momentum, kill list, authorship, loss-risk |
| Complements total-recall | One-shot ranked census, not a persistent operator memory profile |

## Why two passes

One agent reading directories top to bottom misses most of the value. Strong ideas hide where a plain `ls` never reaches. The blind-spot pass covers:

| Blind spot | Where it looks | What it finds |
| --- | --- | --- |
| Transcripts | `~/.claude/projects/` (idea/plan language) | Ideas discussed but never turned into a folder |
| Other agent CLIs | `~/.codex/`, `~/.opencode/`, `~/.config/` agent tools | Work done through other coding agents |
| Running services | Shell history, cron, user systemd, `docker ps -a`, long-running processes | What is actually live versus abandoned |
| Research artifacts | Downloads, Documents, Desktop, browser bookmarks/history | Ideas you're circling but haven't built |
| Beyond home | `/opt`, `/srv`, `/mnt`, `/media`, nested repos, system-wide recent source | Work outside the obvious home tree |

## How it ranks

Default axis: idea novelty, non-obvious insight, and leverage.

| Tier | Meaning |
| --- | --- |
| S — genius | Genuinely novel core insight, high ceiling |
| A — elegant, high-leverage | Strong idea, clear payoff |
| B — clever hacks, narrower | Smart but bounded in scope |
| C — solid, low novelty | Useful and reliable, not inventive |
| D + Dormant | Utility, scratch, stubs; plus untouched pre-cutoff work |

Each entry carries a tag that separates the idea from its execution state: `[idea]` (no codebase yet — can still rank at the top), `[LIVE]` (currently running), `[dormant]` (untouched before the cutoff). Every cited path, commit count, or number is verified against disk before it goes in the report.

<details>
<summary>Alternative lenses (ask for any of these instead)</summary>

- **Initiative clustering** — group projects into real themes and rank the clusters by coherence.
- **Momentum** — accelerating versus stalled, by the trend of commits over time.
- **Kill list** — what to archive or delete as dead weight, with the reason.
- **Authorship / provenance** — an honest share of what you wrote versus vendored, forked, or scaffolded.
- **Loss-risk / bus-factor** — valuable work in danger of vanishing (zero commits, unpushed branches, scratch dirs, no backup).

</details>

## Usage and arguments

Two inputs shape every run, both stated in plain language:

- **Time window** — relative dates resolve to an absolute cutoff (e.g. "last 3 months"). Defaults to roughly 3 months if unspecified, and says so. Recency is judged by substantive activity (real commits, content of changes), not raw mtimes bumped by a generated file or a formatting-only commit.
- **Scope and exclusions** — narrow to a theme ("just my homelab projects"), a directory, or a non-home root, and exclude paths to skip ("ignore my work repo"). The exclusion is honored verbatim by every agent.

```text
Take stock of my half-finished repos from this week.
Catalog my side projects, but ignore my day-job monorepo.
What's the single most original thing I've built since I started benchie?
Audit /srv on this server and give me the kill list.
```

The written deliverable scales to the ask: a top-3 question gets a short shortlist; "catalog everything" gets the full S–D census with the dormant tail.

> [!NOTE]
> Project Prospector is strictly read-only. It inspects; it never edits, moves, deletes, commits, or starts and stops services. Everything read off disk is treated as untrusted data, not instructions (prompt-injection hardened). If a finding warrants action, that is a separate step you confirm explicitly.

## What it bundles

One skill (`project-prospector`) plus reference agent-prompt templates and a trigger and task eval set. Read-only, general-purpose, no MCP, hooks, or scripts.

It complements [total-recall](https://github.com/88plug/total-recall) (persistent operator memory) rather than duplicating it: prospector produces a one-shot ranked project census, not a memory profile.

## Development

Local clone for development only:

```text
git clone https://github.com/88plug/project-prospector
/plugin marketplace add ./project-prospector
/plugin install project-prospector@88plug
```

## Contributing

Issues and pull requests are welcome at [88plug/project-prospector](https://github.com/88plug/project-prospector). The [plugin-validate](https://github.com/88plug/project-prospector/actions/workflows/plugin-validate.yml) workflow checks the plugin manifest and skill structure on every push.

## License

[FSL-1.1-ALv2](LICENSE) © 2026 [88plug](https://github.com/88plug) — Functional Source License; converts to Apache 2.0 two years after each release.
