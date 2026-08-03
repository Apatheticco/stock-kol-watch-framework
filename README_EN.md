<!-- Language: English | 中文: README.md -->
**Language / 语言**: English (this file) · [中文](README.md)

# Stock KOL Watch

> **You follow a dozen people on Twitter who talk about stocks. This turns what they say every day into a note you'll actually read.**

Say "run KOL watch" and it pulls every new tweet from your list, strips the jokes and the ads, organizes what's left by ticker and sector, watches for signals on your holdings — and **every single line carries a link back to the original tweet so you can verify it**.

`Claude Code skill` · `中文 / English`

> Built and run in Chinese originally, but the workflow is language-agnostic. It handles English-language KOLs fine (they usually carry cashtags, which actually makes them *easier* than non-cashtag accounts), and it answers in whatever language you talk to it in.

---

## Is this for you? (30 seconds)

**Probably yes** if two or more of these are true:

- You follow 8+ stock accounts but **mostly just scroll and forget**
- You want to review "why did I buy this last time" and **can't find the original rationale**
- You can't recall what price someone was bullish at — **or whether they've quietly flipped since**
- An AI has helped you read the tape and **blurted out "buy the dip at $X"** out of thin air

**Probably not** if:

- You want trade signals or automation — it **never calls trades and never predicts prices**, it organizes what others said
- You follow 1–2 accounts — just read them, you don't need a system
- You expect it to sync your brokerage positions — it doesn't connect to a broker; you tell it your positions

---

## Try it in 5 minutes (zero configuration)

Once installed, just say:

> **"Run a quick brief on these 5 accounts: @jukan05 @aleabitoreddit @nft_hu @xiaomustock @qinbafrank"**

(These 5 ship as public reference accounts — ⚠️ illustrative only, **not a recommendation, not investment advice**.)

You get a brief right there in the conversation. **Nothing is written to disk**:

```
Coverage: 5/5 (4✅ pulled / 1⚪ nothing in window)

⭐ Most important today
1. Samsung foundry targeting 100% utilization this year (currently 70-80%), driven by
   HBM4 base dies on 4nm — but the real gate is 2nm yield moving from the 60s to the
   70s, not utilization itself.        [@account_A 08-03 07:28Z · original tweet]
2. The carry trade won't unwind fast: all 4 indicators untriggered; this FX move is
   government intervention, not capital fleeing.  [@account_B 08-03 05:58Z · link]

🔭 Non-holdings chatter: $XXXX (quiet period ends 08-04, buyback plan could drop anytime)
🔴 Bear case: 0 items this batch — that's a structural gap in YOUR list,
   not evidence that no bear case exists.
```

If it's useful, read on. If not, you're out five minutes.

---

## What it does for you long-term

| You say | It does |
|---------|---------|
| "run KOL watch" | Pulls the full list → daily brief → updates each ticker & sector running note → tells you the 3 things most worth seeing |
| "catch up on last night" | Incremental pull from the last checkpoint, **merged into the same day's brief** — never two files contradicting each other |
| "I bought 100 XXXX @ $85" | Updates the holdings table, ticker note and sector note, and **logs a decision** with 1-week / 1-month / 3-month review prompts |
| "should I buy XXXX now?" | Runs 5 checks (macro red lights / sector strength / is the original bull still bullish / position sizing / 5 reverse-prior questions), **lays out the state and lets you decide — never decides for you** |
| "give me a stop-loss plan" | Offers 4–5 **sourced** trigger candidates (technical level / thesis author retracted / fundamentals falsified / sector divergence) — **it will not pull a percentage out of the air** |
| "show me everything on XXXX" | Opens that ticker's running note: price history, who said what and when, bear cases, your own position log |
| "run the weekly" (weekends) | 5 sections: holdings evolution / sector evolution / account-quality review / **your own decision-quality review** / next week's calendar |

After a few weeks you own three things you didn't have before:

1. **A searchable history** — "who was bullish at $85 three weeks ago" takes five seconds
2. **A decision journal** — every trade records why, prompts you to revisit whether you were right, and feeds the lesson into your next pre-trade checklist
3. **A bear-case archive** — counter-arguments accumulate separately and are never deleted, which is the cure for remembering only what agreed with you

---

## Three things it will never do

These are hard constraints wired into the workflow:

**1. It won't make up numbers.** Every specific price, quantity or percentage must trace to a data source or a stated principle. No basis → it gives you direction only, or plainly says "I don't know, it depends on your risk tolerance."

> ❌ "buy the dip around here" ✅ "buy at the 50-day MA, $X 〔market data〕"

**2. It won't decide for you.** When a KOL calls a trade it quotes and attributes; it never endorses. When you signal intent to trade, it runs the checklist, shows you the state, and stops.

**3. It won't pretend to be complete.** Every pull publishes a coverage table marking each account explicitly — pulled / pulled-but-empty / failed. **No account gets to quietly go missing.** If tweets were left behind, the script says so out loud.

---

## Getting started

### What you need

| Requirement | Notes |
|-------------|-------|
| Claude Code | This is a Claude Code skill |
| A tweet data source (MCP) | Reference implementation uses `followin`; others work |
| A Markdown folder | Only if you want long-term accumulation. Obsidian is nicest; a plain folder works |

### Install

```bash
cp -r stock-kol-watch-framework ~/.claude/skills/stock-kol-watch
```

### Two modes — start low, upgrade later

| | 🅱️ Quick brief | 🅰️ Persistent |
|---|---|---|
| **Output** | In-conversation brief only, no files | Daily brief + per-ticker/per-sector running notes + decision journal + weekly |
| **Config needed** | none | one folder path |
| **When** | trying it out / occasional glance | building your own research archive |

