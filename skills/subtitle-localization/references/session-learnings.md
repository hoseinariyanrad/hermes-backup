# Subtitle Localization — Session Learnings

## Critical Corrections (from user feedback)

1. **NEVER use subagents/parallel delegation for translation work.** The user explicitly rejected this. Subagents hit iteration limits, lose context, and produce incomplete/broken output. Always work sequentially in the main session.

2. **Always check BEFORE uploading.** Run `grep -n "[a-zA-Z]" <file>` to verify no English remains. The user will reject any file with English text in dialogue lines.

3. **Translation must be fluent, cinematic Persian — NOT literal/machine translation.** Use colloquial forms for casual dialogue, formal for elders/nobles. Match pronouns to the speaker (first person, second person).

4. **Work one file at a time.** Translate → verify → push → then start the next file. Never batch.

5. **Strip ALL ASS tags completely** including `\fad`, `\pos`, `\fn`, `\fs`, `\c&`, `\3c&`, `\bord`, `\blur`, `\shad`, `\p1`, `\p0`. Remove geometric vector paths entirely.

6. **Song lyrics at end of episodes** must be translated as poetry, not left in English.

7. **TN (Translator Notes)** from fansub groups must be translated and prefixed with `مترجم:`.

## Repository Structure Convention

```
subtitles/
  anime/
    <show-name>/
      season-<N>/
        <Show>.S<N>.E<NN>.<LANG>.srt
  series/
    <show-name>/...
  movies/
    <Movie>.<LANG>.srt
```

## Technical Pitfalls

- Replacing standalone `E` (subtitle group logo) can corrupt words like "Eight" → "فصل ۴ight". Be surgical.
- Multi-line TN blocks span multiple SRT entries — translate each and merge.
- Git conflicts: always `git pull --rebase` before pushing, resolve with `GIT_EDITOR=true`.
