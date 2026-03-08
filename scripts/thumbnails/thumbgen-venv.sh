#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -n "${MATERIAL_SHELL_VIRTUAL_ENV:-}" ]]; then
    _ms_venv="$(eval echo "$MATERIAL_SHELL_VIRTUAL_ENV")"
else
    _ms_venv="$HOME/.local/state/quickshell/.venv"
fi
source "$_ms_venv/bin/activate" 2>/dev/null || true
GIO_USE_VFS=local "$_ms_venv/bin/python3" "$SCRIPT_DIR/thumbgen.py" "$@"
THUMBGEN_EXIT_CODE=$?
deactivate 2>/dev/null || true

exit $THUMBGEN_EXIT_CODE