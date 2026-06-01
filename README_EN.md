<!-- Language: English | 中文: README.md -->

# Stock KOL Watch — a daily-brief framework for stock KOL accounts

> **Turn the pile of stock KOLs you follow into a system that produces a daily watch brief + decision-support notes automatically.**
> Say "run KOL watch" and it pulls your whole roster, distills it into a dated brief with source links, updates a per-ticker and per-sector running note, and tracks signals on your holdings — **it never places orders, never predicts prices, never makes up numbers. The call is always yours.**

`Claude Code skill` · `methodology framework (sanitized, ready to use)` · `bilingual (中文 / EN)`

> Built and run in Chinese originally; the workflow is **language-agnostic** — it already handles English-language KOLs (most carry cashtags, which actually makes them easier than non-cashtag accounts), and output follows the language you talk to Claude in.

---

## The problem: you follow 15 KOLs — now what?

- Tweets scroll past and you forget them; **nothing turns the scattered signals into a searchable note**
- A KOL is bullish today, flips tomorrow; **you can't recall who said what at which price**
- You want to review "why did I buy last time" — **the original rationale is gone**
- You ask an AI to help read the tape, and **it blurts out "buy the dip at $X"** — an unsourced number is the most dangerous thing of all

This framework plugs each of these with **mechanisms**, not willpower.

---

## What it produces

Turns the last N hours of tweets from **a fixed roster of stock KOL accounts you choose** into structured, traceable, reviewable decision material:

- **One merged daily brief** (Daily/) — two-zone structure (a State zone that OVERWRITES + an Event-stream zone that APPENDS), so multiple pulls a day merge seamlessly
- **A running note per ticker** (Tickers/) — price snapshots + price-target tracking + KOL views + bear cases + your position
- **A running note per sector** (Sectors/) — strength-rating history + thesis + counter-signals
- **A decision loop** (Decisions-Journal / Pre-Trade-Checklist) — every trade records "why" + 1-week/1-month/3-month reviews that feed back into the pre-trade gate
- **A weekly review** (Weekly/) — 12 sections incl. benchmark comparison + account-rating review + profile deepening

> This is an **information-organizing + decision-support methodology — NOT a signal generator. It doesn't shout calls, predict prices, or fabricate numbers.** The judgment stays with you.

---

## What it is / isn't

- ✅ Is: a workflow that makes scattered KOL signals **structured + traceable (every item carries UTC + account + original tweet URL) + reviewable**; a discipline for watching the tape.
- ❌ Isn't: trade advice, price prediction, or automated trading. KOL views are quoted, never endorsed.

## Why it's worth it

The three biggest traps in following KOLs, each plugged by a mechanism:

