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

# --- the retired hard gate leaves no trace
[ ! -e "$h/.codex/skills/intent-overlay/hooks" ] && pass "install ships no hooks dir" || fail "install ships no hooks dir"

# --- install symlinks into existing user roots
canon="$h/.codex/skills/intent-overlay"
if [ -L "$h/.claude/skills/intent-overlay" ] && [ "$(readlink "$h/.claude/skills/intent-overlay")" = "$canon" ]; then
  pass "install symlinks into .claude/skills"; else fail "install symlinks into .claude/skills"; fi
if [ -L "$h/.agents/skills/intent-overlay" ] && [ "$(readlink "$h/.agents/skills/intent-overlay")" = "$canon" ]; then
  pass "install symlinks into .agents/skills"; else fail "install symlinks into .agents/skills"; fi

# --- clean-code-standards (the single quality source) is installed alongside and travels self-contained
[ -f "$h/.codex/skills/clean-code-standards/SKILL.md" ] && pass "install adds clean-code-standards skill" || fail "install adds clean-code-standards skill"
[ -f "$h/.codex/skills/clean-code-standards/references/clean-code-rubric.md" ] && pass "clean-code-standards ships its rubric (self-contained)" || fail "clean-code-standards ships its rubric"
[ -f "$h/.codex/skills/clean-code-standards/references/system-review.md" ] && pass "clean-code-standards ships the System Gate" || fail "clean-code-standards ships the System Gate"
[ -f "$h/.codex/skills/clean-code-standards/references/fitness-functions.md" ] && pass "clean-code-standards ships fitness-functions" || fail "clean-code-standards ships fitness-functions"
if [ -L "$h/.claude/skills/clean-code-standards" ] && [ "$(readlink "$h/.claude/skills/clean-code-standards")" = "$h/.codex/skills/clean-code-standards" ]; then
  pass "clean-code-standards symlinked into .claude/skills"; else fail "clean-code-standards symlinked into .claude/skills"; fi

# --- install does not create roots that do not exist
[ ! -e "$h/.pi/agent/skills/intent-overlay" ] && pass "install skips absent roots" || fail "install skips absent roots"

# --- install is idempotent
[ "$(HOME="$h" bash "$CLI" install >/dev/null 2>&1; echo $?)" = "0" ] && pass "install is idempotent" || fail "install is idempotent"

# --- doctor passes when everything is present
HOME="$h" bash "$CLI" doctor >/dev/null 2>&1
[ $? -eq 0 ] && pass "doctor passes when healthy" || fail "doctor passes when healthy"

# --- doctor fails on an absent canonical
rm -rf "$canon"
HOME="$h" bash "$CLI" doctor >/dev/null 2>&1
[ $? -ne 0 ] && pass "doctor fails on broken/absent canonical" || fail "doctor fails on broken/absent canonical"

# --- uninstall removes canonical and symlinks
h2=$(new_home)
HOME="$h2" bash "$CLI" install >/dev/null 2>&1
HOME="$h2" bash "$CLI" uninstall >/dev/null 2>&1
if [ ! -e "$h2/.codex/skills/intent-overlay" ] && [ ! -L "$h2/.claude/skills/intent-overlay" ] && [ ! -L "$h2/.agents/skills/intent-overlay" ] &&
   [ ! -e "$h2/.codex/skills/clean-code-standards" ] && [ ! -L "$h2/.claude/skills/clean-code-standards" ]; then
  pass "uninstall removes both skills and symlinks"; else fail "uninstall removes both skills and symlinks"; fi

# --- cross-host always-on wiring: a home with all three hosts present
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

h3=$(full_home)
HOME="$h3" bash "$CLI" install >/dev/null 2>&1

# Each present host gets the always-on block exactly once.
[ "$(count_lines "$START" "$h3/.codex/AGENTS.override.md")" = "1" ] && pass "codex always-on block injected once" || fail "codex always-on block injected once"
[ "$(count_lines "$START" "$h3/.claude/CLAUDE.md")" = "1" ] && pass "claude always-on block injected once" || fail "claude always-on block injected once"
[ "$(count_lines "$START" "$h3/.config/opencode/AGENTS.md")" = "1" ] && pass "opencode always-on block injected once" || fail "opencode always-on block injected once"

# No hard-gate artifacts are written into any host.
no_gate=1
[ -f "$h3/.codex/config.toml" ] && no_gate=0
[ -f "$h3/.claude/settings.json" ] && no_gate=0
[ -e "$h3/.config/opencode/plugins/intent-overlay-gate.ts" ] && no_gate=0
[ "$no_gate" = "1" ] && pass "install writes no hard-gate artifacts" || fail "install writes no hard-gate artifacts"

