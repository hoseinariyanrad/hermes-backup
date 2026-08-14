---
name: subtitle-search
description: Search/download subtitles for movies, anime, donghua.
tags: [subtitles, srt, ass, donghua, anime, media]
---

# Subtitle Search & Download

Search for and retrieve subtitle files (SRT, ASS, VTT, SSA) for any video content across Chinese and English subtitle databases.

## Trigger

Use when the user needs to find, download, or list subtitle files for a movie, TV series, anime, donghua, or any video content.

## Workflow

### 1. Identify Search Terms

Extract from the user's request:
- **Primary title** (e.g., "Soul Land 2", "Douluo Dalu 2")
- **Chinese title** if applicable (e.g., "斗罗大陆2 绝世唐门")
- **Alternative names** (romanizations, abbreviations)
- **Episode range** if specified

Search in both English and Chinese — coverage varies by database.

### 2. Web Search

**Primary: `ddgs` Python library** (if installed):
```python
from ddgs import DDGS
results = list(DDGS().text('<search query>', max_results=15))
```

**Fallback: curl + DuckDuckGo Lite** (if `ddgs` not available):
```bash
curl -sL 'https://lite.duckduckgo.com/lite/?q=<URL-encoded-query>' \
  -H 'User-Agent: Mozilla/5.0' | grep -oP 'href="(https?://[^"]+)"'
```

**Fallback: curl + Google** (may return empty due to bot detection):
```bash
curl -sL 'https://www.google.com/search?q=<query>' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36' \
  | grep -oP '<a href="/url\?q=(https?://[^&"]+)'
```

Run searches in both English and Chinese:
- English: `"show name" subtitles SRT download`
- Chinese: `show中文名 字幕 srt 下载`

### 3. OpenSubtitles REST API (Best for Direct Downloads)

The legacy REST API works **without authentication** and returns JSON with direct download URLs:

```
https://rest.opensubtitles.org/search/query-<search+terms>
```

Key query parameters (URL-encoded, space-separated in path):
- `query-<term>` — free text search
- `sublanguageid-eng` — filter by language (eng, chn, etc.)
- `subformat-srt` — filter by format

Response includes per-subtitle:
- `SubFileName` — actual filename
- `SubDownloadLink` — direct download (gzipped)
- `ZipDownloadLink` — ZIP bundle download
- `SubtitlesLink` — web page
- `SubLanguageID` — language code
- `SubFormat` — srt, ssa, ass, vtt
- `MovieReleaseName` — helps match to specific video release

**Pitfall:** The `SubDownloadLink` URLs contain VRF tokens that expire. Download promptly or use the `SubtitlesLink` web page for fresh tokens.

**Pitfall:** The web interface at opensubtitles.org uses Anubis anti-bot protection — do NOT try to scrape the website, only use the REST API.

### 4. Subtitle Database Sites (by accessibility)

**Accessible via curl (no auth required):**

| Site | URL Pattern | Notes |
|------|-------------|-------|
| **subdl.com** | `https://subdl.com/subtitle/<id>/<show-slug>` | Season packs, multiple languages, episode-level granularity |
| **subtitlist.com** | `https://www.subtitlist.com/subtitles/<show-slug>` | SRT download + format conversion tools |
| **subf2m.co** | `https://subf2m.co/subtitles/<show-slug>` | Multiple languages, good coverage |
| **dongsub.net** | `https://www.dongsub.net/<date>/<show-slug>.html` | Dedicated donghua subtitles, latest episodes |
| **donghuastream.org** | `https://donghuastream.org/<episode-slug>/` | Multi-sub episode downloads |

**Blocked by anti-bot (skip automated access):**
- opensubtitles.org (web) — Anubis proof-of-work
- zimuku.la — Chinese subtitle site, bot protection
- subhd.tv — Chinese subtitle site
- assrt.net — Chinese subtitle site

### 5. GitHub Search (for subtitle collections)

