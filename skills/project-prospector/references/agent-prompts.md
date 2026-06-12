# Agent prompt templates

Copy these, fill the `<BRACKETS>`, and spawn each as an **Explore** subagent.
Spawn all of one pass in a single message so they run in parallel. Keep every
agent read-only and word-budgeted — you want conclusions, not file dumps.

Two placeholders appear in every prompt:
- `<CUTOFF>` — the absolute date you derived (e.g. `2026-03-03`).
- `<EXCLUSIONS>` — paths/projects to skip, verbatim (e.g. "EXCLUDE /home/x/work-repo").
  If there are none, write "none".

---

## Pass 1 — cluster sweep (one per cluster)

> Investigate these related directories owned by the user:
> `<DIR_1>`, `<DIR_2>`, `<DIR_3>` …
>
> Goal: tell me what the user built/designed in each and the IDEAS behind them,
> focusing on work since `<CUTOFF>`. `<EXCLUSIONS>`.
>
> For EACH project:
> 1. Read README / docs / package.json / pyproject to identify purpose and stack.
> 2. If it's a git repo, run `git -C <dir> log --since=<CUTOFF> --stat --oneline`
>    and `git -C <dir> log --oneline -25` for context. If it's NOT a git repo,
>    judge activity from file mtimes (`ls -la --time-style=long-iso <dir>`).
> 3. Infer the product concept and how far along it is.
>
> Return a CONCISE structured report (under ~450 words, NOT file dumps). Per
> project: **one-liner · core idea · tech stack · activity since `<CUTOFF>`
> · maturity**. Flag anything untouched before `<CUTOFF>` as dormant rather than
> padding the report. Read-only — do not modify anything.

Notes when filling this in:
- Put a lone large/multi-component repo in its **own** agent and tell it this is a
  single-project deep dive (raise the budget to ~500 words).
- For clusters mixing a vendored upstream clone with the user's fork, tell the
  agent to report **what the user changed**, not what the upstream does.

---

## Pass 2 — blind spots

Give all five the **known-projects list** from Pass 1 and tell them to surface
only what's NEW or missed. Spawn together.

### 2a. Transcripts

> Deep-mine the user's Claude Code SESSION TRANSCRIPTS for project ideas, plans,
> and work that may NOT correspond to any directory. `<EXCLUSIONS>`.
>
> 1. `ls ~/.claude/projects/` — each subdir is a slug encoding the working dir
>    (slashes → dashes). List the slugs; flag any whose implied path is NOT in
>    this known list: `<KNOWN_PROJECTS>` — especially slugs under /tmp, /opt,
>    /mnt, or unfamiliar names.
> 2. Do NOT bulk-read the `.jsonl` (huge). Instead grep for idea signals, e.g.
>    `grep -rhoE "(idea|let's build|what if we|I want to build|new project|prototype|concept)[^\"]{0,160}" ~/.claude/projects/ | sort -u | head -200`
>    and `du -sh ~/.claude/projects/* | sort -h` to gauge effort by size. Sample
>    the first user message of the largest/newest transcripts for the goal.
> 3. Surface DISTINCT ideas the directory sweep would miss — discussed-but-never-
>    built, or built somewhere unusual.
>
> Return under ~550 words: slug→implied-dir→known/new table; a bulleted list of
> transcript-only ideas; anything pointing outside the home dir. Read-only.

### 2b. Other agent CLIs

> Find work done via OTHER AI coding agents and tools besides Claude Code.
> `<EXCLUSIONS>`.
>
> Explore `~/.codex/` (sessions, history, config, memories), `~/.opencode/`
> (sessions/config), and scan `~/.config/` subdir NAMES for agent/dev tools
> (goose, crush, gemini, aider, cursor, zed, continue, vllm, litellm, crewai…).
> For each agent tool, peek at session/history to find distinct working dirs and
> the GOAL of each session; note dates since `<CUTOFF>` and gauge effort with
> `du -sh`.
>
> Return under ~500 words: what each tool was used for (bulleted, with dates), and
> any NEW idea/project not in this known list: `<KNOWN_PROJECTS>`. Read-only.

### 2c. Running services & history

