#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"
PY="${PYTHON:-python3}"

echo "=== smoke: manifest is valid JSON ==="
"$PY" -c "import json; json.load(open('.claude-plugin/plugin.json')); print('  ok: .claude-plugin/plugin.json')"
"$PY" -c "import json; json.load(open('.claude-plugin/marketplace.json')); print('  ok: .claude-plugin/marketplace.json')"

echo "=== smoke: eval fixtures are valid JSON ==="
for f in skills/project-prospector/evals/*.json; do
    "$PY" -c "import json,sys; json.load(open(sys.argv[1])); print('  ok:', sys.argv[1])" "$f"
done

echo "=== smoke: SKILL.md frontmatter present ==="
test -f skills/project-prospector/SKILL.md && head -1 skills/project-prospector/SKILL.md | grep -q '^---' && echo "  ok: SKILL.md frontmatter"

echo "=== smoke: all good ==="