```
https://api.github.com/search/repositories?q=<query>+subtitles&sort=stars&per_page=10
```

Limited results for specific shows but useful for discovering subtitle tools (CloudStream extensions, muxing utilities).

### 6. SubDL — The Primary Subtitle Database (Successor to Subscene)

SubDL (subdl.com) is **the successor to Subscene** (shutdown 2024). It has 3M+ subtitle files in 111 languages.

**Key discovery:** SubDL publishes `https://subdl.com/llms-full.txt` — a comprehensive reference designed for AI agents. Read it first for URL patterns, API details, and language coverage.

**URL patterns:**
- Title page: `https://subdl.com/subtitle/sd<ID>/<slug>`
- Language filter: `https://subdl.com/subtitle/sd<ID>/<slug>/<language>`
- Season page: `https://subdl.com/subtitle/sd<ID>/<slug>/<n>-season`
- Single download: `https://subdl.com/s/info/<fileId>/<slug>`
- Search: `https://subdl.com/search/<query>`

**API:** Free REST API at `https://subdl.com/api-doc`. An API key is required (free from user panel). The `auto` endpoint accepts `film_name`, `type=series`, and `languages` filter.

**Pitfall:** The API may return `{"error":"query not found or length is low"}` for short queries. Use full titles.

**Pitfall:** SubDL search pages require JavaScript rendering for full results. The API or `llms-full.txt` are more reliable for programmatic access.

### 7. Wayback Machine — Fallback for Dead/Blocked Sites

When a subtitle site is down (e.g., Subscene shutdown 2024) or behind Cloudflare:

```bash
# CDX API — find archived snapshots
curl -s 'https://web.archive.org/cdx/search/cdx?url=<site-url-pattern>&output=json&limit=50&fl=original,timestamp,statuscode'

# Fetch a cached page
curl -sL 'https://web.archive.org/web/<timestamp>/<original-url>'
```

**Proven use case:** Subscene's Soul Land II page was fully cached, revealing Farsi/Persian subtitle entries that no longer exist on the live web. The CDX API discovered 10 subtitle entries with episode details.

### 8. Telegram Channels — Donghua Subtitle Distribution

Telegram is a major distribution channel for donghua subtitles. Key channels discovered:

| Channel | Content | Subscribers |
|---------|---------|-------------|
| `@soulland` | Soul Land English subs | ~7K |
| `@soul_land_eng` | Soul Land English | — |
| `@donghua_subs` | Hub linking multiple donghua channels | — |
| `@soullandsub` | Soul Land 2 Sub Indonesia | — |

**Search approach:** Use `https://t.me/s/<channel>` to preview channel content without a Telegram account. Search for channels with `curl -sL 'https://t.me/s/<channel-name>' | grep -i 'subtitle|srt'`.

**Pattern:** Donghua fansub groups often create per-show Telegram channels. Search `https://t.me/s/<show_name>_eng` or `https://t.me/s/<show_name>_sub`.

### 9. yt-dlp + Dailymotion Extraction (BEST for Donghua Multi-Language SRT)

Many donghua streaming sites (donghuastream.org, donghuaworld.com) embed **Dailymotion players** that carry multi-language SRT subtitles — including Persian/Farsi. These can be extracted as standalone .srt files via yt-dlp.

**Prerequisites:**
```bash
pip install yt-dlp curl_cffi
```

**Step 1 — Find the Dailymotion video ID from the episode page:**
```bash
curl -sL 'https://donghuastream.org/<episode-slug>/' \
  -H 'User-Agent: Mozilla/5.0' | \
  grep -oP 'dailymotion\.com/player/[^?]*\?video=([a-zA-Z0-9]+)'
```

**Step 2 — List available subtitles:**
```bash
yt-dlp --impersonate firefox --list-subs \
  'https://www.dailymotion.com/video/<VIDEO_ID>'
```
Typical languages: `fr, es, pt, ru, tr, pl, ar, bn, fa, id, und` — where `fa` = Persian/Farsi.