> Find what the user has actually been RUNNING and doing since `<CUTOFF>`, via
> shell history, scheduled jobs, services, and containers. `<EXCLUSIONS>`.
>
> 1. `tail -n 600 ~/.zhistory` (and `~/.bash_history` if present); grep for
>    one-off experiments (builds, curl to APIs, docker runs, git clones).
>    Summarize THEMES and surface anything new.
> 2. `crontab -l`, `ls -la /etc/cron.d/`, `systemctl --user list-timers --all`,
>    `systemctl --user list-units --type=service --all`, and `~/.config/systemd/
>    user/` for user-authored units — describe what each does.
> 3. `docker ps -a --format '{{.Names}}\t{{.Image}}\t{{.Status}}'` and
>    `docker images | head -40` to see which projects are LIVE.
> 4. `ps aux | grep -iE 'python|node|go run|llama|vllm|frpc|uvicorn' | grep -v grep`
>    for long-running project processes.
>
> Return under ~550 words: history themes; user-authored jobs/units; running
> containers/processes → which projects are LIVE; any NEW project/tool. Read-only,
> do not start/stop anything.

### 2d. Research artifacts

> Deep-read the user's RESEARCH artifacts and browser research for idea-level work
> that never became code. `<EXCLUSIONS>`.
>
> 1. `find ~/Downloads -maxdepth 2 -newermt <CUTOFF> -type f -printf '%TY-%Tm-%Td %s %p\n' | sort`
>    then READ the substantive research docs (markdown/txt/pdf reports — NOT
>    installers/ISOs/images) and extract each one's THESIS in a line. Also check
>    `~/Documents` and `~/Desktop` for notes.
> 2. Firefox: find the profile under `~/.mozilla/firefox/`, then bookmarks/history
>    from `places.sqlite`, e.g.
>    `sqlite3 <profile>/places.sqlite "SELECT url,title,datetime(last_visit_date/1000000,'unixepoch') FROM moz_places ORDER BY last_visit_date DESC LIMIT 200"`.
>    If sqlite3 is unavailable or the DB is locked, skip gracefully and say so.
>    Summarize research THEMES (not a URL dump) and note specific repos/products.
> 3. Surface any idea NOT already a known project: `<KNOWN_PROJECTS>`.
>
> Return under ~600 words: research docs → one-line thesis each (grouped by
> theme); browser themes + notable repos/products; NEW unbuilt ideas. Read-only.

### 2e. Beyond home

> Sweep for projects OUTSIDE the obvious top-level home dirs, and deeper inside
> home. `<EXCLUSIONS>`.
>
> 1. `ls -la /opt /srv /mnt /media /data 2>/dev/null` and
>    `find /opt /srv /mnt /media /data -maxdepth 3 -name .git -type d 2>/dev/null`
>    — note anything owned by the user.
> 2. Nested git repos:
>    `find ~ -maxdepth 4 -name .git -type d 2>/dev/null | grep -vE '/(node_modules|\.cache|\.nvm|\.bun|\.local)/'`
>    — flag any inside Documents/Projects/Desktop or nested in another project
>    that's NOT in this known list: `<KNOWN_PROJECTS>`.
> 3. List `~/Projects/` contents and identify each subproject.
> 4. Recently-modified source implying a missed project:
>    `find ~ -maxdepth 3 -type f \( -name '*.py' -o -name '*.go' -o -name '*.ts' -o -name 'README*' \) -newermt <CUTOFF> 2>/dev/null | grep -vE '/(node_modules|\.cache|site-packages)/' | head -120`.
> 5. `ls -la /tmp | grep -iE 'claude|project'` for agent working dirs with real
>    content.
>
> Return under ~500 words: projects found outside ~ (location + one-liner); notable
> nested repos; `~/Projects/` contents; any NEW codebase. Confirm areas that are
> clean rather than padding. Read-only.

---

## Filling in `<KNOWN_PROJECTS>`

After Pass 1, build a short comma-separated list of the project names/dirs already
catalogued and paste it into each Pass-2 prompt. This is what lets Pass-2 agents
report only the delta instead of re-describing what you already know.
