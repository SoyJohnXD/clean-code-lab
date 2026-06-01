#!/usr/bin/env bash
# Tests for the shared hard gate — run: bash overlay/hooks/check-intent-frozen.test.sh
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
GATE="$HERE/check-intent-frozen.sh"

fails=0
pass() { printf 'ok   - %s\n' "$1"; }
fail() { printf 'FAIL - %s\n' "$1"; fails=$((fails + 1)); }

# Each test runs against a throwaway project tree.
new_project() { mktemp -d; }

# --- denies when no sentinel exists
p=$(new_project)
( cd "$p" && bash "$GATE" >/dev/null 2>&1 ); [ $? -eq 2 ] && pass "denies without a frozen sentinel" || fail "denies without a frozen sentinel"

# --- --json emits a deny envelope
out=$(cd "$p" && bash "$GATE" --json 2>/dev/null)
case "$out" in *'"permissionDecision":"deny"'*) pass "--json emits deny envelope" ;; *) fail "--json emits deny envelope" ;; esac

# --- allows once a sentinel is present
mkdir -p "$p/.atl/intent"; : >"$p/.atl/intent/demo.frozen"
( cd "$p" && bash "$GATE" >/dev/null 2>&1 ); [ $? -eq 0 ] && pass "allows with a frozen sentinel" || fail "allows with a frozen sentinel"

# --- --json stays silent (no deny) when allowed
out=$(cd "$p" && bash "$GATE" --json 2>/dev/null)
[ -z "$out" ] && pass "--json silent when allowed" || fail "--json silent when allowed"

# --- finds a sentinel in an ancestor directory (walk-up)
sub="$p/pkg/src"; mkdir -p "$sub"
( cd "$sub" && bash "$GATE" >/dev/null 2>&1 ); [ $? -eq 0 ] && pass "walks up to an ancestor sentinel" || fail "walks up to an ancestor sentinel"

# --- bypass env forces allow even without a sentinel
clean=$(new_project)
( cd "$clean" && INTENT_OVERLAY_BYPASS=1 bash "$GATE" >/dev/null 2>&1 ); [ $? -eq 0 ] && pass "INTENT_OVERLAY_BYPASS=1 forces allow" || fail "INTENT_OVERLAY_BYPASS=1 forces allow"

# --- explicit START_DIR argument is honored
( bash "$GATE" "$p" >/dev/null 2>&1 ); [ $? -eq 0 ] && pass "honors explicit START_DIR" || fail "honors explicit START_DIR"

rm -rf "$p" "$clean"
if [ "$fails" -eq 0 ]; then printf '\nAll tests passed.\n'; else printf '\n%d test(s) failed.\n' "$fails"; exit 1; fi
