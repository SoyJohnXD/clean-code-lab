#!/usr/bin/env bash
# Scriptable layer of the closed test: confirms the overlay is activated as a project-skill in this
# repo and is shaped so gentle-ai would index and inject it. Does NOT invoke the gentle-ai binary
# (its subcommands self-upgrade). Run: bash overlay/dogfood/check.sh
set -u

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LINK="$ROOT/skills/intent-overlay"
SKILL="$LINK/SKILL.md"

fails=0
ok() { printf 'ok   - %s\n' "$1"; }
no() { printf 'FAIL - %s\n' "$1"; fails=$((fails + 1)); }

file_contains() {
  local needle=$1 line
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in *"$needle"*) return 0 ;; esac
  done <"$2"
  return 1
}

[ -L "$LINK" ] && ok "project-skill symlink present: skills/intent-overlay" || no "project-skill symlink missing (run: ln -sfn ../overlay/skill skills/intent-overlay)"
[ -f "$SKILL" ] && ok "SKILL.md reachable through the symlink" || no "SKILL.md not reachable through the symlink"
{ [ -f "$SKILL" ] && file_contains "## Compact Rules" "$SKILL"; } && ok "SKILL.md declares Compact Rules (gentle will inject them)" || no "SKILL.md missing Compact Rules"
[ -f "$ROOT/overlay/dogfood/proposal.md" ] && ok "approved proposal fixture present" || no "proposal.md missing"
[ -f "$ROOT/overlay/dogfood/drift-task.md" ] && ok "drift-task fixture present" || no "drift-task.md missing"
[ -d "$ROOT/workspaces/dogfood-counter" ] && ok "target workspace present" || no "workspaces/dogfood-counter missing"

if [ "$fails" -eq 0 ]; then
  printf '\nReady: ./skills is a scanned root, so /skill-registry:refresh will index intent-overlay for THIS repo only.\n'
else
  printf '\n%d check(s) failed.\n' "$fails"; exit 1
fi
