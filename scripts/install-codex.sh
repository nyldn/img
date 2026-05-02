#!/usr/bin/env bash
set -euo pipefail

MARKETPLACE="https://github.com/nyldn/plugins.git"
PLUGIN_NAME="img"
INSTALL_LOCAL="false"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() { echo "  [ok] $1"; }
fail() { echo "  [error] $1"; exit 1; }

while [ "$#" -gt 0 ]; do
  case "$1" in
    --local)
      INSTALL_LOCAL="true"
      shift
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

command -v codex >/dev/null 2>&1 || fail "Missing required command: codex"

if [ "$INSTALL_LOCAL" = "true" ]; then
  MARKETPLACE="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

echo "Adding Codex marketplace $MARKETPLACE..."
codex plugin marketplace add "$MARKETPLACE"

info "Codex marketplace added"
echo ""
echo "Next steps:"
echo "  1. Restart Codex"
echo "  2. Open /plugins"
echo "  3. Install or enable $PLUGIN_NAME"
