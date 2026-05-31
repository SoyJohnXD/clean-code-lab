#!/usr/bin/env bash
# Governance Overlay installer — gentle-ai host mode (v1).
# Wires the overlay into a project via AGENTS.md only. Idempotent and reversible.
set -euo pipefail

START="<!-- intent-overlay:start -->"
END="<!-- intent-overlay:end -->"

usage() {
  cat <<'USAGE'
Usage: install.sh <command> [DIR]
  install [DIR]    Add the overlay block to DIR/AGENTS.md (default: current dir). No-op if present.
  uninstall [DIR]  Remove the overlay block, leaving the rest of AGENTS.md byte-identical.
  doctor [DIR]     Verify the gentle-ai seams. Non-zero exit if a seam is missing.
  --direct         Standalone mode (no host). Deferred in v1.
USAGE
}

block() {
  cat <<BLOCK
$START
## Intent Overlay (active)

Before any SDD chain, freeze an Intent Contract per \`overlay/INTENT-CONTRACT.md\` at the engram topic
\`sdd/{change}/intent\`. Do not write code until the human freezes it.

Pass these overlay paths to EVERY SDD phase, applied through \`overlay/PHASE-LENS.md\`:
- \`overlay/VISION.md\`
- \`overlay/PHASE-LENS.md\`
- \`overlay/INTENT-CONTRACT.md\`

Every phase emits \`Intent Gate: aligned | drift-detected\`. Code phases also emit the Clean Code Gate
at refactor-exit. \`drift-detected\` halts the chain and returns to the human as a change request.
$END
BLOCK
}

is_installed() { # is_installed FILE
  local line
  while IFS= read -r line || [ -n "$line" ]; do
    [ "$line" = "$START" ] && return 0
  done <"$1"
  return 1
}

do_install() {
  local agents="$1/AGENTS.md"
  [ -f "$agents" ] || { echo "error: $agents not found" >&2; return 1; }
  if is_installed "$agents"; then
    echo "Overlay already installed in $agents (no-op)."
    return 0
  fi
  printf '\n%s\n' "$(block)" >>"$agents"
  echo "Overlay installed in $agents."
}

do_uninstall() {
  local agents="$1/AGENTS.md"
  [ -f "$agents" ] || { echo "error: $agents not found" >&2; return 1; }
  local -a lines=() out=()
  local line
  while IFS= read -r line || [ -n "$line" ]; do lines+=("$line"); done <"$agents"
  local i=0 n=${#lines[@]} start_idx=-1 end_idx=-1
  for ((i = 0; i < n; i++)); do
    [ "${lines[i]}" = "$START" ] && start_idx=$i
    [ "${lines[i]}" = "$END" ] && { end_idx=$i; break; }
  done
  if [ "$start_idx" -lt 0 ] || [ "$end_idx" -lt 0 ]; then
    echo "Overlay not present in $agents (no-op)."
    return 0
  fi
  # Drop one blank line immediately preceding the block (added by install).
  if [ "$start_idx" -gt 0 ] && [ -z "${lines[start_idx - 1]}" ]; then
    start_idx=$((start_idx - 1))
  fi
  for ((i = 0; i < n; i++)); do
    if [ "$i" -ge "$start_idx" ] && [ "$i" -le "$end_idx" ]; then continue; fi
    out+=("${lines[i]}")
  done
  : >"$agents"
  for line in "${out[@]}"; do printf '%s\n' "$line" >>"$agents"; done
  echo "Overlay removed from $agents."
}

file_contains() { # file_contains NEEDLE FILE
  local needle=$1 line
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in *"$needle"*) return 0 ;; esac
  done <"$2"
  return 1
}

do_doctor() {
  local dir=$1 ok=0
  local agents="$dir/AGENTS.md" registry="$dir/.atl/skill-registry.md"
  if [ -f "$agents" ] && [ -w "$agents" ]; then echo "ok   - AGENTS.md present and writable"; else echo "FAIL - AGENTS.md missing or not writable"; ok=1; fi
  for doc in VISION PHASE-LENS INTENT-CONTRACT; do
    if [ -f "$dir/overlay/$doc.md" ]; then echo "ok   - overlay/$doc.md present"; else echo "FAIL - overlay/$doc.md missing"; ok=1; fi
  done
  if [ -f "$registry" ] && file_contains "clean-code-standards" "$registry"; then
    echo "ok   - clean-code-standards registered"
  else
    echo "warn - clean-code-standards not found in registry (quality lens may not reach subagents)"
  fi
  return $ok
}

main() {
  local cmd=${1:-}
  case "$cmd" in
    install) do_install "${2:-.}" ;;
    uninstall) do_uninstall "${2:-.}" ;;
    doctor) do_doctor "${2:-.}" ;;
    --direct) echo "Standalone (--direct) mode is not implemented in v1. See overlay/README.md." ;;
    ""|-h|--help) usage ;;
    *) usage; return 1 ;;
  esac
}

main "$@"
