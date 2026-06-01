<!-- Language: English | 中文: USER-GUIDE.md -->

# User Guide — How to use Stock KOL Watch

This guide is for the **human operator**: what to install, what to configure, **what info you need to provide**, and how to talk to it day to day.
(`README_EN.md` = overview; `SKILL.md` = the workflow spec the AI reads; this file = your operating manual.)

---

## 0. One-sentence model

You maintain a "roster of stock KOLs you follow." Each day you tell Claude "run KOL watch," and it pulls those accounts' new tweets, distills them into a daily brief, updates a running note for each ticker and sector, tracks signals on your holdings, and lands every conclusion into your Obsidian (or any Markdown) vault — **with source links for traceability, and without making buy/sell decisions for you**.

---

## Two modes (pick before you run)

- 🅰️ **Flagship (persistent)**: lands daily brief + running notes + decision loop + weekly; value compounds over time. Needs a vault.
- 🅱️ **Quick brief (no vault)**: an in-conversation brief only, zero-config, useful in a single run — good for trying it out / the occasional glance.

How to trigger: say "**quick brief / just try it**" → 🅱️; "**full version / run the daily**" → 🅰️; if unspecified it checks whether `KOL_VAULT` is set (set → 🅰️, unset → 🅱️). In 🅱️ mode, holdings signals require you to **state your positions on the spot** (no vault = no history), and cross-day accumulation / decision reviews aren't available — upgrade to 🅰️ for long-term use. The install/config below targets 🅰️; for 🅱️ only, skip the vault and just wire a data-source MCP + supply a roster.

## 1. Prerequisites

| You need | Notes |
|----------|-------|
| **Claude Code** | This framework is a Claude Code skill |
| **A Markdown vault** | Obsidian recommended; a plain folder works too. All output lands here |
| **A tweet + market data source (MCP)** | Reference impl uses the `followin` MCP (tweets/quotes/sell-side/signals). Others work too — just swap the calls |
| **(Optional) Stop-hook permission** | Needed to enable the mechanical close-out gate |

---

## 2. Install

Drop the whole `stock-kol-watch-framework/` directory into your skills folder:

```bash
cp -r stock-kol-watch-framework ~/.claude/skills/stock-kol-watch
```

(Or distribute as a plugin. The skill name comes from the `name` field in `SKILL.md` frontmatter.)

---

## 3. Configure (first time, ~10 min)

### 3.1 Set the vault path
```bash
export KOL_VAULT="/path/to/your/vault/Stock-Watch"
```
Put it in `~/.zshrc` / `~/.bashrc` to persist. Everything lands under it.

### 3.2 Enable the close-out gate hook (optional but strongly recommended)
Add to `~/.claude/settings.json`:
```json
{ "hooks": { "Stop": [ { "hooks": [ { "type": "command",
  "command": "bash ~/.claude/skills/stock-kol-watch/scripts/daily-gate-check.sh",
  "timeout": 15 } ] } ] } }
```
Effect: when you try to end a session after running the brief, the hook mechanically checks "were all the files that should be updated actually updated?" and blocks you if not — turning "I think I wrote it" into "the system won't let me cut corners."

### 3.3 Build your roster (the most important step)
The framework **includes a 5-account public starter** (⚠️ illustrative, NOT a recommendation — runs out of the box). Beginners: copy `references/example-roster.md` (the 5-account sample + a role-by-role template + how to find accounts), fill it in, and save to `$KOL_VAULT/references-roster.md` (🅰️ reads the roster from here; in 🅱️ just tell Claude). **These 5 lean semiconductors with no bear voice — add a skeptic before real use.** Rating/profiling method is in `references/account-roster.md`.

Selection principles (see the roster template):
- Cover the few main threads you care about (e.g. memory, optical, power semis…)
- **Diverse viewpoints**: an analyst, a trader, a sell-side aggregator, a macro voice — one or two of each
- ⚠️ **Keep at least 1–2 steady bear/skeptic voices** — don't let the list become all-bull (the most dangerous blind spot)

---

## 4. ⚠️ What info you need to provide

This is the core. The framework runs on the inputs you feed it — **the more accurate, the more reliable the conclusions**:

| Info | Required? | When | Example |
|------|-----------|------|---------|
| **Roster** | ✅ Required | First setup | "I want to follow @account_a @account_b … these N" |
| **Holdings** | Needed for holdings monitoring | Setup + after each trade | "I hold 10 shares of $AAAA @ $50; 100 of $BBBB @ $12" (fictional) |
| **Cash basis** | ⚠️ Required for Risk Budget | Setup + on change | "$X cash + $Y money-market" (**include near-cash, not just the trading-account balance**) |
| **Timezone / window** | Has a default | Setup (or ad hoc) | "I'm in EST, split by natural day" / ad hoc "pull last 12h" |
| **Trade actions** | Holdings accuracy depends on it | Right after each fill | "I bought 20 shares of $CCCC @ $30" (fictional) |
| **Data-source creds** | ✅ | When installing the MCP | followin (or whichever MCP) connection |
| **Your thesis (optional)** | No | When you want something tracked | "I'm betting memory re-rates as growth — track the evidence" |