**Step 3 — Download a specific language:**
```bash
yt-dlp --impersonate firefox \
  --write-sub --sub-lang fa --sub-format srt --skip-download \
  -o 'output_dir/ep<NUM>' \
  'https://www.dailymotion.com/video/<VIDEO_ID>'
```

**Key: `--impersonate firefox`** is REQUIRED — Dailymotion blocks yt-dlp's default UA. Needs `curl_cffi`.

**Batch download pattern (all episodes of a season):**
```bash
for ep in $(seq 105 148); do
  dm_id=$(curl -sL "https://donghuastream.org/<show>-episode-${ep}-multiple-subtitles/" \
    -H 'User-Agent: Mozilla/5.0' | \
    grep -oP 'dailymotion\.com/player/[^?]*\?video=\K[a-zA-Z0-9]+')
  [ -z "$dm_id" ] && echo "Ep $ep: no DM ID" && continue
  yt-dlp --impersonate firefox --write-sub --sub-lang fa --sub-format srt \
    --skip-download -o "subs/fa/ep${ep}" "https://www.dailymotion.com/video/${dm_id}"
  sleep 2  # rate limit
done
```

**Pitfall:** Newer episodes may lack subtitle tracks ("There are no subtitles for the requested languages"). This means the fansub group hasn't uploaded subs yet — not a tool failure.

**Pitfall:** Episode page URL slugs vary per show. Scrape the main anime page to discover the slug pattern first.

**When to use:** This is the **primary technique** for donghua subtitles when standalone SRT files aren't on subtitle databases. Proven with donghuastream.org for Legend of Xianwu, Soul Land, and other Tencent-backed donghua.

**Reference:** `references/dailymotion-subtitle-languages.md` — full language code table and `en` vs `en-auto` distinction.

### 10. Archive.org — Supplementary Source

Some Internet Archive uploads contain video files with embedded subtitles:
```bash
curl -s 'https://archive.org/advancedsearch.php?q=<query>+subtitle&fl[]=identifier,title&output=json&rows=50'
```

**Note:** These are typically .mp4 files with burned-in subtitles, not standalone .srt files. Useful as a last resort or for specific episode ranges.

### 11. Subtitle Translation (English → Target Language)

When subtitles exist in English but not in the target language (e.g. Persian), batch-translate SRT files using `deep-translator`:

**Prerequisites:**
```bash
pip install deep-translator
```

**Translation script pattern:**
```python
from deep_translator import GoogleTranslator
import re, os

def translate_srt(input_path, output_path, src='en', tgt='fa'):
    translator = GoogleTranslator(source=src, target=tgt)
    with open(input_path) as f:
        content = f.read()
    
    blocks = re.split(r'\n\n+', content.strip())
    output = []
    for block in blocks:
        lines = block.strip().split('\n')
        if len(lines) >= 3:
            index = lines[0]
            timing = lines[1]
            text = '\n'.join(lines[2:])
            clean = re.sub(r'<[^>]+>', '', text)
            translated = translator.translate(clean) if clean.strip() else text
            output.append(f"{index}\n{timing}\n{translated}\n")
    
    with open(output_path, 'w') as f:
        f.write('\n'.join(output))
```

**Pitfalls:**
- Google Translate free tier has rate limits — add `time.sleep(0.5)` between batches
- Batch translations (joining with separators) reduce API calls but may garble multi-line entries
- Auto-generated English subs (`en-auto`) often have lower quality — translate from human-uploaded subs when available
- Always mark AI-translated files clearly in the SRT header and README

**When to use:** When a donghua has English auto-subs but no target-language subs, and the user wants subtitles in their language. Proven for Legend of Xianwu Season 3 (29 episodes translated to Persian).

**Script:** `scripts/translate_srt.py` — reusable CLI tool for batch SRT translation.

### 12. Verify & Report

- Test at least one download link with `curl -sI` to confirm it returns HTTP 200
- Organize results by: source, language, episode range, format
- Note any coverage gaps

