#!/usr/bin/env python3
"""
Filter raw mcp__followin__twitter tool-result files to a recent time window.

Usage:
    python filter_tweets.py \
        --hours 24 \
        --account account_a:/path/to/file1.txt \
        --account account_b:/path/to/file2.txt \
        --out /tmp/tweets_filtered.md

Output: a single markdown file, one section per account, with each retained
tweet on its own subsection containing UTC time, like count, view count,
URL, and full text.

Schema assumed: tool result JSON shape is
{ data: { data: { tweets: [ {createdAt, text, url, likeCount, viewCount,
                              isReply, ...}, ...] } } }
This matches `mcp__followin__twitter(action="user_tweets")`. If you swap in a
different tweet MCP, adjust extract_tweets() to that source's JSON shape — this
file is the one place coupled to the data source's response format.
"""

import argparse
import datetime
import json
import pathlib
import sys


def parse_created_at(s: str) -> datetime.datetime:
    """X API returns 'Wed May 22 14:50:43 +0000 2026'."""
    return datetime.datetime.strptime(s, "%a %b %d %H:%M:%S %z %Y")


def extract_tweets(path: pathlib.Path) -> list[dict]:
    raw = json.loads(path.read_text(encoding="utf-8"))
    # Be liberal about the wrapper shape.
    node = raw
    for key in ("data", "data"):
        if isinstance(node, dict) and key in node:
            node = node[key]
    if isinstance(node, dict) and "tweets" in node:
        return node["tweets"]
    # Some versions return tweets at top level.
    if isinstance(node, list):
        return node
    return []


def filter_account(name: str, path: pathlib.Path, cutoff: datetime.datetime) -> str:
    tweets = extract_tweets(path)
    lines = [f"## @{name}"]
    kept = 0
    for t in tweets:
        if t.get("isReply"):
            continue
        try:
            ts = parse_created_at(t["createdAt"])
        except (KeyError, ValueError):
            continue
        if ts < cutoff:
            continue
        ts_str = ts.strftime("%Y-%m-%dT%H:%M:%SZ")
        like = t.get("likeCount", 0)
        view = t.get("viewCount", 0)
        url = t.get("url", "")
        text = (t.get("text") or "").strip()
        lines.append(f"### {ts_str} (likes:{like} views:{view}) {url}")
        lines.append(text)
        lines.append("")
        kept += 1
    if kept == 0:
        lines.append("_(no tweets in window)_")
    return "\n".join(lines) + "\n"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--hours", type=float, default=24.0, help="time window in hours (default 24)"
    )
    ap.add_argument(
        "--account",
        action="append",
        required=True,
        metavar="HANDLE:PATH",
        help="repeat per account. e.g. --account account_a:/tmp/abc.txt",
    )
    ap.add_argument("--out", required=True, help="output markdown path")
    args = ap.parse_args()

    cutoff = datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(
        hours=args.hours
    )

    chunks = [
        f"Cutoff (UTC): {cutoff.strftime('%Y-%m-%dT%H:%M:%SZ')}",
        f"Window: last {args.hours}h",
        "",
    ]
    for spec in args.account:
        if ":" not in spec:
            print(f"skip malformed: {spec}", file=sys.stderr)
            continue
        handle, path = spec.split(":", 1)
        p = pathlib.Path(path)
        if not p.exists():
            print(f"missing: {p}", file=sys.stderr)
            chunks.append(f"## @{handle}\n_(file not found)_\n")
            continue
        chunks.append("=" * 28)
        chunks.append(filter_account(handle, p, cutoff))

    pathlib.Path(args.out).write_text("\n".join(chunks), encoding="utf-8")
    print(args.out)


if __name__ == "__main__":
    main()
