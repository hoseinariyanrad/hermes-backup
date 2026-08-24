---
name: subtitle-localization
description: "Translate SRT subtitles with cinematic quality."
version: 1.0.0
tags: [subtitle, translation, localization, persian, farsi, SRT, ASS, donghua, anime, cinematic]
category: media
---

# Subtitle Localization

Translate subtitle files between languages while preserving exact timing, SRT/ASS structure, and cinematic quality. Focused on English-to-Persian (Farsi) donghua/anime subtitles but applicable to any subtitle language pair.

## When to use this skill

- User sends .srt, .ass, or .ssa subtitle files for translation
- User asks to translate subtitles to Persian/Farsi
- User asks to convert between subtitle formats (ASS to SRT)
- User asks to clean up subtitle files (strip styling tags, fix encoding)
- User asks to upload translated subtitles to a repo or platform

## Pipeline

### 1. Receive and validate input
- Confirm all files are received (count expected vs actual)
- Check file encoding (UTF-8 BOM is common in SRT files from fansub groups)
- Parse and count subtitle blocks to confirm completeness

### 2. Parse SRT/ASS structure
- SRT format: index, timestamp, text separated by blank lines
- ASS/SSA styling tags: Strip all curly brace tags and backslash commands
- Geometric path data: Lines starting with m followed by coordinates are vector drawing commands - remove entirely
- TN (Translator Notes): Annotation overlays from fansub groups. Translate them too but prefix with a translator note marker
- Preserve timestamps EXACTLY - never modify timing, frame offsets, or duration

### 3. Translation quality standards (CRITICAL)

The user explicitly corrected this: machine-literal translation is unacceptable.

DO:
- Use natural, cinematic Persian - the kind you would hear in a dubbed film on Iranian TV
- Match dialogue register: casual speech stays casual, formal speech stays formal
- Use correct first-person and second-person pronouns in context - check who is speaking to whom
- Preserve emotional tone: anger, tenderness, sarcasm, desperation must carry through
- Use colloquial Persian for casual dialogue
- Let lines flow naturally across subtitles - a sentence split over multiple entries should read as one coherent thought
- Character names: Keep transliterated
- Place names: Keep transliterated
- Fantasy terms: Translate meaningfully

DO NOT:
- Translate word-by-word (produces unintelligible output)
- Use stiff or formal Persian for casual dialogue
- Leave English text untranslated in dialogue lines (except intentionally kept proper nouns)
- Mix singular and plural pronouns incorrectly
- Flatten emotional nuance into neutral statements

### 4. Quality review (BEFORE uploading)
The user explicitly required this step: never skip it.

After translation, review EVERY entry for:
1. Pronoun consistency: Check first-person, second-person - who is speaking?
2. Dialogue flow: Read consecutive entries as a continuous conversation - does it make sense?
3. Emotional coherence: Does the tone match the scene?
4. No leftover English: Every dialogue line should be in target language
5. No geometric paths: Remove any vector drawing commands that leaked through
6. Timestamp integrity: Spot-check that no timestamps were shifted or reordered

### 5. Output format
- Write clean SRT with sequential numbering starting from 1
- UTF-8 encoding (with BOM for maximum compatibility)
- One blank line between entries
- No ASS styling tags in output (pure SRT)

### 6. Upload (if requested)
- Clone or pull the target repo
- Write files to the specified directory
- Commit and push with descriptive message
- Provide the download link to the user