### 13. Local Whisper Extraction (For Raw Video / No Subs)

When a donghua or anime has no available subtitle tracks online or via Dailymotion, use OpenAI Whisper locally via Python to transcribe audio and generate an SRT file:

```bash
pip install openai-whisper torch
```

```python
import whisper

model = whisper.load_model("base")  # or small, medium
result = model.transcribe("video_file.mkv", language="Chinese") # or English

# Save as SRT format manually or iterate result['segments']
```

Or via CLI:
```bash
whisper "video_file.mkv" --model base --language Chinese --output_format srt --output_dir .
```

*Note: On CPU, Whisper uses FP32 which is slower than GPU, so `base` or `small` is recommended for speed.*

## Search Strategy Decision Tree

```
Is it a donghua (Chinese anime)?
  YES → yt-dlp + Dailymotion extraction from donghuastream.org (BEST for Persian/multi-lang SRT)
       → SubDL (sd1665296 for Soul Land 2 type) + Telegram channels
  NO  → Continue

Is it a popular anime/movie?
  YES → OpenSubtitles API + SubDL + subf2m.co
  NO  → OpenSubtitles API (widest coverage for niche content)

Is the original site dead/blocked?
  YES → Wayback Machine CDX API for cached pages
       → SubDL as successor site (check llms-full.txt)
  NO  → Continue

Need Persian/Farsi subtitles?
  YES → SubDL farsi_persian filter + Wayback Machine for Subscene cached entries
       → Telegram @soulland (may have multi-lang)
  NO  → Continue

Need Chinese subtitles specifically?
  YES → Note: most Chinese subs are hardcoded in video releases
       Try OpenSubtitles API with sublanguageid=chn
       Try zimuku.la (may need browser, not curl)
  NO  → English subs readily available from most sources
```

## Common Pitfalls

1. **`ddgs` Python library may not be installed** — fall back to curl + DuckDuckGo Lite or Google scraping
2. **Subscene is dead (shutdown 2024)** — use SubDL (its successor) or Wayback Machine for cached data
3. **OpenSubtitles REST API URLs expire** — VRF tokens are time-sensitive; download promptly
4. **opensubtitles.org website is behind Anubis** — use REST API only, never scrape the website
5. **Subscene and many subtitle sites are behind Cloudflare** — cannot curl them; use Wayback Machine
6. **SubDL API needs an API key** — free key from user panel; `auto` endpoint may reject short queries
7. **SubDL search pages require JS rendering** — API or `llms-full.txt` more reliable for automation
8. **Chinese subtitle sites block curl** — they require JavaScript/cookies; try browser-based access
9. **Episode numbering varies** — some sources use absolute numbering, others use season+episode
10. **Format mismatch** — some subs are ASS/SSA (styling) while others are SRT (plain); VTT files sometimes labeled as SRT
11. **Multiple subtitle packs per episode** — different timing groups, different translators; match to your video release
12. **Telegram channels may be private** — `https://t.me/s/<channel>` preview may not work for private channels
13. **`curl_cffi` required for Dailymotion impersonation** — `yt-dlp --impersonate firefox` fails without it: `pip install curl_cffi`. Error: "none of these impersonate targets are available: firefox"
14. **animegate.net has hardcoded Persian subs (هاردساب)** — no standalone SRT files; CAPTCHA blocks automated login
15. **Dailymotion auto-generated subs use `en-auto`, not `en`** — when `--list-subs` shows `en-auto srt`, request `--sub-lang en-auto` not `--sub-lang en`. The `en` code silently finds nothing: "There are no subtitles for the requested languages". Human-uploaded subs use language codes without the `-auto` suffix (e.g. `fa`, `ar`).
16. **Same show may have multiple slug patterns on donghuastream** — e.g. "Renegade Immortal" (ep 1-148) vs "Legend of Martial Immortal" (ep 149-173). When episodes span a naming change, search both slug patterns. Check the main anime page's related-season links for alternate names.
