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

echo "=== smoke: evals.json assertions are non-empty machine-checkable strings ==="
"$PY" - <<'PY'
import json
import sys
from pathlib import Path

path = Path("skills/project-prospector/evals/evals.json")
data = json.loads(path.read_text())
evals = data.get("evals")
if not isinstance(evals, list) or not evals:
    print("  FAIL: evals.json missing non-empty evals[]", file=sys.stderr)
    sys.exit(1)
for i, ev in enumerate(evals):
    name = ev.get("name", f"index-{i}")
    assertions = ev.get("assertions")
    if not isinstance(assertions, list) or not assertions:
        print(f"  FAIL: eval {name!r} has empty/missing assertions", file=sys.stderr)
        sys.exit(1)
    for j, a in enumerate(assertions):
        if not isinstance(a, str) or not a.strip():
            print(f"  FAIL: eval {name!r} assertions[{j}] not a non-empty string", file=sys.stderr)
            sys.exit(1)
        if ":" not in a:
            print(f"  FAIL: eval {name!r} assertions[{j}] missing id: description form", file=sys.stderr)
            sys.exit(1)
        key, _, desc = a.partition(":")
        if not key.strip() or not desc.strip():
            print(f"  FAIL: eval {name!r} assertions[{j}] empty key or description", file=sys.stderr)
            sys.exit(1)
    print(f"  ok: {name} ({len(assertions)} assertions)")
print(f"  ok: {len(evals)} evals with non-empty assertions")
PY

echo "=== smoke: trigger-eval.json has should_trigger bools ==="
"$PY" - <<'PY'
import json
import sys
from pathlib import Path

path = Path("skills/project-prospector/evals/trigger-eval.json")
data = json.loads(path.read_text())
if not isinstance(data, list) or not data:
    print("  FAIL: trigger-eval.json must be a non-empty list", file=sys.stderr)
    sys.exit(1)
trues = falses = 0
for i, row in enumerate(data):
    if not isinstance(row, dict) or "query" not in row or "should_trigger" not in row:
        print(f"  FAIL: trigger-eval[{i}] missing query/should_trigger", file=sys.stderr)
        sys.exit(1)
    if not isinstance(row["query"], str) or not row["query"].strip():
        print(f"  FAIL: trigger-eval[{i}] empty query", file=sys.stderr)
        sys.exit(1)
    if not isinstance(row["should_trigger"], bool):
        print(f"  FAIL: trigger-eval[{i}] should_trigger not bool", file=sys.stderr)
        sys.exit(1)
    if row["should_trigger"]:
        trues += 1
    else:
        falses += 1
if trues < 1 or falses < 1:
    print(f"  FAIL: need both true and false cases (true={trues}, false={falses})", file=sys.stderr)
    sys.exit(1)
print(f"  ok: {len(data)} trigger cases ({trues} true / {falses} false)")
PY

echo "=== smoke: SKILL.md frontmatter present ==="
test -f skills/project-prospector/SKILL.md && head -1 skills/project-prospector/SKILL.md | grep -q '^---' && echo "  ok: SKILL.md frontmatter"

echo "=== smoke: all good ==="