**Hard rules**:
- **Position size/cost only comes from what you tell it** (no broker integration). If you trade and forget to say so → P&L, weightings, thesis all cascade wrong, silently. **Build the habit: say one line whenever you fill.**
- Always report cash in full (incl. money-market / off-account). Otherwise it **refuses** to compute Risk-Budget red lines (it would rather report nothing than fabricate a denominator).

---

## 5. First run (cold start)

A fresh vault is empty. The first time, just say:

> **"Initialize the vault, then run KOL watch"**

Claude will (this is SKILL **Step 0.0 first-time init**, 🅰️ flagship only):
1. Create the directory skeleton (Daily/ Tickers/ Sectors/ Watchlist/ Weekly/) + **11 seed files** per `references/vault-skeleton.md`: references-roster / Portfolio / Orders / Decisions-Journal / Pre-Trade-Checklist / Macro / Spotlight / Daily-Index / _Sectors-Index / _last-pull / Candidate-Roster
2. Ask for your holdings, cash, roster, timezone (if not yet given)
3. Pull the roster once and produce the first daily brief

After that, daily use is just "run KOL watch." (🅱️ quick-brief mode needs no init — skip this step.)

---

## 6. Day-to-day commands

| You say | It does |
|---------|---------|
| **"run KOL watch" / "pull the latest"** | Pull the full roster → daily brief → update tickers/sectors → recalibrate → gate → report the 3 things most worth seeing |
| **"catch up on last night" / "evening pull"** | Incremental pull from the last window, **merged** into the same day's brief (two-zone protocol) |
| **"I bought/sold X N shares @ Y"** | Updates Tickers + Portfolio + Sectors + Decisions-Journal + Orders (automatically) |
| **"can I buy X / should I add to X"** | Runs the 5 pre-trade gates (Macro / sector / thesis / Risk Budget / reverse-prior), lays out the state, lets you decide — **never decides for you** |
| **"give me a stop-loss plan for X"** | Offers 4–5 **sourced** trigger candidates (technical level / KOL / institutional / fundamental / sector-sync), you pick |
| **"walk me through account X's logic"** | Reads the daily brief's per-account section |
| **"show me everything on X"** | Reads `Tickers/X.md` |
| **"how has sector X evolved"** | Reads `Sectors/X.md` strength table |
| **"run the weekly" / on weekends** | 12-section weekly review (holdings evolution / sectors / account-rating review / decision-quality review / benchmark comparison…) |
| **"add @XX / drop @YY"** | Adjusts the roster for this run, asks whether to update the roster file |

---

## 7. Where to find the output

| To see | Open |
|--------|------|
| What happened today | `Daily/YYYY-MM-DD.md` |
| 30-second lookback over recent days | `Daily/Daily-Index.md` |
| Your holdings overview | `Portfolio.md` |
| One-page decision view | `Spotlight.md` (holdings + pending + hot sectors + today's to-dos) |
| A ticker's full history | `Tickers/<TICKER>.md` |
| How a sector evolved | `Sectors/<板块>.md` |
| Each decision + its review | `Decisions-Journal.md` |
| This week's review | `Weekly/YYYY-W##.md` |

---

## 8. FAQ

**Q: Will it place orders / shout calls?**
No. It only organizes info, lays out signals, and runs pre-trade gates. You always decide and execute yourself.

**Q: Will it tell me whether a KOL's call was "right"?**
Not daily — it only logs events + time + price at the time. Weekly it reviews ratings by *signal quality* (not whether the call went up). Rating changes need your confirmation.

**Q: Why does it sometimes refuse to give a specific level/percentage?**
"No made-up numbers" is a hard rule. Without data or a principle behind it, it won't give a number — only a qualitative direction. That's a feature, not a bug.

**Q: What if data is pulled incompletely / an account is missed?**
Two safety nets: the pull-coverage gate (forces a full roster coverage table) + the completeness critic (reverse-scans the raw tweets for omissions). But **the input side is on you** — the roster is yours to define, holdings yours to report.

**Q: Can I use a data source other than followin?**
Yes. followin is the data-source adapter layer; replace the `mcp__followin__*` calls in `SKILL.md` with your tweet/market MCP — the methodology is unchanged.

**Q: What about live-position monitoring?**
The framework bundles no live/paid source (sanitized out). SKILL Step 5.6 leaves a generic extension point — wire your own trustworthy live feed, minding the traps noted there ("value column ≠ cost", "same source counts as 1").

---

## 9. One-line getting-started

1. `export KOL_VAULT=...`
2. Wire the hook (optional)
3. Tell Claude your roster + holdings + cash (incl. money-market)
4. Say "initialize the vault and run KOL watch"
5. After that, "run KOL watch" daily; whenever you fill, say one line "I bought/sold …"
