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

rm -rf "$h" "$h2"
if [ "$fails" -eq 0 ]; then printf '\nAll tests passed.\n'; else printf '\n%d test(s) failed.\n' "$fails"; exit 1; fi
