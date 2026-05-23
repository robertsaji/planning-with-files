#!/usr/bin/env bash
# check-complete.sh
# Checks whether all tasks in a plan file are marked as complete.
# Usage: ./check-complete.sh <plan-file>
#
# Exit codes:
#   0 - All tasks are complete
#   1 - One or more tasks are incomplete
#   2 - Invalid usage or file not found

set -euo pipefail

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }
green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
bold()   { printf '\033[1m%s\033[0m\n'   "$*"; }

usage() {
  cat <<EOF
Usage: $(basename "$0") <plan-file>

Checks whether every task checkbox in the given plan file is ticked.

Task formats recognised:
  - [x] Completed task
  - [ ] Incomplete task

Examples:
  $(basename "$0") PLAN.md
  $(basename "$0") docs/sprint-plan.md
EOF
}

# ---------------------------------------------------------------------------
# Argument validation
# ---------------------------------------------------------------------------
if [[ $# -lt 1 ]]; then
  red "Error: no plan file specified."
  usage
  exit 2
fi

PLAN_FILE="$1"

if [[ ! -f "$PLAN_FILE" ]]; then
  red "Error: file not found — '$PLAN_FILE'"
  exit 2
fi

# ---------------------------------------------------------------------------
# Parse checkboxes
# ---------------------------------------------------------------------------
# Match lines that contain a markdown task checkbox anywhere in the line.
TOTAL=$(grep -cE '\- \[[ xX]\]' "$PLAN_FILE" || true)
COMPLETE=$(grep -cE '\- \[[xX]\]' "$PLAN_FILE" || true)
INCOMPLETE=$(grep -cE '\- \[ \]' "$PLAN_FILE" || true)

# Collect the actual incomplete lines for reporting.
INCOMPLETE_LINES=$(grep -nE '\- \[ \]' "$PLAN_FILE" || true)

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------
bold "Plan file : $PLAN_FILE"
echo  "Total tasks  : $TOTAL"
echo  "Complete     : $COMPLETE"
echo  "Incomplete   : $INCOMPLETE"
echo

if [[ "$TOTAL" -eq 0 ]]; then
  yellow "Warning: no task checkboxes found in '$PLAN_FILE'."
  exit 2
fi

if [[ "$INCOMPLETE" -eq 0 ]]; then
  green "✔  All $TOTAL task(s) are complete."
  exit 0
else
  red "✘  $INCOMPLETE incomplete task(s) remaining:"
  echo
  while IFS= read -r line; do
    printf '  %s\n' "$line"
  done <<< "$INCOMPLETE_LINES"
  echo
  exit 1
fi
