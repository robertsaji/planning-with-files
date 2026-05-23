#!/usr/bin/env bash
# create-plan.sh
# Creates a new plan file with the standard structure for planning-with-files.
# Usage: ./create-plan.sh <plan-name> [--dir <output-directory>]

set -euo pipefail

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_PLANS_DIR="$(pwd)/plans"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage: $(basename "$0") <plan-name> [OPTIONS]

Create a new plan file with the standard planning-with-files structure.

Arguments:
  <plan-name>   Short, kebab-case name for the plan (e.g. "add-login-flow")

Options:
  --dir <path>  Directory where the plan file will be created
                (default: ./plans)
  --help        Show this help message and exit

Examples:
  $(basename "$0") add-login-flow
  $(basename "$0") refactor-database --dir ./docs/plans
EOF
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
PLAN_NAME=""
OUTPUT_DIR="$DEFAULT_PLANS_DIR"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --dir)
      [[ -n "${2:-}" ]] || die "--dir requires a path argument"
      OUTPUT_DIR="$2"
      shift 2
      ;;
    -*)
      die "Unknown option: $1"
      ;;
    *)
      if [[ -z "$PLAN_NAME" ]]; then
        PLAN_NAME="$1"
      else
        die "Unexpected argument: $1"
      fi
      shift
      ;;
  esac
done

[[ -n "$PLAN_NAME" ]] || die "<plan-name> is required. Run with --help for usage."

# Validate plan name: lowercase letters, digits, hyphens only
if [[ ! "$PLAN_NAME" =~ ^[a-z0-9][a-z0-9-]*[a-z0-9]$|^[a-z0-9]$ ]]; then
  die "Plan name must be kebab-case (lowercase letters, digits, hyphens). Got: '$PLAN_NAME'"
fi

# ---------------------------------------------------------------------------
# Prepare output
# ---------------------------------------------------------------------------
mkdir -p "$OUTPUT_DIR"

PLAN_FILE="$OUTPUT_DIR/${PLAN_NAME}.md"

if [[ -f "$PLAN_FILE" ]]; then
  die "Plan file already exists: $PLAN_FILE"
fi

# ---------------------------------------------------------------------------
# Write plan template
# ---------------------------------------------------------------------------
cat > "$PLAN_FILE" <<TEMPLATE
# Plan: ${PLAN_NAME}

<!-- created: ${TIMESTAMP} -->
<!-- status: in-progress -->

## Overview

<!-- Describe the goal of this plan in 1-3 sentences. -->

## Steps

<!-- Each step follows the format:
     - [ ] Step description  <!-- step-id: <unique-id> -->
     Mark a step done by changing [ ] to [x].
-->

- [ ] Define requirements  <!-- step-id: 001 -->
- [ ] Design solution      <!-- step-id: 002 -->
- [ ] Implement changes    <!-- step-id: 003 -->
- [ ] Write tests           <!-- step-id: 004 -->
- [ ] Review and merge     <!-- step-id: 005 -->

## Notes

<!-- Optional: context, decisions, links to related issues/PRs. -->

## Completion Criteria

<!-- What does "done" look like for this plan? -->
TEMPLATE

echo "✅ Plan created: $PLAN_FILE"