1. **Input gaps** (you didn't pull everything you should) → Step 2 pull-coverage gate + Step 10.95 completeness-critic
2. **Landing gaps** (you pulled it but didn't write it all down) → Step 10.9 close-out gate (a hook mechanically checks file mtimes + sector-sync declaration)
3. **No made-up numbers** (price levels by gut feel) → a hard rule throughout: every number must carry a `[data]` or `[principle]` source tag

Plus one most people lack: a **decision-review loop** — every trade is logged, revisited for right/wrong on a schedule, and fed back into the next pre-trade checklist.

---

## What the output looks like (sample, tickers fictional)

The daily brief uses a two-zone structure (State zone + Event-stream zone), so multiple pulls a day merge cleanly:

```markdown
# 2026-XX-XX Daily Brief
## Pull batches
| Batch | Time | Window | Coverage | Key new |
| #1 | 09:19 | 15.4h | 8/8 (7✅/1⚪) | Memory chain multi-source confluence / $XXXX pre-market breakout unconfirmed |

=== State zone (OVERWRITE) ===
## Holdings snapshot
| Ticker | Price | P&L | This-window signal | thesis health |
| $XXXX | $X | +25% | 🟢🟢 three sell-side upgrades + dual real-position hold | 🟢 strong |
| $YYYY | $X | -3%  | 🟡 sector momentum cooling (indirect headwind) | 🟡 flat |

=== Event-stream zone (APPEND per batch) ===
### Batch #1 — 09:19 (window ...)
#### 🟢🟢 Memory super-cycle (multi-source)
- @account_a 11:16Z: bank raises Co. X profit forecast ... (with tweet URL)
- @account_b 14:51Z (sell-side NDR): DRAM undersupply extended to ... (verbatim numbers)
#### 🔴 Bear case
- @account_c 21:08Z: "this roadmap is a mistake" ← the roster's only short voice
```

Each ticker also gets a running note (price snapshots / PT tracking / KOL view history / bear case / your position), each sector a strength-evolution note, and each decision a journal entry with 1w/1m/3m reviews.

---

## Two modes (your choice)

| | 🅰️ Flagship (persistent / vault) | 🅱️ Quick brief (no vault / single-session) |
|---|---|---|
| Output | Daily brief + ticker/sector running notes + decision loop + weekly, all landed to files | **In-conversation brief only**, nothing written to disk |
| Needs | vault + hook + cross-session state | just Claude + a data-source MCP + a roster |
| Value | accumulates & is reviewable, decision-learning loop (compounds over days/weeks) | zero-config, instant, useful in a single run |

Say "quick brief / just try it" → 🅱️; "full version / run the daily" → 🅰️; if unspecified it checks whether `KOL_VAULT` is set (set → 🅰️, unset → 🅱️). Both modes share the same distillation logic (Steps 2–9) and diverge only on whether they persist. 🅱️ is the zero-friction entry point — upgrade to 🅰️ once you see the value.

## Setup (first time, ~10 min)

1. **Set your vault path**:
   ```bash
   export KOL_VAULT="/path/to/your/vault/Stock-Watch"
   ```
2. **Build your roster**: **runs out of the box — ships a 5-account public starter roster** (`references/example-roster.md`, ⚠️ illustrative, NOT a recommendation), copy it and go. Replace/expand into your own 8–15 complementary accounts via the methodology in `references/account-roster.md` (**keep at least 1–2 steady bears — don't let the list go all-bull**).
3. **Wire a data source**: the reference implementation uses the `mcp__followin__*` MCP (tweets / quotes / sell-side / signals). Swapping in another tweet/market MCP is **not free** — you edit the `mcp__followin__*` calls in SKILL.md (~7 spots) + the `extract_tweets()` JSON schema in `filter_tweets.py`; the methodology (windowing / distillation / landing / gates) is unchanged.
4. **(Optional) enable the hook**: wire `scripts/daily-gate-check.sh` as a Claude Code Stop hook for mechanical landing checks:
   ```json
   { "hooks": { "Stop": [ { "hooks": [ { "type": "command",
     "command": "bash ~/.claude/skills/stock-kol-watch/scripts/daily-gate-check.sh" } ] } ] } }
   ```

## Usage

Install this directory as a Claude Code skill, then tell Claude "run KOL watch" / "pull the latest". It follows the `SKILL.md` workflow: scan holdings → set window → pull the full roster → distill → land the three layers → recalibrate → gate → completeness critic → report.
See **[USER-GUIDE_EN.md](USER-GUIDE_EN.md)** for the full hands-on guide (what to install, what to configure, what info you need to provide, daily commands).

## Layout

```
LICENSE                        MIT + not-investment-advice notice
README.md / README_EN.md      Overview (中文 / English)
USER-GUIDE.md / _EN.md         Hands-on guide (中文 / English)
SKILL.md                       Workflow spec, Step 0 → 11 (Chinese; Claude reads it fine)
references/
  account-roster.md            How to build/rate/maintain your roster (methodology)
  example-roster.md            Starter roster template (roles to fill + how to find accounts)
  output-templates.md          Daily / ticker / sector landing templates
  vault-skeleton.md            Seed structure for the 12 files created on first init
scripts/
  daily-gate-check.sh          Close-out gate Stop hook (mtime + sector-sync checks)
  filter_tweets.py             Filter a raw tweet dump to a time window → markdown
  coverage-audit.sh            Coverage audit: cashtag frequency from dumps → BUILD/ARCHIVE candidates (prevents missed ticker/sector files)
  pre-commit-privacy-scan.sh   Pre-commit scan (blocks personal paths / real handles / secrets)
```

> 🔒 **Maintaining this repo (after a fork)**: install `scripts/pre-commit-privacy-scan.sh` as a git pre-commit hook — it blocks any commit containing personal paths / tokens / private emails. Put your own real roster handles in a local `.privacy-patterns.local` (gitignored, **never committed**) so the scan can catch them without publishing them.
> Install: `cp scripts/pre-commit-privacy-scan.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit`

> Note: `SKILL.md` and `references/` are kept in Chinese. Claude reads them fine and operates in any language; only the user-facing docs (README / USER-GUIDE) are bilingual. PRs translating the rest are welcome.

## License

**MIT** (see [LICENSE](LICENSE)). ⚠️ No investment-advice character whatsoever — it only organizes third-party opinions and public data, is not buy/sell advice or price prediction; use at your own risk.
