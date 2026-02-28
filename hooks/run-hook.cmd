#!/usr/bin/env bash
# Hook runner for esp-idf-claude-agent plugin

set -euo pipefail

# Determine plugin root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
export CLAUDE_PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

hook_name="$1"

# Run the hook script
hook_script="${SCRIPT_DIR}/${hook_name}"

if [[ ! -x "${hook_script}" ]]; then
    echo "Hook script not found or not executable: ${hook_script}" >&2
    exit 1
fi

exec "${hook_script}"
