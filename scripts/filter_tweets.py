#!/usr/bin/env python3
"""
filter_tweets.py — Stock KOL Watch Step 3 固化脚本（framework v1.6）

把 mcp__followin__twitter(action="user_tweets") 的 tool-result dump 过滤成
窗口内 digest（markdown），供日报提炼。取代每批重写的内联 Python。换别的 tweet MCP 时只需改 find_tweets()/parse_dt() 对应字段。

用法:
    python3 scripts/filter_tweets.py \
        --cutoff 2026-06-10T02:12:00Z \
        --out /tmp/digest_0610b2.txt \
        /path/to/tool-results/mcp-followin-twitter-1781087*.txt

行为（实战定型）:
  - 递归扫 JSON 找 tweet 对象（有 text/full_text + createdAt/created_at 即算）
  - 每个文件按 author.userName 多数票识别主账号（并行调用顺序可能错位）
  - 只保留: 主账号本人 + createdAt >= cutoff + 按 tweet id 去重
  - 每条输出: UTC + SGT 双时间戳 + [RT @x]/[QT @x: 摘要]/[reply] 标记 + 原推 URL + 全文
  - stderr 打印每账号 in-window 计数（直接喂 Step 2 覆盖表）

schema 变了 → 改这个脚本，不要回退到内联重写。
"""

import argparse
import json
import sys
from datetime import datetime, timedelta, timezone
from collections import Counter
from pathlib import Path

DT_FORMATS = (
    "%a %b %d %H:%M:%S %z %Y",       # X API classic
    "%Y-%m-%dT%H:%M:%S.%fZ",
    "%Y-%m-%dT%H:%M:%SZ",
)


def parse_dt(s):
    if not s:
        return None
    for fmt in DT_FORMATS:
        try:
            d = datetime.strptime(s, fmt)
            return d if d.tzinfo else d.replace(tzinfo=timezone.utc)
        except ValueError:
            continue
    return None


def parse_cutoff(s):
    d = parse_dt(s)
    if d is None:
        sys.exit(f"bad --cutoff: {s!r} (want e.g. 2026-06-10T02:12:00Z)")
    return d


def find_tweets(obj, out):
    """递归收集疑似 tweet 的 dict。"""
    if isinstance(obj, dict):
        if ("text" in obj or "full_text" in obj) and (
            "createdAt" in obj or "created_at" in obj
        ):
            out.append(obj)
        for v in obj.values():
            find_tweets(v, out)
    elif isinstance(obj, list):
        for v in obj:
            find_tweets(v, out)


def author_of(t):
    return (t.get("author") or {}).get("userName") or t.get("screen_name")


def sgt(d):
    return (d + timedelta(hours=8)).strftime("%m-%d %H:%M")


def mark_of(t):
    mark = ""
    rt = t.get("retweetedTweet") or t.get("retweeted_status")
    qt = t.get("quotedTweet")
    if rt:
        mark = f"[RT @{author_of(rt) or '?'}]"
    elif qt or t.get("is_quote_status"):
        qa = author_of(qt or {}) or "?"
        qtext = ((qt or {}).get("text") or "")[:160].replace("\n", " ")
        mark = f"[QT @{qa}: {qtext}]"
    if t.get("isReply") or t.get("in_reply_to_status_id"):
        mark = "[reply]" + mark
    return mark


def process_file(path, cutoff):
    """返回 (main_author, rows)；rows = [(dt, text, mark, url), ...] 时间正序。"""
    try:
        data = json.loads(Path(path).read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as e:
        print(f"  !! {path}: {e}", file=sys.stderr)
        return None, []
    tweets = []
    find_tweets(data, tweets)
    counts = Counter(a for a in (author_of(t) for t in tweets) if a)
    if not counts:
        return None, []
    main = counts.most_common(1)[0][0]
    rows, seen = [], set()
    for t in tweets:
        if author_of(t) != main:
            continue
        tid = t.get("id") or t.get("id_str")
        if tid in seen:
            continue
        seen.add(tid)
        cd = parse_dt(t.get("createdAt") or t.get("created_at"))
        if not cd or cd < cutoff:
            continue
        text = (t.get("text") or t.get("full_text") or "").strip()
        rows.append((cd, text, mark_of(t), f"x.com/{main}/status/{tid}"))
    rows.sort(key=lambda r: r[0])
    return main, rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cutoff", required=True,
                    help="窗口下界 UTC, e.g. 2026-06-10T02:12:00Z（取自 $VAULT/_last-pull.md）")
    ap.add_argument("--out", required=True, help="digest 输出路径")
    ap.add_argument("files", nargs="+", help="tool-result dump 文件（可 glob 展开）")
    args = ap.parse_args()

    cutoff = parse_cutoff(args.cutoff)
    chunks = []
    summary = []
    for f in args.files:
        main_author, rows = process_file(f, cutoff)
        if main_author is None:
            summary.append((f"?({Path(f).name})", 0))
            continue
        summary.append((main_author, len(rows)))
        chunks.append(f"\n\n########## @{main_author} ({len(rows)} in-window) ##########")
        for cd, text, mark, url in rows:
            chunks.append(
                f"\n--- {cd.strftime('%H:%MZ')} / SGT {sgt(cd)} {mark} {url}\n{text}"
            )

    Path(args.out).write_text("\n".join(chunks) + "\n", encoding="utf-8")
    print(args.out)
    print("--- in-window counts（喂覆盖表）---", file=sys.stderr)
    for name, n in sorted(summary, key=lambda x: -x[1]):
        print(f"  {name}: {n}", file=sys.stderr)


if __name__ == "__main__":
    main()
