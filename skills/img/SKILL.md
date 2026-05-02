---
name: img
version: 0.1.18
description: Generate, edit, or plan image assets with img using OpenAI gpt-image-2 or Google gemini-3.1-flash-image-preview. Use when a user asks for image generation, image editing, website/marketing visuals, brand-consistent batches, or prompt engineering for those models.
---

# img

Use this skill as an image director, not just a CLI wrapper. The user should be
able to give a rough goal; you should translate it into a model-aware prompt,
choose the provider deliberately, use project defaults, consult bundled prompt
recipes, then call img.

## First Move

For any non-trivial request, inspect the local recipe index before generating:

```bash
"${CLAUDE_PLUGIN_ROOT}/bin/img" recipes "$ARGUMENTS" --limit 4 --json
```

Use recipe results as pattern evidence, not as text to paste blindly. Borrow the
structure: asset type, composition, camera/lighting, typography treatment,
layout constraints, negative constraints, and batch variation axes. Preserve
recipe attribution in your reasoning when you mention a recipe, but do not dump
long recipe prompts into chat unless asked.

For simple one-off prompts, a direct command is fine.

## Provider Choice

Default to OpenAI `gpt-image-2` for polished single assets, commercial product
shots, posters, website heroes, editorial banners, infographics, UI mockups,
precise typography, and masked edits. OpenAI exposes generation and edit
endpoints, supports text input plus image input/output, flexible image sizes,
quality levels, output formats, and high-fidelity image inputs.

Prefer Gemini `gemini-3.1-flash-image-preview` when the request is
reference-image heavy, asks for conversational restyling, multi-image fusion,
diagram/knowledge transformation, visual reasoning, iterative edit ideas, or a
response that may include explanatory text plus an image. Gemini can return
text-only when the image intent is vague, so explicitly ask it to generate or
update the image. Gemini-generated images may include SynthID watermarking.

Do not silently fall back between providers. If the selected provider fails,
report the failure and the useful next action.

## Prompt Contract

Build the final prompt in this order:

1. Intent: the asset type and job to be done.
2. Subject: the concrete object, person, scene, product, UI, or system.
3. Composition: crop, aspect, hierarchy, focal point, camera angle, and spacing.
4. Surface: medium, lens/rendering style, lighting, materials, depth, texture.
5. Brand: discovered colors, pre-prompts, negative prompts, reference files.
6. Text: exact visible copy, language, typography, and "no extra text" rules.
7. Constraints: avoid watermarks, malformed hands, unreadable text, brand drift.
8. Batch plan: if `--count` is more than 1, specify the variation axis for each image.

Use compact professional language. Dense prompts are fine when they control
layout, text, materials, or a batch. Avoid ornamental adjectives that do not
change the image.

## Model Tactics

For text-heavy images, quote exact text and state whether the model may add any
other text. Ask for clean typography, readable glyphs, layout hierarchy, and
proof-like spelling. For multilingual text, name the language and script.

For product or marketing assets, specify product identity, packaging details,
surface materials, lighting, background, brand color usage, campaign role, and
whether labels/logos should appear.

For website heroes, specify viewport crop, safe area, where copy will overlay,
subject placement, brand palette, and whether the image should leave negative
space. Generate a real usable hero image, not a generic atmosphere.

For edits, separate preserve/change instructions. Preserve identity, pose,
camera, background, lighting, and product geometry unless the user asked to
change them. With OpenAI masks, keep the prompt specific to the masked region.

For Gemini, include direct image intent such as "generate the updated image" or
"return an image, not only advice." For complex diagrams or transformed
documents, ask for clean structure and legible labels, then expect possible
response text alongside the image.

For OpenAI, use `--quality high` when detail, typography, product polish, or a
client-facing final matters. Use `--format webp` or `jpeg` only when the user
needs that delivery format; otherwise keep PNG.

## Commands

Use the plugin-local binary in Claude Code:

```bash
"${CLAUDE_PLUGIN_ROOT}/bin/img" --provider openai --prompt "$FINAL_PROMPT"
"${CLAUDE_PLUGIN_ROOT}/bin/img" --provider gemini --prompt "$FINAL_PROMPT"
```

In Codex or terminal workflows, use `img` when it is installed on PATH.

Useful preflight:

```bash
"${CLAUDE_PLUGIN_ROOT}/bin/img" recipes "$ARGUMENTS" --model-family openai --limit 4 --json
"${CLAUDE_PLUGIN_ROOT}/bin/img" --dry-run --provider openai --prompt "$FINAL_PROMPT"
```

Edit with references:

```bash
"${CLAUDE_PLUGIN_ROOT}/bin/img" --provider openai --input ./reference.png --prompt "$FINAL_PROMPT"
"${CLAUDE_PLUGIN_ROOT}/bin/img" --provider gemini --input ./reference.png --prompt "$FINAL_PROMPT"
```

Setup and health:

```bash
"${CLAUDE_PLUGIN_ROOT}/bin/img" setup --open-terminal
"${CLAUDE_PLUGIN_ROOT}/bin/img" setup --json
"${CLAUDE_PLUGIN_ROOT}/bin/img" check-health
```

## Runtime Contract

- Read provider credentials from the user's environment, project `.env`, user
  `~/.config/img/.env.local`, or macOS Keychain.
- Prefer macOS Keychain for local provider keys. Use `img key set openai`,
  `img key set gemini`, and `img key status` from a normal terminal.
- Do not ask the user to paste API keys into Claude or Codex chat.
- Load user config from `~/.config/img/config.json` and nearest project
  `img.config.json`; project config overrides user config.
- Include configured pre-prompts, negative prompts, and brand colors with every
  provider API prompt.
- Save generated files to `IMG_OUTPUT_DIR`, config `outputDir`, or `./img-output`.
- Use `--dry-run` before a costly, uncertain, or batch request.

## Local Research Assets

Bundled prompt recipes live at:

```text
resources/prompt-recipes.jsonl
```

They are generated from the dev-only `dependencies/` checkouts. Each recipe
includes source repo, source URL, commit, license, attribution, model family,
category, use case, prompt template, and variables. The dependency repos are not
published with the plugin.

When recipes disagree with project brand defaults, project defaults win.
