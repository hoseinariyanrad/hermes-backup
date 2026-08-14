# Subtitle Database Site Catalog

Verified as of August 2026.

## Tier 1: Direct API Access (no auth, returns JSON/download links)

### SubDL API (preferred — Subscene successor)
- **Docs:** https://subdl.com/api-doc
- **LLM Reference:** https://subdl.com/llms-full.txt (comprehensive, designed for AI agents)
- **Auth:** Free API key required (obtain from user panel)
- **Endpoint:** `https://api.subdl.com/auto?film_name=<term>&type=series&languages=<lang>`
- **Returns:** JSON with subtitle metadata and download paths
- **Stats:** 3M+ subtitles, 111 languages, 161K+ titles
- **Verified IDs:** Soul Land: sd1305871, Soul Land II: sd221244, Soul Land 2 Peerless Tang Clan: sd1665296
- **Pitfall:** `auto` endpoint returns `{"error":"query not found or length is low"}` for short queries

### OpenSubtitles REST API
- **Endpoint:** `https://rest.opensubtitles.org/search/query-<terms>`
- **Auth:** None required (legacy API)
- **Returns:** JSON array of subtitle objects
- **Key fields:** `SubFileName`, `SubDownloadLink` (gz), `ZipDownloadLink`, `SubLanguageID`, `SubFormat`, `MovieReleaseName`, `IDSubtitle`
- **Movie ID for Soul Land 2:** 1572805 (IMDB 28022382)
- **Languages seen:** English (srt), Persian (ass/ssa), Arabic, Vietnamese, Indonesian, French, Spanish, Portuguese, Hindi, Turkish, and more
- **Pitfall:** VRF tokens in download URLs expire. Use `SubtitlesLink` page for fresh tokens.
- **Test:** Verified download link returns HTTP 200 with `application/zip` content-type

### Wayback Machine CDX API (for dead sites)
- **Endpoint:** `https://web.archive.org/cdx/search/cdx?url=<pattern>&output=json&limit=50&fl=original,timestamp,statuscode`
- **Use:** Find cached versions of dead/blocked sites
- **Verified:** Subscene Soul Land II page fully cached with 10 Farsi/Persian subtitle entries
- **Fetch cached page:** `https://web.archive.org/web/<timestamp>/<original-url>`

## Tier 2: Accessible via curl (HTML scraping, no JS required)

### SubDL Web (successor to Subscene)
- **URL pattern:** `https://subdl.com/subtitle/sd<ID>/<show-slug>`
- **Language filter:** `https://subdl.com/subtitle/sd<ID>/<slug>/<language>`
- **Season page:** `https://subdl.com/subtitle/sd<ID>/<slug>/<n>-season`
- **Download:** `https://subdl.com/s/info/<fileId>/<slug>`
- **Search:** `https://subdl.com/search/<query>`
- **SRT format:** Yes, with season packs
- **Note:** Search pages need JS rendering; API or direct URLs more reliable

### subtitlist.com
- **URL pattern:** `https://www.subtitlist.com/subtitles/<show-slug>`
- **Features:** Download, convert, clean, sync, manage subtitles
- **Formats:** SRT, VTT, SSA, ASS

### subf2m.co
- **URL pattern:** `https://subf2m.co/subtitles/<show-slug>`
- **Languages:** English, Arabic, Indonesian, Vietnamese, Persian, and more
- **Note:** Successor to subscene.com for some content

## Tier 3: Donghua-Specific Sources

### DonghuaWorld (streaming with embedded multi-lang subs)
- **URL:** `https://donghuaworld.com/anime/<show-slug>/`
- **Episode pages:** `https://donghuaworld.com/<show-slug>-episode-<range>-multi-subtitles/`
- **Languages:** English, Persian, Indonesian, Arabic, Bengali, French, German, Italian, Khmer, Polish, Portuguese, Russian, Spanish, Thai, Turkish, Vietnamese
- **Format:** Embedded subs in MP4/MKV (hardsub/softsub), not standalone .srt
- **Note:** Best for watching; not for downloading separate subtitle files
- **Verified:** Soul Land 2 Peerless Tang Sect (26 episodes, Season 1 complete)

