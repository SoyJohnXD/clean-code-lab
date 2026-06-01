#!/usr/bin/env bash
# Tests for the intent-overlay CLI — run: bash overlay/intent-overlay.test.sh
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
CLI="$HERE/intent-overlay"

fails=0
pass() { printf 'ok   - %s\n' "$1"; }
fail() { printf 'FAIL - %s\n' "$1"; fails=$((fails + 1)); }

# Each test runs the CLI against a throwaway HOME so the real ~/.codex is never touched.
new_home() {
  local h
  h=$(mktemp -d)
  mkdir -p "$h/.codex/skills" "$h/.claude/skills" "$h/.agents/skills"
  printf '%s' "$h"
}

# --- install copies the canonical into the hub
h=$(new_home)
HOME="$h" bash "$CLI" install >/dev/null 2>&1
[ -f "$h/.codex/skills/intent-overlay/SKILL.md" ] && pass "install creates canonical in hub" || fail "install creates canonical in hub"

# --- install symlinks into existing user roots
canon="$h/.codex/skills/intent-overlay"
if [ -L "$h/.claude/skills/intent-overlay" ] && [ "$(readlink "$h/.claude/skills/intent-overlay")" = "$canon" ]; then
  pass "install symlinks into .claude/skills"; else fail "install symlinks into .claude/skills"; fi
if [ -L "$h/.agents/skills/intent-overlay" ] && [ "$(readlink "$h/.agents/skills/intent-overlay")" = "$canon" ]; then
  pass "install symlinks into .agents/skills"; else fail "install symlinks into .agents/skills"; fi

# --- install does not create roots that do not exist
[ ! -e "$h/.pi/agent/skills/intent-overlay" ] && pass "install skips absent roots" || fail "install skips absent roots"

# --- install is idempotent
HOME="$h" bash "$CLI" install >/dev/null 2>&1
[ "$(HOME="$h" bash "$CLI" install >/dev/null 2>&1; echo $?)" = "0" ] && pass "install is idempotent" || fail "install is idempotent"

# --- doctor passes when everything is present
HOME="$h" bash "$CLI" doctor >/dev/null 2>&1
[ $? -eq 0 ] && pass "doctor passes when healthy" || fail "doctor passes when healthy"

# --- doctor fails on a broken symlink
rm -rf "$canon"
HOME="$h" bash "$CLI" doctor >/dev/null 2>&1
[ $? -ne 0 ] && pass "doctor fails on broken/absent canonical" || fail "doctor fails on broken/absent canonical"

# --- uninstall removes canonical and symlinks
h2=$(new_home)
HOME="$h2" bash "$CLI" install >/dev/null 2>&1
HOME="$h2" bash "$CLI" uninstall >/dev/null 2>&1
if [ ! -e "$h2/.codex/skills/intent-overlay" ] && [ ! -L "$h2/.claude/skills/intent-overlay" ] && [ ! -L "$h2/.agents/skills/intent-overlay" ]; then
  pass "uninstall removes canonical and symlinks"; else fail "uninstall removes canonical and symlinks"; fi

# --- cross-host wiring: a home with all three hosts present
full_home() {
  local h; h=$(mktemp -d)
  mkdir -p "$h/.codex/skills" "$h/.claude/skills" "$h/.agents/skills" "$h/.config/opencode/skills"
  printf '%s' "$h"
}
count_lines() { # count_lines NEEDLE FILE — exact-line occurrences
  local needle=$1 file=$2 line n=0
  [ -f "$file" ] || { echo 0; return; }
  while IFS= read -r line || [ -n "$line" ]; do [ "$line" = "$needle" ] && n=$((n + 1)); done <"$file"
  echo "$n"
}
contains() { # contains NEEDLE FILE — substring anywhere
  local needle=$1 file=$2 line
  [ -f "$file" ] || return 1
  while IFS= read -r line || [ -n "$line" ]; do case "$line" in *"$needle"*) return 0 ;; esac; done <"$file"
  return 1
}

START="<!-- intent-overlay:start -->"
TOML_START="# >>> intent-overlay (managed) >>>"

h3=$(full_home)
HOME="$h3" bash "$CLI" install >/dev/null 2>&1
gate="$h3/.codex/skills/intent-overlay/hooks/check-intent-frozen.sh"

