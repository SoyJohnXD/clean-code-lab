#!/usr/bin/env bash
# check-intent-frozen — the shared hard gate of the Intent Overlay.
# Answers one question for every host's PreToolUse hook: is there a FROZEN Intent Contract for
# this project? The freeze signal is a sentinel file `.atl/intent/<change>.frozen` at (or above)
# the working directory. Synchronous and dependency-free so it is safe inside a tool-call hook.
#
# Allow  → exit 0, no output (Codex/Claude read "no deny" as allow).
# Deny   → exit 2; with --json prints the PreToolUse deny envelope both Codex and Claude honor.
# Bypass → INTENT_OVERLAY_BYPASS=1 forces allow (the explicit escape hatch).
set -u

INTENT_DIR=".atl/intent"
SENTINEL_GLOB="*.frozen"

usage() {
  cat <<'USAGE'
Usage: check-intent-frozen.sh [--json] [START_DIR]
  --json      Emit the PreToolUse deny envelope on stdout when denying (for Codex/Claude hooks).
              Without it, denial is signalled by exit code 2 and a reason on stderr.
  START_DIR   Directory to start the walk-up from (default: current directory).
USAGE
}

# Drain any hook payload on stdin so the host never sees a broken pipe. We key off the working
# directory, not the payload, to stay dependency-free (no jq).
drain_stdin() { [ -t 0 ] || cat >/dev/null 2>&1 || true; }

# is_frozen DIR — true if DIR/.atl/intent holds at least one *.frozen sentinel.
is_frozen() {
  local hits
  hits=$(compgen -G "$1/$INTENT_DIR/$SENTINEL_GLOB" 2>/dev/null) || return 1
  [ -n "$hits" ]
}

# walk_up START — succeed as soon as any ancestor (START included) is frozen.
walk_up() {
  local dir="$1"
  while :; do
    is_frozen "$dir" && return 0
    [ "$dir" = "/" ] && return 1
    dir=$(dirname "$dir")
  done
}

main() {
  local json=0 start="$PWD"
  while [ $# -gt 0 ]; do
    case "$1" in
      --json) json=1 ;;
      -h|--help) usage; return 0 ;;
      *) start="$1" ;;
    esac
    shift
  done

  drain_stdin

  if [ "${INTENT_OVERLAY_BYPASS:-0}" = "1" ]; then
    return 0
  fi

  if walk_up "$start"; then
    return 0
  fi

  local reason="Intent Overlay: no frozen Intent Contract found ($INTENT_DIR/$SENTINEL_GLOB). Freeze it first (intent-overlay freeze <change>) or set INTENT_OVERLAY_BYPASS=1 to override."
  if [ "$json" -eq 1 ]; then
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason"
  else
    printf '%s\n' "$reason" >&2
  fi
  return 2
}

main "$@"