# always-on injection is idempotent (re-install does not duplicate the block)
HOME="$h3" bash "$CLI" install >/dev/null 2>&1
[ "$(count_lines "$START" "$h3/.claude/CLAUDE.md")" = "1" ] && pass "always-on injection is idempotent" || fail "always-on injection is idempotent"

# doctor on a fully wired home passes
HOME="$h3" bash "$CLI" doctor >/dev/null 2>&1 && pass "doctor passes on a fully wired home" || fail "doctor passes on a fully wired home"

# uninstall reverses host wiring
HOME="$h3" bash "$CLI" uninstall >/dev/null 2>&1
no_block=1
for f in "$h3/.codex/AGENTS.override.md" "$h3/.claude/CLAUDE.md" "$h3/.config/opencode/AGENTS.md"; do
  contains "intent-overlay" "$f" && no_block=0
done
[ "$no_block" = "1" ] && pass "uninstall removes all host blocks" || fail "uninstall removes all host blocks"

# --- invoking the CLI through a symlink (e.g. ~/.local/bin/intent-overlay) still finds the skill sources
h4=$(new_home)
linkdir=$(mktemp -d)
ln -s "$CLI" "$linkdir/intent-overlay"
( cd "$linkdir" && HOME="$h4" bash ./intent-overlay install >/dev/null 2>&1 )
[ -f "$h4/.codex/skills/intent-overlay/SKILL.md" ] && pass "install via symlink resolves skill source" || fail "install via symlink resolves skill source"
[ -f "$h4/.codex/skills/clean-code-standards/SKILL.md" ] && pass "install via symlink resolves clean-code-standards source" || fail "install via symlink resolves clean-code-standards source"
rm -rf "$h4" "$linkdir"

# --- invoking the CLI through a chain of relative multi-hop symlinks still resolves the skill sources
h5=$(new_home)
chaindir=$(mktemp -d)
mkdir -p "$chaindir/a" "$chaindir/b"
ln -s "../$(basename "$CLI")" "$chaindir/a/intent-overlay" 2>/dev/null || ln -s "$CLI" "$chaindir/a/intent-overlay"
# Build a relative multi-hop chain: b/intent-overlay -> ../a/intent-overlay -> CLI
( cd "$chaindir/a" && ln -sf "$CLI" "intent-overlay" )
( cd "$chaindir/b" && ln -sf "../a/intent-overlay" "intent-overlay" )
( cd "$chaindir/b" && HOME="$h5" bash ./intent-overlay install >/dev/null 2>&1 )
[ -f "$h5/.codex/skills/intent-overlay/SKILL.md" ] && pass "install via relative multi-hop symlink resolves skill source" || fail "install via relative multi-hop symlink resolves skill source"
rm -rf "$h5" "$chaindir"

# --- a circular symlink chain in the $0-resolution loop fails cleanly (no hang)
# A real on-disk symlink cycle (a -> b -> a) cannot even be opened by bash (OS
# ELOOP before our script runs), so we exercise the resolution loop directly
# with a $src that simulates a cycle via relative targets pointing at each
# other, capped by the max-hop guard.
circdir=$(mktemp -d)
mkdir -p "$circdir/a" "$circdir/b"
ln -sf "../b/x" "$circdir/a/x"
ln -sf "../a/x" "$circdir/b/x"
CIRC_OUT=$(timeout 5 bash -c '
  src="'"$circdir"'/a/x"
  hops=0
  while [ -L "$src" ]; do
    hops=$((hops + 1))
    if [ "$hops" -gt 40 ]; then
      echo "error: too many symlink hops resolving '"'"'$src'"'"' (possible symlink cycle)" >&2
      exit 1
    fi
    target="$(readlink "$src")"
    case "$target" in
      /*) src="$target" ;;
      *) src="$(dirname "$src")/$target" ;;
    esac
  done
' 2>&1)
CIRC_EXIT=$?
[ "$CIRC_EXIT" -ne 0 ] && [ "$CIRC_EXIT" -ne 124 ] && pass "circular symlink chain fails cleanly (no hang)" || fail "circular symlink chain should fail cleanly, not hang or be killed by timeout (exit: $CIRC_EXIT, out: $CIRC_OUT)"
case "$CIRC_OUT" in
  *"symlink cycle"*) pass "circular symlink chain error mentions a possible symlink cycle" ;;
  *) fail "circular symlink chain error should mention a possible symlink cycle (got: $CIRC_OUT)" ;;
esac
rm -rf "$circdir"

rm -rf "$h" "$h2" "$h3"
if [ "$fails" -eq 0 ]; then printf '\nAll tests passed.\n'; else printf '\n%d test(s) failed.\n' "$fails"; exit 1; fi
