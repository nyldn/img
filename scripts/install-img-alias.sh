#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="$HOME/.claude/commands"
TARGET="$TARGET_DIR/img.md"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_CACHE_DIR="$HOME/.claude/plugins/cache/nyldn-plugins/img"
USE_LOCAL="false"

fail() { echo "  [error] $1"; exit 1; }

while [ "$#" -gt 0 ]; do
  case "$1" in
    --local)
      USE_LOCAL="true"
      shift
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

resolve_img_bin() {
  local local_bin
  local_bin="$(cd "$SCRIPT_DIR/.." && pwd)/bin/img"

  if [ "$USE_LOCAL" = "true" ]; then
    if [ -x "$local_bin" ]; then
      printf '%s\n' "$local_bin"
      return
    fi
    fail "Could not find executable local img binary at $local_bin."
  fi

  local cached_bin=""
  if [ -d "$PLUGIN_CACHE_DIR" ]; then
    cached_bin="$(find "$PLUGIN_CACHE_DIR" -mindepth 3 -maxdepth 3 -type f -path '*/bin/img' 2>/dev/null | sort | tail -n 1 || true)"
  fi

  if [ -n "$cached_bin" ] && [ -x "$cached_bin" ]; then
    printf '%s\n' "$cached_bin"
    return
  fi

  if [ -x "$local_bin" ]; then
    printf '%s\n' "$local_bin"
    return
  fi

  fail "Could not find an executable img binary. Install img@nyldn-plugins first."
}

IMG_BIN="$(resolve_img_bin)"

mkdir -p "$TARGET_DIR"
cat > "$TARGET" <<'EOF'
---
description: Generate an image with img.
argument-hint: "[natural language image request]"
allowed-tools: "Bash(__IMG_BIN__:*)"
---

# img

This is the user-scope base command for img. It points to:

```text
__IMG_BIN__
```

If the user runs `/img setup`, run the setup workflow and health check:

```bash
"__IMG_BIN__" activate
"__IMG_BIN__" setup --json
"__IMG_BIN__" check-health
```

Otherwise, generate an image from the user's natural language request:

```text
$ARGUMENTS
```

Default to OpenAI `gpt-image-2`. Preserve aspect, style, size, and subject words
from the user request inside the prompt. Do not ask the user to translate their
request into CLI flags.

Activate the terminal loader, then run:

```bash
"__IMG_BIN__" activate
"__IMG_BIN__" --provider openai --prompt "$ARGUMENTS"
```

Report the saved file path and provider. Do not retry with a different provider
if the command fails.

If the command returns `setupRequired: true`, tell the user that img created or
found the setup files. Do not ask them to paste the API key into chat. Tell them
to run `__IMG_BIN__ key set openai` or `__IMG_BIN__ key set gemini` from a normal
terminal, matching the reported provider, then re-run the same `/img` request.
Name the reported `envFile` only as a fallback for CI or machines without
Keychain. Do not tell them setup is required; `/img setup` is only for
refreshing setup files or adding project defaults.
EOF

IMG_BIN="$IMG_BIN" TARGET="$TARGET" node --input-type=module <<'EOF'
import { readFileSync, writeFileSync } from "node:fs";

const target = process.env.TARGET;
const imgBin = process.env.IMG_BIN;
writeFileSync(target, readFileSync(target, "utf8").replaceAll("__IMG_BIN__", imgBin));
EOF

echo "Installed base command: $TARGET"
echo "Restart Claude Code, then use /img."
