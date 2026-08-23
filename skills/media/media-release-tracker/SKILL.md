---
name: media-release-tracker
description: "Track daily media releases with per-item formatted messages."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [media, donghua, anime, tracking, monitoring, scheduled, reporting]
    related_skills: [product-price-monitor, competitor-news-monitor]
---

# Media Release Tracker

Monitor and report daily new releases of media content (Donghua/Chinese anime, Japanese anime, shows, movies) from tracking sites. Each item is sent as its own separate message with images, multilingual names, episode details, synopsis, and download links.

## When to Use

- "Check what new Donghua episodes came out today."
- "Track daily anime releases and notify me."
- "Report new media episodes with images and links."
- A cron tick fires for a scheduled daily media check.

## CRITICAL User Preference

**ONE item = ONE message. NEVER combine multiple items into a single message.**

If 5 anime released today, send exactly 5 separate messages. If 3, send 3. The number of messages MUST equal the number of items found. Send them back-to-back consecutively without waiting for user confirmation between messages.

This is non-negotiable. The user has corrected this behavior multiple times.

## Procedure — Setup (foreground, once)

### 1. Define the tracking scope

Record:
- Type of media (Donghua, anime, etc.)
- Specific titles to watch (if user has favorites)
- Source websites for tracking
- Language for output (e.g., Persian/Farsi)
- Download source preferences (Iranian sites, Telegram channels)

### 2. Define the output format

Standard per-item message format:
```
[Poster image inline]

**English Name**
**نام چینی:** (Chinese characters)
**نام فارسی:** (Persian name)

**ژانر:** (Genre)
**تعداد فصل‌ها:** (Total seasons)
- **فصل X:** Y قسمت (Z قسمت تا امروز)
**کل قسمت‌های منتشر شده:** X قسمت
**وضعیت:** در حال پخش / تمام شده
**روز پخش:** (Weekly air day)
**پلتفرم:** (Platform)
**امتیاز:** ⭐ X از ۱۰

**لینک آنلاین:** [link]

**خلاصه داستان:** (Full detailed synopsis in target language)

📥 **دانلود با زیرنویس فارسی:**
- [آپارات](link)
- [تلگرام](link)
```

### 3. Schedule the cron job

```
cronjob(action="create",
        schedule="30 5 * * *",  # adjust for timezone
        prompt="Load the media-release-tracker skill and run the daily check.",
        deliver="origin")
```

**Pitfall: Cron job model config** — Always pin model and provider explicitly:
```
/opt/venv/bin/hermes cron edit <job_id> --model hermes --provider openai-api
```
Without this, the cron job will fail with "no model configured" error.

## Procedure — Tick (each scheduled run)

### 4. Search for releases

Check tracking sources for today's new episodes:
- animexin.dev/release-date/ (comprehensive donghua schedule)
- mydonghuareview.com (release calendar)
- animeschedule.net (airing timetable)
- donghuasubs.com/schedule
- User's favorite title trackers

### 5. Count and send individually

Count exactly how many items were found. Then send EACH as its own separate Telegram message:
- Message 1: Anime #1 with all details
- Message 2: Anime #2 with all details
- Message 3: Anime #3 with all details
- ...and so on for ALL items

After the last item, send a summary: "Today X anime were updated."

### 6. Format each message

For each item, produce a complete message following the format defined in step 2. Include:
- Poster image (inline photo)
- Name in English, Chinese, and target language
- Episode/season counts (aired vs total)
- Full detailed synopsis (not brief — the user wants comprehensive descriptions)
- Download links for regional sites (e.g., Iranian sites for Persian users)

## Pitfalls

- **Combining items in one message** — This is the #1 user frustration. Each item MUST be its own message.
- **Sending only partial results** — If 9 anime released, send all 9, not just 1 or 2.
- **Missing the cron model config** — Cron jobs need explicit model/provider pinning or they fail silently.
- **Brief/insufficient synopsis** — User wants full, detailed story descriptions, not one-liners.
- **Missing episode counts** — Always include: seasons, episodes per season, episodes aired vs total.
- **Waiting for user confirmation between messages** — Send all messages consecutively without pausing.

## Verification

- [ ] Number of messages sent equals number of items found.
- [ ] Each message contains only ONE item with its own image.
- [ ] Every message includes: 3 language names, episode counts, full synopsis, download links.
- [ ] Cron job has model/provider explicitly pinned.
- [ ] Messages are sent back-to-back without gaps.
