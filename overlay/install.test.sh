#!/usr/bin/env bash
# Tests for install.sh — run: bash overlay/install.test.sh
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
INSTALL="$HERE/install.sh"
START="<!-- intent-overlay:start -->"

fails=0
pass() { printf 'ok   - %s\n' "$1"; }
fail() { printf 'FAIL - %s\n' "$1"; fails=$((fails + 1)); }

count_marker() { # count_marker FILE
  local n=0 line
  while IFS= read -r line || [ -n "$line" ]; do
    [ "$line" = "$START" ] && n=$((n + 1))
  done <"$1"
  printf '%s' "$n"
}

make_fixture() { # make_fixture DIR
  local d=$1
  mkdir -p "$d/overlay/adapters" "$d/.atl"
  printf '# Project\n\nSome existing instructions.\n' >"$d/AGENTS.md"
  printf '# vision\n' >"$d/overlay/VISION.md"
  printf '# lens\n' >"$d/overlay/PHASE-LENS.md"
  printf '# contract\n' >"$d/overlay/INTENT-CONTRACT.md"
  printf '| `clean-code-standards` | x | project | /x/SKILL.md |\n' >"$d/.atl/skill-registry.md"
}

# --- install adds the block
t1=$(mktemp -d); make_fixture "$t1"
bash "$INSTALL" install "$t1" >/dev/null 2>&1
[ "$(count_marker "$t1/AGENTS.md")" = "1" ] && pass "install adds the block" || fail "install adds the block"

# --- install is idempotent
bash "$INSTALL" install "$t1" >/dev/null 2>&1
[ "$(count_marker "$t1/AGENTS.md")" = "1" ] && pass "install is idempotent" || fail "install is idempotent"

# --- uninstall restores byte-identical content
t2=$(mktemp -d); make_fixture "$t2"
cp "$t2/AGENTS.md" "$t2/AGENTS.orig"
bash "$INSTALL" install "$t2" >/dev/null 2>&1
bash "$INSTALL" uninstall "$t2" >/dev/null 2>&1
if cmp -s "$t2/AGENTS.md" "$t2/AGENTS.orig"; then pass "uninstall is byte-identical"; else fail "uninstall is byte-identical"; fi

# --- doctor passes when seams present
t3=$(mktemp -d); make_fixture "$t3"
bash "$INSTALL" doctor "$t3" >/dev/null 2>&1
[ $? -eq 0 ] && pass "doctor passes with seams present" || fail "doctor passes with seams present"

# --- doctor fails when AGENTS.md missing
t4=$(mktemp -d); make_fixture "$t4"; rm -f "$t4/AGENTS.md"
bash "$INSTALL" doctor "$t4" >/dev/null 2>&1
[ $? -ne 0 ] && pass "doctor fails when AGENTS.md missing" || fail "doctor fails when AGENTS.md missing"

# --- --direct is a not-implemented stub (exits 0, prints notice)
out=$(bash "$INSTALL" --direct 2>&1)
case "$out" in *"not implemented"*) pass "--direct is a documented stub";; *) fail "--direct is a documented stub";; esac

rm -rf "$t1" "$t2" "$t3" "$t4"
if [ "$fails" -eq 0 ]; then printf '\nAll tests passed.\n'; else printf '\n%d test(s) failed.\n' "$fails"; exit 1; fi
