# project-prospector

A Claude Code plugin that discovers, catalogs, and ranks **everything you've
built or sketched** on a machine — half-finished repos, one-off scripts, dormant
ideas, running services — and synthesizes it into an opinionated, tiered ranking
by idea-novelty and leverage (not polish).

## What it does

A two-pass parallel, **read-only** sweep:

1. **Catalog pass** — cluster the filesystem into themed groups, one read-only
   explorer agent per cluster (READMEs, recent `git log`, mtimes).
2. **Blind-spot pass** — agents that look where a file sweep misses: shell/agent
   transcripts, other AI-CLI histories, running services, research artifacts,
   and anything beyond the home directory.
3. **Synthesize** — an S–D tiered ranking with `[idea]/[LIVE]/[dormant]` tags,
   evidence-anchored one-liners, dedup, and alternative lenses (momentum,
   kill-list, loss-risk). Everything read off disk is treated as untrusted data
   (prompt-injection hardened).

## What it bundles

One skill (`project-prospector`) plus reference agent-prompt templates and a
trigger/task eval set. Read-only, general-purpose, no MCP/hooks/scripts.

Complements `total-recall` (persistent operator memory) rather than duplicating
it: prospector produces a one-shot ranked project census, not a memory profile.

## Install

```
/plugin marketplace add 88plug/project-prospector
/plugin install project-prospector@project-prospector
```

Or from a local clone:

```
git clone https://github.com/88plug/project-prospector
/plugin marketplace add ./project-prospector
/plugin install project-prospector@project-prospector
```

## License

[FSL-1.1-ALv2](LICENSE.md) © 2026 [88plug](https://github.com/88plug) —
Functional Source License; converts to Apache 2.0 two years after each release.
