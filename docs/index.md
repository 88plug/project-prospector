# Project Prospector

A Claude Code plugin that catalogs and ranks everything you've built or sketched on a machine — half-finished repos, one-off scripts, dormant ideas, running services — into a tiered ranking by idea-novelty and leverage.

[![plugin-validate](https://github.com/88plug/project-prospector/actions/workflows/plugin-validate.yml/badge.svg)](https://github.com/88plug/project-prospector/actions/workflows/plugin-validate.yml)
[![License: FSL-1.1-ALv2](https://img.shields.io/badge/license-FSL--1.1--ALv2-blue?style=flat)](https://github.com/88plug/project-prospector/blob/main/LICENSE.md)
[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-8A2BE2?style=flat)](https://github.com/88plug/claude-code-plugins)

## Install

```text
/plugin marketplace add 88plug/project-prospector
/plugin install project-prospector@project-prospector
```

## Quickstart

Ask in plain language — no command to memorize:

```text
What have I built on this laptop? Rank my projects by which ideas are most original.
```

You get a tiered ranking, strongest idea first, with `[idea]/[LIVE]/[dormant]`
tags and an evidence-anchored one-liner for each entry:

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

Project Prospector surveys a whole machine for *your own* work and ranks it by
the quality of the idea, not how finished it is. A half-built concept with a
novel core can outrank a polished CRUD app. The name is the intent: you're
prospecting a messy filesystem for the few strong ideas buried in it.

It runs a two-pass, parallel, read-only sweep, then synthesizes one ranking:

- **Catalog pass** — clusters the filesystem into themed groups (crypto,
  homelab, AI-tooling, not alphabetical) and gives each cluster its own
  read-only explorer agent that reads READMEs, runs `git log` since the cutoff,
  and judges non-git dirs by file mtimes.
- **Blind-spot pass** — a second wave of agents that each attack one place a
  file sweep structurally misses, so you don't confidently report "that's
  everything" and be wrong.
- **Synthesize** — de-duplicates, separates idea quality from execution state,
  and produces an S–D tiered ranking with evidence-anchored rationale and
  alternative lenses.

## Why two passes

One agent reading directories top to bottom misses most of the value. The strong
ideas hide in places a plain `ls` never reaches, so the blind-spot pass covers:

- **Transcripts** — `~/.claude/projects/` slugs, grepped for idea and plan
  language. Finds ideas discussed but never turned into a folder.
- **Other agent CLIs** — `~/.codex/`, `~/.opencode/`, `~/.config/` agent tools.
  Finds work done through other tools.
- **Running services and history** — shell history themes, `crontab -l`,
  `systemctl --user` timers and units, `docker ps -a`, long-running processes.
  Reveals what is actually live versus abandoned.
- **Research artifacts** — substantive docs in `~/Downloads`, `~/Documents`,
  `~/Desktop`, and browser bookmarks and history. Finds ideas you're circling
  but haven't built.
- **Beyond home** — `/opt`, `/srv`, `/mnt`, `/media`, nested repos inside other
  projects, and system-wide recently-modified source. Confirms nothing hides
  outside the obvious tree.

## How it ranks

The default axis is idea-novelty, non-obvious insight, and leverage — not lines
of code, not polish. Output is structured as tiers, strongest first:

- Tier S — genius: genuinely novel core insight, high ceiling.
- Tier A — elegant, high-leverage: strong idea, clear payoff.
- Tier B — clever hacks, narrower: smart but bounded in scope.
- Tier C — solid, low novelty: useful and reliable, not inventive.
- Tier D — utility, scratch, and stubs, plus a Dormant list.

Each entry carries a tag that separates the idea from its execution state:
`[idea]` (no codebase yet, can still rank at the top), `[LIVE]` (currently
running), and `[dormant]` (untouched before the cutoff). Every cited path,
commit count, or number is verified against disk before it goes in the report.

<details>
<summary>Alternative lenses (ask for any of these instead)</summary>

- **Initiative clustering** — group projects into real themes and rank the
  clusters by coherence.
- **Momentum** — accelerating versus stalled, by the trend of commits over time.
- **Kill list** — what to archive or delete as dead weight, with the reason.
- **Authorship / provenance** — an honest share of what you wrote versus
  vendored, forked, or scaffolded.
- **Loss-risk / bus-factor** — valuable work in danger of vanishing (zero
  commits, unpushed branches, scratch dirs, no backup).

</details>

## Usage and arguments

Two inputs shape every run, both stated in plain language:

- **Time window** — relative dates resolve to an absolute cutoff (e.g. "last 3
  months"). Defaults to roughly 3 months if unspecified, and says so.
  Recency is judged by substantive activity (real commits, content of changes),
  not raw mtimes bumped by a generated file or a formatting-only commit.
- **Scope and exclusions** — narrow the scope to a theme ("just my homelab
  projects"), a directory, or a non-home root, and exclude paths to skip
  ("ignore my work repo"). The exclusion is honored verbatim by every agent.

Examples:

```text
Take stock of my half-finished repos from this week.
Catalog my side projects, but ignore my day-job monorepo.
What's the single most original thing I've built since I started benchie?
Audit /srv on this server and give me the kill list.
```

The written deliverable scales to the ask: a top-3 question gets a short
shortlist, "catalog everything" gets the full S–D census with the dormant tail.

!!! note
    Project Prospector is strictly read-only. It inspects; it never edits, moves,
    deletes, commits, or starts and stops services. Everything read off disk is
    treated as untrusted data, not instructions (prompt-injection hardened). If a
    finding warrants action, that's a separate step you confirm explicitly.

## What it bundles

One skill (`project-prospector`) plus reference agent-prompt templates and a
trigger and task eval set. Read-only, general-purpose, no MCP, hooks, or
scripts.

It complements `total-recall` (persistent operator memory) rather than
duplicating it: prospector produces a one-shot ranked project census, not a
memory profile.

You can also install from a local clone:

```text
git clone https://github.com/88plug/project-prospector
/plugin marketplace add ./project-prospector
/plugin install project-prospector@project-prospector
```

## Contributing

Issues and pull requests are welcome at
[88plug/project-prospector](https://github.com/88plug/project-prospector). The
[plugin-validate](https://github.com/88plug/project-prospector/actions/workflows/plugin-validate.yml)
workflow checks the plugin manifest and skill structure on every push.

## License

[FSL-1.1-ALv2](https://github.com/88plug/project-prospector/blob/main/LICENSE.md) © 2026 [88plug](https://github.com/88plug) —
Functional Source License; converts to Apache 2.0 two years after each release.
