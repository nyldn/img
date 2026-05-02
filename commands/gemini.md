---
description: Generate an image with Gemini 3.1 Flash Image Preview.
argument-hint: "[prompt]"
allowed-tools: "Bash(${CLAUDE_PLUGIN_ROOT}/bin/img:*)"
---

# Gemini Image Generation

Generate an image from this prompt using Gemini `gemini-3.1-flash-image-preview`:

```text
$ARGUMENTS
```

For non-trivial prompts, first inspect bundled Gemini-oriented prompt recipes:

```bash
"${CLAUDE_PLUGIN_ROOT}/bin/img" recipes "$ARGUMENTS" --model-family gemini --limit 4 --json
```

Use the recipes to improve the final prompt structure, and make the final prompt
explicit that Gemini should return an image, not only advice or text.

Run:

```bash
"${CLAUDE_PLUGIN_ROOT}/bin/img" --provider gemini --prompt "$ARGUMENTS"
```

Report the saved file path. Do not fall back to OpenAI if Gemini fails.