# gate script lands in the hub, executable
{ [ -x "$gate" ]; } && pass "gate script installed and executable" || fail "gate script installed and executable"

# Codex: always-on block + hook block + resolved gate path
[ "$(count_lines "$START" "$h3/.codex/AGENTS.override.md")" = "1" ] && pass "codex always-on block injected once" || fail "codex always-on block injected once"
contains "$TOML_START" "$h3/.codex/config.toml" && pass "codex hook block injected" || fail "codex hook block injected"
contains "$gate" "$h3/.codex/config.toml" && pass "codex hook references resolved gate path" || fail "codex hook references resolved gate path"

# Claude: always-on block + valid settings.json carrying our entry
[ "$(count_lines "$START" "$h3/.claude/CLAUDE.md")" = "1" ] && pass "claude always-on block injected once" || fail "claude always-on block injected once"
HOME="$h3" python3 -c "import json,sys; d=json.load(open(sys.argv[1])); assert any('check-intent-frozen.sh' in json.dumps(e) for e in d['hooks']['PreToolUse'])" "$h3/.claude/settings.json" 2>/dev/null && pass "claude settings.json has valid hook entry" || fail "claude settings.json has valid hook entry"

# OpenCode: always-on block + plugin with __GATE__ resolved
[ "$(count_lines "$START" "$h3/.config/opencode/AGENTS.md")" = "1" ] && pass "opencode always-on block injected once" || fail "opencode always-on block injected once"
plugin="$h3/.config/opencode/plugins/intent-overlay-gate.ts"
{ [ -f "$plugin" ] && contains "$gate" "$plugin" && ! contains "__GATE__" "$plugin"; } && pass "opencode plugin installed with resolved gate" || fail "opencode plugin installed with resolved gate"

# always-on injection is idempotent (re-install does not duplicate the block)
HOME="$h3" bash "$CLI" install >/dev/null 2>&1
[ "$(count_lines "$START" "$h3/.claude/CLAUDE.md")" = "1" ] && pass "always-on injection is idempotent" || fail "always-on injection is idempotent"

# doctor on a fully wired home passes
HOME="$h3" bash "$CLI" doctor >/dev/null 2>&1 && pass "doctor passes on a fully wired home" || fail "doctor passes on a fully wired home"

# uninstall reverses host wiring
HOME="$h3" bash "$CLI" uninstall >/dev/null 2>&1
no_block=1
for f in "$h3/.codex/AGENTS.override.md" "$h3/.codex/config.toml" "$h3/.claude/CLAUDE.md" "$h3/.config/opencode/AGENTS.md"; do
  contains "intent-overlay" "$f" && no_block=0
done
[ "$no_block" = "1" ] && pass "uninstall removes all host blocks" || fail "uninstall removes all host blocks"
[ ! -f "$plugin" ] && pass "uninstall removes opencode plugin" || fail "uninstall removes opencode plugin"
HOME="$h3" python3 -c "import json,sys; d=json.load(open(sys.argv[1])); assert 'hooks' not in d or not any('check-intent-frozen.sh' in json.dumps(e) for e in d.get('hooks',{}).get('PreToolUse',[]))" "$h3/.claude/settings.json" 2>/dev/null && pass "uninstall removes claude hook entry, keeps valid json" || fail "uninstall removes claude hook entry, keeps valid json"

# freeze / unfreeze write and remove the sentinel
proj=$(mktemp -d)
HOME="$h3" bash "$CLI" freeze demo "$proj" >/dev/null 2>&1
[ -f "$proj/.atl/intent/demo.frozen" ] && pass "freeze writes the sentinel" || fail "freeze writes the sentinel"
HOME="$h3" bash "$CLI" unfreeze demo "$proj" >/dev/null 2>&1
[ ! -f "$proj/.atl/intent/demo.frozen" ] && pass "unfreeze removes the sentinel" || fail "unfreeze removes the sentinel"

rm -rf "$h" "$h2" "$h3" "$proj"
if [ "$fails" -eq 0 ]; then printf '\nAll tests passed.\n'; else printf '\n%d test(s) failed.\n' "$fails"; exit 1; fi
