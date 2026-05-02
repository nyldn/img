---
description: Generate an image with OpenAI gpt-image-2.
argument-hint: "[prompt]"
allowed-tools: "Bash(${CLAUDE_PLUGIN_ROOT}/bin/img:*)"
---

# OpenAI Image Generation

Generate an image from this prompt using OpenAI `gpt-image-2`:

```text
$ARGUMENTS
```

For non-trivial prompts, first inspect bundled OpenAI-oriented prompt recipes:

```bash
"${CLAUDE_PLUGIN_ROOT}/bin/img" recipes "$ARGUMENTS" --model-family openai --limit 4 --json
```

Use the recipes to improve the final prompt structure, but do not paste long
recipe text into chat.

Run:

```bash
"${CLAUDE_PLUGIN_ROOT}/bin/img" --provider openai --prompt "$ARGUMENTS"
```

Report the saved file path. Do not fall back to Gemini if OpenAI fails.