### dongsub.net
- **URL pattern:** `https://www.dongsub.net/<date>/<show-slug>.html`
- **Focus:** Dedicated donghua (Chinese anime) subtitles
- **Coverage:** Latest episodes, often within days of release
- **Languages:** English, Indonesian, multi-language

### donghuastream.org (Dailymotion-embedded, KEY source for SRT extraction)
- **URL pattern:** `https://donghuastream.org/<show-episode-slug>/`
- **Video host:** Dailymotion (embedded player) — extract DM video ID from page HTML
- **Subtitle extraction:** Use `yt-dlp --impersonate firefox --write-sub --sub-lang fa --sub-format srt` on the DM video URL
- **Languages available:** fa (Persian), ar, fr, es, pt, ru, tr, pl, bn, id, and more
- **Verified:** Legend of Xianwu Season 3 (39/44 episodes with Persian SRT)
- **Pitfall:** Requires `curl_cffi` for `--impersonate firefox`
- **See:** SKILL.md section 9 for full extraction workflow

### animexin.dev
- **Focus:** Indonesian + English donghua subtitles

### anime4i.com
- **Focus:** English donghua subtitles

### xiaobhaidonghua.com
- **Focus:** Multi-language donghua subtitles

## Tier 4: Telegram Channels (Donghua Subtitle Distribution)

Telegram is a major distribution channel for donghua subtitles. Preview channels without an account via `https://t.me/s/<channel>`.

### Confirmed active channels:
| Channel | Content | URL |
|---------|---------|-----|
| `@soulland` | Soul Land English subs (~7K subs) | https://t.me/soulland |
| `@soul_land_eng` | Soul Land English | https://t.me/soul_land_eng |
| `@donghua_subs` | Hub linking multiple donghua channels | https://t.me/donghua_subs |
| `@soullandsub` | Soul Land 2 Sub Indonesia | https://t.me/soullandsub |
| `@Throne_of_Seal` | Throne of Seal subs | https://t.me/Throne_of_Seal |
| `@Battle_Through_Heavens` | Battle Through Heavens subs | https://t.me/Battle_Through_Heavens |
| `@Perfect_World_Anime` | Perfect World subs | https://t.me/Perfect_World_Anime |

### Discovery pattern:
```bash
# Preview channel content
curl -sL 'https://t.me/s/<channel>' | grep -iP 'subtitle|srt|soul|land'

# SubHD community Telegram group
# https://t.me/+wNZD6i-nGH02NjZl (invite link)
```

## Tier 5: Archive.org (Supplementary)
- **Search API:** `https://archive.org/advancedsearch.php?q=<query>+subtitle&fl[]=identifier,title&output=json&rows=50`
- **Format:** Video files with embedded subtitles (not standalone .srt)
- **Verified:** Soul Land episodes 121-147 with Indonesian subs (9 items)
- **Use case:** Last resort or for specific episode ranges with embedded subs

## Blocked by Anti-Bot (require browser/JS or use alternatives)

| Site | Protection Type | Alternative |
|------|----------------|-------------|
| opensubtitles.org (web) | Anubis proof-of-work | Use REST API instead |
| zimuku.la | JavaScript challenge | SubDL (may have same content) |
| subhd.tv | Cloudflare + bot detection | SubDL or Wayback Machine |
| assrt.net | Bot detection | SubDL or Wayback Machine |
| subscene.com | **DEAD (shutdown 2024)** | SubDL (official successor) or Wayback Machine |
| subf2m.co | Cloudflare | Try direct URL with proper headers |
| animegate.net | CAPTCHA on login | Has hardcoded Persian subs (هاردساب) — no SRT files; browse manually |

## Chinese Subtitle Reality

Chinese subtitles for donghua are typically **hardcoded** (burned into video) in release files from Chinese sources. Standalone Chinese SRT files are rare because:
1. Tencent Video / Bilibili embed subs in their players
2. Fansub groups embed subs in video encodes
3. Soft-subs exist but are distributed via forums/torrents, not public databases

## GitHub Repos (subtitle-adjacent)

| Repo | Stars | Use |
|------|-------|-----|
| hockyy/miteiru | 112 | Subtitle muxer for anime |
| HatsuneMikuUwU/cloudstream-extensions-uwu | 34 | CloudStream streaming extensions |
| blyat-uk/polygluttony | 3 | LLM-powered subtitle translation for donghua |