To upgrade to 🅰️: set one environment variable, then say "initialize the vault and run KOL watch."

```bash
export KOL_VAULT="/path/to/your/vault/Stock-Watch"
```

It builds the directory skeleton, asks for your holdings, cash and timezone, and produces the first daily brief. After that it's one sentence a day.

**Step-by-step in [USER-GUIDE_EN.md](USER-GUIDE_EN.md)** (what to install, what to configure, what you must supply, day-to-day commands).

### ⚠️ You only need to supply three things

| Info | Example |
|------|---------|
| Holdings (ticker/cost/qty) | "I hold 100 XXXX at $85" |
| Cash (**including money-market**) | "$X cash + $Y money-market" |
| **Report every fill** | "I sold 50 XXXX @ $92" |

The third is the lifeline: **it doesn't connect to your broker. Forget to report a fill and your P&L and position weights drift wrong silently, with no alarm.**
Report cash in full, or it will refuse to compute position percentages — a percentage built on an unverified denominator is a fake number.

---

## About your account list

The list is the intelligence network; its quality is your quality. Five public accounts ship built-in so you can run immediately, but **replace them with your own 8–15 for real use**.

The most common mistake is also the most dangerous: **the list quietly becomes all-bull**. The built-in five have exactly this flaw (semiconductor-heavy, no bear). Before real use, **add 1–2 steady skeptics** — they are the control group for your own thesis.

How to build, rate and maintain one → [references/account-roster.md](references/account-roster.md)

---

## FAQ

**Will it place orders?** No. It organizes information, surfaces signals, runs checklists. Buying and selling is always your decision and your action.

**Will it tell me if a KOL is accurate?** Not daily — it logs events and the price at the time. Weekly it reviews *signal quality* (not whether the ticker went up), and rating changes need your confirmation.

**Why does it sometimes refuse to give a price level?** That's a feature. Numbers with no data or principle behind them don't get written — an invented price level is the most dangerous output there is.

**What if data doesn't come through completely?** Three backstops: account-level coverage table, tweet-level pagination warning, post-hoc completeness review. But **you choose the list and you report the positions** — those two ends are on you.

**Can I use something other than followin?** Yes, two places to change. See "For people who want to modify it" below.

---

## Scope & verification status

- **Verification status (v2.0, stated honestly)**: the main chain (pull → filter → distill → land → gate) has been **verified end-to-end on live data**; the **two subagent paths and the 5-section weekly are template-verified only, not yet exercised in a real run** — early users may hit rough edges; feedback welcome.
- Extracted from a personal system that actually runs, with **private information stripped**: no personal paths, no full private roster, no position sizes, no paid sources.
- Advanced layers (live-position feeds / broker research / independent research / RT-QT candidate mining / archiving) are **not** in the core chain — add them back from [references/advanced-extensions.md](references/advanced-extensions.md) when you need them (7 sections; every parameter and trap measured against the live API, including one measured rejection).

<details>
<summary><b>For people who want to modify it (layout / swapping the data source / maintaining a fork)</b></summary>

```
SKILL.md                      Workflow spec the AI reads (Step 0 → 11; kept in Chinese)
USER-GUIDE.md / _EN.md        Human operating manual
references/
  account-roster.md           Starter list + how to build/rate/maintain your own
  output-templates.md         Daily / ticker / sector landing templates
  vault-skeleton.md           The 8 seed files created on first init
  critic-prompt.md            Spawn prompt for the completeness-review subagent
  advanced-extensions.md      7 advanced layers (incl. one measured rejection)
  failure-modes.md            19 real failure modes (symptom → root cause → fix)
scripts/
  daily-gate-check.sh         Close-out gate Stop hook (file mtime + sector-sync checks)
  filter_tweets.py            Filter a raw tweet dump to a time window → digest
  pre-commit-privacy-scan.sh  Pre-commit scan for personal info
```

**Swapping the data source** (defaults to followin) is not free — two places, methodology unchanged:
1. the `mcp__followin__*` calls in `SKILL.md` (grep finds them all)
2. `find_tweets()` / `parse_dt()` in `filter_tweets.py` (JSON schema + timestamp formats)

**Maintaining a fork**: install `scripts/pre-commit-privacy-scan.sh` as a git pre-commit hook — it blocks commits containing personal paths, tokens or private emails. Put your own real handles in a local `.privacy-patterns.local` (gitignored, never committed) so the scan catches them without publishing them.

```bash
cp scripts/pre-commit-privacy-scan.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
```

**Enabling the close-out gate hook** (optional, strongly recommended) — add to `~/.claude/settings.json`. ⚠️ **Inline the vault path in the command**; don't rely on a shell export. If the hook process doesn't inherit it, the gate silently never runs and you'd never know.

```json
{ "hooks": { "Stop": [ { "hooks": [ { "type": "command",
  "command": "KOL_VAULT=/path/to/vault bash ~/.claude/skills/stock-kol-watch/scripts/daily-gate-check.sh" } ] } ] } }
```

`SKILL.md` and `references/` are kept in Chinese — Claude reads them fine and operates in any language; only the user-facing docs are bilingual. Translation PRs welcome.

</details>

---

## License

**MIT** (see [LICENSE](LICENSE)).

⚠️ **Not investment advice.** This tool organizes third-party public opinions and market data. It does not constitute buy/sell recommendations or price predictions, and takes no responsibility for any investment outcome. Use at your own risk.
