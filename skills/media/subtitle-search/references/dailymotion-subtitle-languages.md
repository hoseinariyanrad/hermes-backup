# Dailymotion Subtitle Language Codes

## Common Language Codes on Dailymotion

| Code | Language | Notes |
|------|----------|-------|
| `fa` | Persian/Farsi | Human-uploaded by fansub groups |
| `ar` | Arabic | Human-uploaded |
| `en` | English | Human-uploaded (rare) |
| `en-auto` | English (auto-generated) | **Most common English source** — use this code, NOT `en` |
| `id` | Indonesian | Human-uploaded |
| `fr` | French | Human-uploaded |
| `es` | Spanish | Human-uploaded |
| `pt` | Portuguese | Human-uploaded |
| `ru` | Russian | Human-uploaded |
| `tr` | Turkish | Human-uploaded |
| `pl` | Polish | Human-uploaded |
| `bn` | Bengali | Human-uploaded |
| `und` | Undefined | VTT format, usually timing-only or no language tag |

## Key Distinction: `en` vs `en-auto`

- `en` = human-uploaded English subtitle (rare on donghua)
- `en-auto` = Dailymotion's auto-generated English subtitle (most common)

When downloading, always check `--list-subs` output first:
```bash
yt-dlp --impersonate firefox --list-subs 'https://www.dailymotion.com/video/<ID>'
```

If you see `en-auto srt`, use `--sub-lang en-auto`. Using `--sub-lang en` will return "no subtitles found".

## Typical Availability by Episode Age

- **Older episodes (1+ year):** More likely to have `fa`, `ar`, and other human-uploaded subs
- **Newer episodes:** Usually only `en-auto`, `id`, and `und`
- **Brand new episodes:** May have no subtitle tracks at all

## Download Commands

```bash
# List available subs
yt-dlp --impersonate firefox --list-subs 'https://www.dailymotion.com/video/<ID>'

# Download Persian
yt-dlp --impersonate firefox --write-sub --sub-lang fa --sub-format srt --skip-download -o 'ep<NUM>' 'https://www.dailymotion.com/video/<ID>'

# Download auto-generated English (for translation)
yt-dlp --impersonate firefox --write-sub --sub-lang en-auto --sub-format srt --skip-download -o 'ep<NUM>' 'https://www.dailymotion.com/video/<ID>'
```
