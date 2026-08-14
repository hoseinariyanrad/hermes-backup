#!/usr/bin/env python3
"""
Translate English SRT subtitles to a target language using deep-translator.
Usage: python translate_srt.py <input.srt> <output.srt> [src_lang] [tgt_lang]
"""
import os
import re
import sys
import time
from deep_translator import GoogleTranslator

def parse_srt(content):
    """Parse SRT into list of (index, timing, text) tuples."""
    blocks = re.split(r'\n\n+', content.strip())
    entries = []
    for block in blocks:
        lines = block.strip().split('\n')
        if len(lines) >= 3:
            index = lines[0].strip()
            timing = lines[1].strip()
            text = '\n'.join(lines[2:])
            entries.append((index, timing, text))
    return entries

def translate_batch(texts, translator, batch_size=10, delay=0.5):
    """Translate a list of texts, batching to reduce API calls."""
    results = []
    for i in range(0, len(texts), batch_size):
        batch = texts[i:i+batch_size]
        joined = '\n|||SEP|||\n'.join(batch)
        clean = re.sub(r'<[^>]+>', '', joined)
        try:
            translated = translator.translate(clean) if clean.strip() else joined
        except Exception as e:
            print(f"  Batch error at {i}: {e}", file=sys.stderr)
            translated = joined
        parts = translated.split('|||SEP|||')
        for j, text in enumerate(batch):
            results.append(parts[j].strip() if j < len(parts) else text)
        if i + batch_size < len(texts):
            time.sleep(delay)
    return results

def translate_srt(input_path, output_path, src='en', tgt='fa', header=None):
    """Translate an SRT file and write output with optional header."""
    with open(input_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    entries = parse_srt(content)
    translator = GoogleTranslator(source=src, target=tgt)
    texts = [e[2] for e in entries]
    translated = translate_batch(texts, translator)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        if header:
            f.write(header + '\n\n')
        for (index, timing, _), text in zip(entries, translated):
            f.write(f"{index}\n{timing}\n{text}\n\n")
    
    return len(entries)

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <input.srt> <output.srt> [src] [tgt]")
        sys.exit(1)
    
    src = sys.argv[3] if len(sys.argv) > 3 else 'en'
    tgt = sys.argv[4] if len(sys.argv) > 4 else 'fa'
    
    header = f"1\n00:00:00,000 --> 00:00:05,000\nAI Translation ({src} → {tgt}) by Hermes Agent"
    count = translate_srt(sys.argv[1], sys.argv[2], src, tgt, header)
    print(f"Translated {count} entries: {sys.argv[1]} → {sys.argv[2]}")
