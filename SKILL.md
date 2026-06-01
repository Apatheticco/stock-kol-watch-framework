---
name: stock-kol-watch
description: Stock KOL Watch — 把一组自选股票 KOL 账号的近 N 小时推文，转成"一份合并日报 + 每标的累积笔记 + 每板块累积笔记"的决策辅助系统。
version: 1.0-framework
---

# Stock KOL Watch — 股票 KOL 观察日报框架

> 把你**固定关注的一组股票 KOL 账号**的近 N 小时推文，转成"**一份合并日报 + 每个标的一份累积笔记 + 每个板块一份累积笔记**"。
> 这是一套**信息整理 + 决策辅助**方法论，不是 signal generator——它帮你把散落的 KOL 信号结构化、可追溯、可复盘，**判断权永远在你手里**。

> ⚠️ **这是脱敏框架版**。原版深度耦合作者的个人配置（vault 路径、实盘群、付费源、具体关注名单）。本版已剔除全部私有信息，保留可复用的方法论骨架。**首次使用前先做下面的「配置」。**

---

## 🔧 配置（首次使用必做）

1. **设 vault 路径**：本框架把结果落盘到一个 Obsidian（或任意 Markdown）vault。设环境变量或在脚本里改：
   ```bash
   export KOL_VAULT="/path/to/your/vault/Stock-Watch"
   ```
   所有文档路径都相对它。下文用 `$VAULT` 指代。
2. **建你自己的 roster**：框架内置一个 **5 人公开参考 starter**（[references/example-roster.md](references/example-roster.md)，⚠️ 示例非推荐）可即刻跑；但 roster 是你的情报网，建议尽快照 [references/account-roster.md](references/account-roster.md) 的方法论换成你自选的 8-15 个。
3. **接数据源**：本框架参考实现用 `mcp__followin__*`（推文 / 行情 / 卖方 / 信号）。这是**数据源适配层**——如果你用别的推文/行情 MCP，把对应调用替换即可，方法论不变。
4. **（可选）启用收尾门禁 hook**：见 [scripts/daily-gate-check.sh](scripts/daily-gate-check.sh)，把它配成 Stop hook 做机械落盘校验。

---

## 🅰️🅱️ 运行模式（两选一，每次开跑先确认）

本框架有两种模式，**价值和门槛完全不同，开跑前先定**：

| | 🅰️ 旗舰版（持久化 / vault） | 🅱️ 快速简报（无 vault / 单会话） |
|---|---|---|
| **产出** | 日报 + 标的/板块累积笔记 + 决策闭环 + 周报，全部落盘 | **只在对话里**出一份当日简报，不落任何文件 |
| **依赖** | Obsidian/Markdown vault + hook + 跨会话状态 | 只需 Claude + 数据源 MCP + 一份 roster |
| **价值** | 累积、可复盘、决策学习闭环——**几天/几周后复利** | 即开即用、一次看完——**单次就有用** |
| **适合** | 长期盯盘、想建自己的投研知识库 | 试用 / 偶尔扫一眼 / 没有 vault 的人 |
| **失去什么** | — | 跨日累积、thesis 健康度趋势、决策回顾、周报、归档（都需要历史） |

**怎么选**：
- 用户明确说"**快速简报 / 简报 / 不落盘 / quick brief / 试一下**" → 🅱️。
- 用户明确说"**完整版 / 落盘 / 跑日报 / 旗舰**" → 🅰️。
- **没说**：检查 `KOL_VAULT` 是否设置 —— 设了 → 默认 🅰️；没设 → 默认 🅱️，并一句话告诉用户"当前无 vault，走快速简报模式；想长期累积可配 vault 跑旗舰版"。

### 🅱️ 快速简报模式 — 怎么跑（精简流程）

**只跑这些**：Step 1（定窗口，无 `_last-pull` 则默认近 24h 或用户指定）→ Step 2（拉满 roster + 覆盖表）→ Step 3（窗口过滤，建议用 subagent）→ Step 3.5（顺手记 RT/QT 候选，仅在回复里提，不落盘）→ Step 4-6（识别投资内容 / 抓报价 / 共识主题）→ Step 6.5（板块识别）→ Step 7（每账号深度，按内容缩放）→ Step 9（综合判断）。

**直接在对话里输出一份简报**（不写文件），结构：
```
# 快速简报 — <窗口>
## 覆盖：N/N（✅/⚪/❌ 账号覆盖表）
## TLDR：1-3 条最重要
## 持仓信号（仅当用户当场报了持仓）：标的 / 本窗口信号 / posture
## 跨账号共识主题：每个带 @账号 + UTC + URL + verbatim 要点
## 板块强度速览
## 决策摘要（lite）：持仓 posture + 重点关注标的（带依据，不喊单）
## 每账号亮点：逐条干货（保留数字/术语/链接）
```

**🅱️ 模式跳过**：Step 0 的 vault 扫描、Step 5.6/5.6.5（除非用户当场喂实盘/卖方）、Step 10 全部落盘、Step 9.6 合并协议、Step 10.8 校准、Step 10.9 收尾门禁、Step 10.95 完整性审查、`_last-pull` 更新、周报、归档。

**🅱️ 模式仍然遵守（不可丢的纪律）**：
- ✅ **拉取覆盖门禁**（Step 2）——仍要列覆盖表，不许偷工只拉几个。
- ✅ **不编数字**——所有价位/数量带 [数据]/[原则] 来源。
- ✅ **数据带源**——每条带 UTC + 账号 + URL。
- ✅ **不替用户决定买卖**；用户表达买卖意图仍跑 Pre-Trade 5 项 gate（在对话里跑，不落盘）。
- ✅ 持仓信号需要用户**当场口头报持仓**（无 vault 读不到历史）。
- ⚠️ 明确告诉用户：**本次不落盘**，跨日累积/thesis 健康度趋势/决策回顾这些**拿不到**，要的话改跑 🅰️。

> 🅱️ 是把这套方法论降到"零配置可尝鲜"的入口；尝到价值想长期用，再升 🅰️。两者共用同一套提炼逻辑（Step 2-9），只在"落不落盘 + 校准/门禁"上分叉。

---

## 核心约束（必读）

### 1. 输出纪律

1. **MCP 路由**（参考实现用 followin，可换）：
   - **价格 / quote** → `mcp__followin__metrics(keywords=[...], categories=["market"])`
   - **目标价 / 评级 / 财报 / DCF** → `mcp__followin__metrics(keywords=[...], categories=["fundamentals"], verbosity="detail")`
   - **新闻 / 推文搜索** → `mcp__followin__news` / `mcp__followin__twitter`
   - **KOL 信号 / 实盘仓位** → `mcp__followin__signal`
2. **不替用户判断买卖**——所有 KOL 观点带原文链接和日期，让用户自己交叉验证。
   - ⚠️ **重大事件后必须等完整数据再分析**：财报 / 政策 / 黑天鹅后，第一次拉数据可能只是事件初期反应（如盘后初期价）。**强制规则**：重大事件后 1h 内主动再拉一次完整数据（含 day high/low/close 区间），不要 single snapshot 就下判断。双源交叉验证（metrics + WebSearch）。
3. **剥离废话**：段子、鸡汤、纯情绪、纯转发吐槽、商业推广——一律不入正文。判断不准时倾向剔除而非保留，宁缺毋滥。
4. **数据带源**：每条引用必须带 **UTC 时间戳 + 账号 + 原推 URL**，否则无法回头验证。

### 2. ⚠️ 策略不许编

每个具体数字（价格、数量、阈值、百分比）必须带 `[数据]` 或 `[原则]` 来源标签：

| ✅ 允许 | ❌ 禁止 |
|--------|--------|
| "回调到 50d MA $X [数据源] 建仓" | "回调到某价位建仓"（凭感觉的数）|
| "TRIM 比例使仓位回到 30% [集中度原则]" | "TRIM 2 股"（凭感觉的数）|
| "跌穿 52w 低 $X [数据]" | "跌一点才有 setup"（凭感觉打折）|

**没依据 = 不给数字**。只能给定性方向，或直接说"不知道，取决于你的风险承受能力 / 时间窗口 / 现金头寸"。

### 3. 落盘结构

```
$VAULT/
├── Daily/YYYY-MM-DD.md    <-- 日报
├── Daily/Daily-Index.md   <-- 日报 TLDR 索引（30 秒回查）
├── Portfolio.md           <-- 持仓 Dashboard 总览
├── Spotlight.md           <-- 决策视图单页（持仓+pending+板块 hot）
├── Orders.md              <-- 待执行 trigger + 已执行日志
├── Decisions-Journal.md   <-- 决策日志（含 1w/1m/3m 回顾）
├── Pre-Trade-Checklist.md <-- 买卖前 5 项 gate
├── Macro.md               <-- 宏观监控
├── Tickers/*.md           <-- 个股累积（活跃）
├── Tickers/Archive/*.md   <-- 归档（超 1 周无 KOL 提及）
├── Sectors/*.md           <-- 板块累积
├── Sectors/_Sectors-Index.md  <-- 全板块覆盖清单 manifest
├── Watchlist/Candidate-Roster.md  <-- RT/QT 网络发掘的候选账号
├── Weekly/YYYY-W##.md     <-- 周报
└── _last-pull.md          <-- 窗口状态（防断档）
```

**归档规则**（Tickers/Archive/）：roster KOL 过去 7 天 0 次提及该 ticker（topic level，不是文件 mtime）→ 归档。用户持仓 / Orders pending / 板块二阶标的**不归档**。任何 KOL 再提及 → 立即移回。每周末周报时 audit。

---

## 关注名册（Roster）

**框架只内置一个 5 人公开参考 starter（[references/example-roster.md](references/example-roster.md)，示例非推荐，开箱即跑）。** 长期名单你自己建——见 [references/account-roster.md](references/account-roster.md)（含建名单 / 信号质量分级 rubric / 画像深化方法 / 何时增删）。

跑流程时默认拉满整个 roster。用户说"加 XX / 去掉 YY / 今天只看英文圈"→ 本次运行调整，并询问是否更新 roster 文件（不主动改）。

**记录 roster 内的认知冲突对**（高信号）：同一标的有强多 vs 强空的两个账号 → 遇到必单独标注成对拉，不许只拉一边就给定调。

### （可选）信号分层

如果你有**多个层级**的信号源（如：自己付费订阅的顶级交易员 > 公开实盘仓位 > 普通推文 KOL），可建立分层权重——高层级信号可对冲低层级反方。**本框架不内置任何具体付费源**；如需，自行在此分层并标注来源。

---

## 时间窗口

**默认按用户本地自然日切分**（设你的时区）：

- 一份 `YYYY-MM-DD.md` 覆盖本地 0:00 → 24:00。
- 一天可多次拉取（晨/盘中/盘后），**都更新同一份日报**（见 Step 9.6 合并协议）。
- **窗口下界从 `_last-pull.md` 读，不手动估**（见 Step 1 / P3）。

**用户可调整**：「拉 12h」「最近一周」「最近 50 条」等明确指令按指令执行。**周末/节假日数据稀薄**，跑前提醒用户考虑放宽窗口或跳过。

---

## 📅 更新节奏分层（日维度 vs 周维度 vs 事件触发）— ⚠️ 别混

> roster 评级/画像是**周维度**（日频绝不动评级），但 Candidate-Roster 的"累积外部账号"是**日维度**——容易混。下表锁死节奏。

### 🟢 日维度（每次跑日报；前 7 个 hook 强制 mtime=当天）
`Daily/<date>.md` · **Spotlight.md · Daily-Index.md · Portfolio.md · Orders.md · Macro.md · _Sectors-Index.md · Watchlist/Candidate-Roster.md（这 7 个 hook 强制）** · 当天有信号的 `Sectors/*.md`+`Tickers/*.md` · `_last-pull.md` · `_coverage-ledger.md` · `Research/Read/`（当天有卖方变动才建）· coverage-audit BUILD 候选检测。
- ⚠️ Candidate-Roster 日维度 = **只累积 RT/QT 外部账号**，**不做升级判定**。

### 🔵 周维度（周末跑周报 Step 10.7；不要在日频做）
`Weekly/<W##>.md` · **`references-roster` 评级 review（⚠️ 日频绝不评/不升降）** · **画像深化（5 维）** · KOL 事件日志 · **Candidate-Roster 升级判定**（≥2 源 ≥3 次/7 天 → 提议入池）· **Ticker 归档 + Sector 归档执行**（平时 coverage-audit 只"提示候选"，执行在周末）· 决策质量复盘 · 基准对比。

### 🟠 事件触发
决策 1周/1月/3月回顾（到 prompt 日期）· 财报 · 用户买卖动作（即时更 Decisions-Journal/Portfolio/Tickers）。

> **自检铁律**：① 评级/画像出现在日频=错（周维度）；② 归档"执行"出现在日频=错（日频只提示候选）；③ hook 强制的文件必须全是日维度。

---

## 工作流（按顺序）

### Step 0.0 — 首次初始化（🅰️ 旗舰版首次运行必做）⚠️

> **为什么**：SKILL 引用十来个 vault 文件（Portfolio / Orders / Decisions-Journal / Pre-Trade-Checklist / Macro / Spotlight / Daily-Index / _Sectors-Index / _last-pull / Candidate-Roster / references-roster）。**首次运行它们都不存在**——若直接跑，① 决策闭环/门禁缺结构靠即兴发挥会漂移，② 收尾门禁 hook 会因这些文件 mtime 检测不到而第一天就 `exit 2` 拦死。

**触发**：🅰️ 模式下 `$KOL_VAULT/Portfolio.md` 不存在（或用户说"初始化 vault"）。

**做法**：
1. 建目录：`$KOL_VAULT/{Daily,Tickers,Tickers/Archive,Sectors,Sectors/Archive,Watchlist,Weekly,Research/Read}`。
2. 按 [references/vault-skeleton.md](references/vault-skeleton.md) 的种子结构创建那 12 个文件（空骨架即可，今日 mtime）。
3. 问用户：**持仓（标的/成本/数量）+ 现金口径（含货基/近现金）+ 关注名单 roster + 时区**，填进 `Portfolio.md` 和 `references-roster.md`。
4. `_last-pull.md` 的 `last_cutoff_utc` 设为"现在 − 24h"（首次无历史窗口）。
5. 初始化完成后再进 Step 0 正常流程。

**🅱️ 快速简报模式跳过本步**（不落盘，无需骨架）。

### Step 0 — 扫描持仓 + 板块上下文 + 决策回顾到期（每次必做）

```bash
# 0a. 扫持仓
grep -l "当前持仓" "$VAULT/Tickers/"*.md
# 0b. 扫已建板块
ls "$VAULT/Sectors/"*.md
# 0c. 决策回顾到期扫描
grep -E "1 周后回顾.*\(20[0-9]{2}-[0-9]{2}-[0-9]{2} prompt\)" "$VAULT/Decisions-Journal.md"
```

到期未填的回顾 → 在日报顶部加"📅 今日决策回顾提醒"（决策 # / 标的 / 当时 thesis / 当时价 / 现价 / 学习）。**不强制立刻填**，只提醒。

**P7 — 回顾必须反哺**：一旦某条回顾被填（用户给"对/错+为什么"），强制三连：① 更新 Decisions-Journal 该决策回顾字段 + 标 ✅对/❌错/⚪未定；② 若产生新教训 → 更新「决策模式归纳索引」；③ 若涉及"下次该先检查 X" → 写进 Pre-Trade-Checklist 对应 gate。

#### P1 — 仓位对账（每日 1 句 + 每周 1 次完整）⚠️

> **为什么**：Portfolio 的数量/成本**只来自用户口头告知**（多数人没接券商 API）。用户交易忘说 → 成本/数量错 → Risk Budget/浮盈/thesis 全链连锁错，且静默无告警。这是整条链的地基。
- **每次跑日报**：开头问一句"**持仓有变动吗？**"。
- **每周末**：贴完整持仓表让用户逐行确认（数量/成本）再算周度盈亏。
- ⚠️ **现金口径必须完整**：对账"现金"要含**货币基金 / 账户外现金 / 其他近现金**，不只交易账户余额。
- 🔴 **分母没核实 = 不报红线**：Risk Budget 是占比型指标，分母（总资产/现金）错则全错。base 存疑时只给定性方向 + 标"待确认总资产"，**禁止报具体 % 红线突破**。

### Step 1 — 确认参数 + 窗口状态（P3）

指令模糊（"跑一下 KOL"）→ 一句话确认窗口和名单。明确说"跑/开始/补一下/晚拉/按默认"→ 直接执行，不再问。

**P3 — 窗口下界从状态文件读**：
1. 读 `$VAULT/_last-pull.md` 的 `last_cutoff_utc` = 本次窗口下界。
2. 本次窗口 = `[last_cutoff_utc, now]`。
3. **断档检测**：`now - last_cutoff_utc > 36h` → 日报顶部标"⚠️ 断档 Nh，加大回溯窗口"，写 `gap_flag`。
4. 跑完 Step 11 **必更新** `_last-pull.md`：`last_cutoff_utc` = 本次 now + 追加历史行。

### Step 2 — 并行拉取推文（整个 roster）

**roster 从哪读**：🅰️ 模式从 `$KOL_VAULT/references-roster.md` 读名单；🅱️ 模式用用户当场给的名单。两种都不读 skill 自带的 `references/account-roster.md`（那是**方法论模板**，不是某人的真实名单）。

```
mcp__followin__twitter(action="user_tweets", user_name="<handle>", include_replies=false)
```

全部账号**并行调用**。返回 JSON 常超 token 限制被落盘到 tool-results。**正常现象，不要重试**。3 个以下账号失败 → 单独重试这几个，不要重试全部。

**P2 — 高价值账号拉回复**：把 roster 里**最高质量的几个 A+ 账号**用 `include_replies=true`（他们常在回复里给 alpha / 反方，主推抓不到）。其余维持 `false`（平衡噪音）。回复条标 `[reply]`，反方/数字优先。

#### 🚪 拉取覆盖门禁（⚠️ 强制）

> **为什么**：落盘门禁（Step 10.9）只保证"拉到的都写了"，保证不了"该拉的都拉了"。输入端的漏比落盘端更隐蔽——日报看起来完整，实际单边信息。

**硬规则**：
- **默认拉满整个 roster**，不许"挑几个核心账号"代替全量。除非用户明确说"只看 X"。
- 列一张**覆盖表**，每个账号显式标：✅ 已拉 / ⚪ 已拉但窗口内无信号 / ❌ 拉取失败。**不许有账号不出现在表里。**
- **来源可追溯**：引用某账号内容，该账号必须本次有实际 `user_tweets` 调用。禁止用"早先贴的/印象/跨会话记忆"冒充当日拉取；若用户手动喂的数据，明确标 `[用户提供，非当日拉取]`。
- **A+ 账号零容忍漏拉**。
- ⚠️ **search ≠ 拉取**：`twitter search` 只作补充验证，**绝不能替代 user_tweets 全量拉取**，也不能作为"无新信号"的唯一依据。原因：search 的 `$cashtag` 过滤对**不带 $ 标签的中文 KOL 系统性失效**。中文 KOL 必须 `user_tweets` 拉全文判断。
- ⚠️ **闭市/瘦窗口也要拉**：预期产出少 ≠ 不拉（亚洲时段 roster 仍在发推）。
- **认知冲突对必须成对拉**，不许只拉一边就给板块定调。

### Step 3 — 过滤时间窗口

用内联脚本（或 [scripts/filter_tweets.py](scripts/filter_tweets.py)）：自动按 `author.userName` 识别账号（并行调用顺序可能错位）→ 按 cutoff 过滤 → 区分"全天 / 增量段 / 已读旧内容" → 输出 markdown，每条带 UTC + 本地双时间戳 + RT/QT 标记。

> ⚠️ **大文件处理**：单个 user_tweets 返回常被落盘成超长单行文件。用 `python3 -c "print(open('FILE').read()[A:B])"` 按 ~80000 字符切片读完整。**强烈建议用 subagent 处理**（每个 subagent 读 1-3 个 dump 文件做提炼），让原始全文不进主上下文——按账号分组并行派发。

### Step 3.5 — 🕸️ RT/QT 网络扫描

从 roster 账号的 RT/QT 网络自动发掘候选账号：
```python
if tweet.retweetedTweet or tweet.quotedTweet:
    external = tweet.(retweeted|quoted)Tweet.author.userName
    if external not in roster:  # 排除 roster 自身互引
        累积到 Watchlist/Candidate-Roster.md（被谁引用 / 日期 / 主题 / 示例）
```
**升级 trigger**（周末 review 判断）：被 ≥2 roster KOL 引用 ≥3 次/7 天 → 提议加入；A+ 账号专门点名"alpha 贡献者" → 立即评估；连续 2 周 0 引用 → archive。
**排除**：已在 roster / 段子私人 / 与股票无关 / 默认头像 0 粉 / 机构官方账号。

### Step 4 — 识别投资内容

**保留**：`$TICKER` cashtag / 公司基本面·技术面·催化剂·估值 / 相关宏观（监管、降息、ETF）/ 供应链非美股标的（日韩台半导体、A 股）→ 后者作"延伸标的"放共识，不单独建 ticker。
**剔除**：段子 / 鸡汤 / 纯情绪 / 纯 retweet 无评论 / 商业推广 / 无关内容。

### Step 5 — 提取标的 + 抓报价

```
mcp__followin__metrics(keywords=["TICKER"], asset_type="tradfi", limit=1)
```
`asset_type="tradfi"` 必传；多 ticker 不要 batch（会被路由到 fundamentals），单调用并行。
记录：name / price / change% / MC / 52w 高低 / 50d-200d MA / DCF / consensus PT / analyst grades。

**⚠️ 持仓标的额外**：用 `categories=["market","fundamentals"]` + `query="<公司全名> analyst price target"` 调用（多类别 + 公司全名帮正确路由，解决同名 crypto token 误识别问题，如 LITE≠Litecoin、CRCL≠crypto），拿完整 PT 写入 Ticker 的「🎯 目标价追踪」段。误识别为 crypto 且无法纠正 → 标"暂无 PT 数据，待手动补"，**不要编 PT 数字**。

### Step 5.5 — 持仓标的特别处理

对 Step 0 持仓标的，**共识阈值降为 1**（单账号提及也保留）。逐条标注操作信号：

| 信号 | 触发 | 含义 |
|------|------|------|
| 🟢 加仓 setup | 新增独立账号验证 / 新催化剂 / 数据超预期 | 论点变厚 |
| 🟡 观察 | 接近 52w 高/关键阻力 / 共识拥挤 / 板块轮动 | 警觉 |
| 🟠 减仓 | 原 thesis KOL 止盈/转口风 / 反方独立账号入场 / 数据证伪 | 论点松动 |
| 🔴 止损 | 核心 thesis 破裂 / 基本面恶化 / 黑天鹅 | 论点崩溃 |

每个信号带：账号 / UTC / URL / 原话片段。**只摆信号，不做决策**。

### Step 5.6 —（可选扩展）实盘仓位源

> 本框架**不内置任何实盘/付费仓位源**。如果你有一个可信的实盘仓位数据流（如某交易员公开仓位、自建监控），可在此并入：把每个标的的方向×杠杆 / 仓位价值 / 开仓价 / 占保证金% 落到对应 Ticker 的「实盘持仓追踪」段。
> **关键陷阱（如接入）**：仓位快照的"价值"列 = 实时市值（shares × 当前价），**不是成本**。判断加仓/减仓**必须看事件流**（"仓位变动"事件），不能看快照"价值"列增减——价格跌时价值也跌，会误判成减仓。
> **同源警告**：若某实盘交易员同时也在你的推特 roster 里，**信号源计数只算 1 个**（不是两个独立背书）。
> **合规护栏**：实盘 ≠ 投资建议，只记录事实，不据此推荐操作。

### Step 5.6.5 — 卖方数据 ingest（持仓 + pending 标的）

对每个持仓 + Orders pending 标的跑 sell-side scan（观察池每周 1 次）：
- **A. 结构化评级 + consensus PT**：`metrics(keywords=[t], categories=["fundamentals"])` → ingest consensus high/low/median/avg + analyst_grades（最近 20 条）+ DCF + next earnings。
- **B. 重大 PT 变动新闻**：`news(query=f"{t} upgrade downgrade price target", time_range="1w")` → 过滤"raised/lowered PT / upgrade / downgrade / 具体美元数"+ 高质量源 → 写 Research/Read/。
- **避免噪音**：consensus 变动 >5% 才记；analyst_grades 新增 entry 才记；无变化仅更新 `last_sell_side_sync` 时间戳。
- **新 IPO（quiet period）**：标"暂无 sell-side coverage"，等首批 initiate 再跑。

### Step 6 — 提炼跨账号共识主题

找**≥2 个独立账号**讨论同一标的/主题。每个主题：时间正序列引用（UTC + 账号 + URL + 论点）+ 标直接论点 vs 间接论据 + 综合判断（共识强度 强/中/弱 + 风险点）。

### Step 6.5 — 板块识别

自下而上聚类板块。触发（任一）：≥2 KOL 讨论同一概念 / ≥3 只同类标的 ±5% 波动 / 当日板块级 catalyst。

**评级标准**：
- 🟢🟢 极强：龙头 +10%+ / 多源 KOL / 财报或政策 catalyst
- 🟢 强：龙头 +3-10% / ≥2 KOL 看多
- ⚪ 平：±3% 内 / 推文密度低
- 🔴 弱：龙头 -5%+ / 机构系统做空信号

固定追踪你关心的 N 个板块（自定义，如：存储 / 光通信-CPO / 半导体大盘 / 先进封装 / AI ASIC / 电源半导体…）。新主题浮现即时加入。维护 `Sectors/_Sectors-Index.md` manifest（见 Step 10.9）。

### Step 7 — 每账号深度（剥离废话版）⚠️ 强制逐条展开

**绝不允许"一句话画像总结"**。每个账号：
1. **画像（本期）**：1-2 句对比上次变化
2. **干货逐条**：用 1️⃣2️⃣3️⃣ 给每条有信息量的推文单独展开（标题/UTC/链接/bullet 要点/保留所有数字术语）
3. **跳过废话**：明确标"→ 跳过"
4. **信号质量**：A+/A/B+/B/B-/C+/C/D + 升降
5. **行动**：可跟进 item

**长度参考**：A+/A 级 800-2000 字；B+/B 级 400-1000 字；C 级 100-300 字。
（瘦窗口/周末按实际内容缩放，不必硬凑字数。）

### Step 8 — 跨主题时间轴

所有进入笔记的推文按 UTC + 本地时间排成表格。

### Step 9 — 综合判断

信号质量排序 / 新增观察池标的 / 多空交锋 / 板块强度 ranking。

### Step 9.6 — 🔁 日内多次拉取的合并协议（落盘前必读）⚠️ 强制

> **背景**：一天可能拉 2-3 次。若把"新信号"和"当前状态"混在一起 append，会叠成层层补丁、自相矛盾、章节错位。根因：状态和事件没分区。

**核心：日报分两区，两种合并动作。**

| 区 | 内容 | 每次拉取动作 |
|----|------|------------|
| **🟦 状态区（顶部）** | TLDR / 持仓快照（价/posture/健康度）/ 板块汇总 / 决策摘要 / Risk Budget | **OVERWRITE 到最新**——改成当前值，不保留旧值、不叠加 |
| **🟨 事件流区（底部）** | 信号事件按拉取批次分块 | **APPEND 新批次块**——旧块永不动，只追加本次净新增 |

**每次拉取的合并 7 步**：
1. 读 `_last-pull.md` 定窗口。
2. 拉数据（全量，Step 2 门禁）。
3. 事件流：append `### 批次#N — HH:MM` 块，只写本次净新增（与既有批次去重；旧块一字不动）。
4. 状态区：用最新数据 **OVERWRITE**（价/posture/健康度/Risk Budget/TLDR 全改当前值）。
5. **矛盾处理（关键）**：新数据推翻旧结论 → 状态区直接改成新结论（不留旧值），事件块记一行 `🔧 修正：X 从 A→B（原因）`。**绝不在状态区留两个互相矛盾的值。**
6. 更新「拉取批次」表 + 底部 footer + `_last-pull.md`。
7. 跑 Step 10.8 校准 + 10.9 门禁 + 10.95 完整性审查。

**铁律**：状态区只有"现在"没有"曾经"（历史演变留事件流 + Decisions-Journal）；同一信号只在首次批次写一次；事件流按批次时间 append，天然有序，**不需事后重排**。

### Step 10 — 落盘（3 层）

**A. 主日报** `$VAULT/Daily/YYYY-MM-DD.md`——按 [references/output-templates.md](references/output-templates.md) 模板（两区骨架 + 各 Part）。
**B. 每标的笔记** `Tickers/<TICKER>.md`——不存在则用 ticker 模板创建；存在则价格快照追加一行 + KOL 观点追加新日期小节 + **不动"我的仓位"段**。Frontmatter 必须有 `sector: [[Sectors/<板块>]]` 反链。
**C. 每板块笔记** `Sectors/<板块>.md`——见下方强制同步规则。

**板块文件强制同步**（满足任一必更新对应 Sectors 文件，不只是日报 Part 7）：① 当日板块汇总出现 ② 用户对该板块标的有买卖 ③ 实盘信号涉及 ④ 重大 KOL thesis/反方 ⑤ 代表标的财报/事件。
必更新段：强度评级历史表追加一行 / 累积 thesis 追加 / 代表标的价格 / KOL 提及历史 / 反方信号（不删旧）/ 用户暴露 / 周期阶段。
**检查方法**：跑完 `ls -la $VAULT/Sectors/*.md`，相关板块 mtime 非当天 = 漏了。

### Step 10.5 — 决策摘要（日报 Part 6）⚠️ 强制

**A. 持仓策略表**：标的 / 浮盈亏 / 多空源数 / Posture / 触发升级 / 触发降级 / 关键价位。
Posture（7 选 1）：🟢 ADD / HOLD-conviction｜🟡 HOLD-attention / TAKE-PROFIT-watch / HOLD-meme｜🟠 TRIM / RE-EVALUATE｜🔴 EXIT-watch。
**B. 重点关注标的（未持仓）**：2-3 个排序 + 排名理由 + 触发买入条件 + 与持仓关系。
**C. 跨标的协同 / 换仓建议（如有）**。
⚠️ **Posture / trigger / 触发价 / 数量全部必须带依据**。

### Step 10.6 — 板块汇总（日报 Part 7）⚠️ 强制

每板块带：当日强度 [🟢🟢/🟢/⚪/🔴 + 数据依据] / 关键催化（KOL 引用 + 数据点）/ 用户持仓连带（直接/间接/无）/ 反方信号。日报写当日快照，Sectors/ 累积跨日演变。

### Step 10.7 — 周末检测：周报 + Ticker 归档 audit

周六/周日 + `Weekly/YYYY-W##.md` 不存在 → 问"要不要跑本周周报？"。用户单独说"跑周报"→ 直接整合现有 daily 写周报。

**周报 12 节模板**：1 持仓演变 / 2 主题板块演变 / 3 KOL 行为 / 4 观察池演变 / 5 下周日历 / 6 周策略 / 7 **关注账号评级 review**（质量非胜率）/ 8 持仓总结+下周前瞻 / 9 **决策质量复盘**（P7：到期回顾对/错 + 模式命中，评用户决策非 KOL 胜率）/ 10 量化+没做的+开放循环 / 11 系统/流程健康度复盘（meta）/ 12 **基准对比**（组合 vs 大盘/行业 ETF 周涨跌 + 量化现金拖累）。
两个固定动作：① 第 9 节回顾必反哺模式索引 + Pre-Trade gate；② 每份周报开头先做 carry-over 检查（上周 open loops 是否关闭）。

**KOL 评级原则**：
- **日频不评准确率、不升降评级**——只记录事件 + 时间戳 + 标的 + 当时价格。
- **周度按"信号质量"复盘评级**（信号密度 / 独特 alpha / actionable 程度 / 可验证性噪音比 / 活跃度立场变化），**非"喊的票涨没涨"**。
- **画像深化**（5 维：独特 alpha / 风格 tell / 盲区打折项 / 最佳用法 / 关系网）每周精修，不需用户批；**评级变动 + 候选入 roster 需用户批**。

**Ticker 归档 audit**：过去 7 天 0 提及（非持仓/非 pending）→ 移 Tickers/Archive/。KOL 再提及 → 移回。⚠️ 以 `_coverage-ledger.md` last-seen 为准，别 grep 文件内日期（会被未来财报日期污染）。

**Sector 归档 audit（与 Ticker 对称）**：某 `Sectors/<X>.md` **连续 14 天 0 新硬信号且无持仓连带** → 移 `Sectors/Archive/`（建该文件夹 + README）；roster 再给硬信号 → 移回。平时 coverage-audit 的 Sector 段提示候选，**执行在周末**。Sector 此前只增不减，本规则补上折叠。

### Step 10.8 — 📐 衍生状态校准（强制）

每次跑日报最后做（落盘后、汇报前）：
1. **持仓现价 + 浮盈重算**（追加 Ticker 价格快照新行 + 更新 Portfolio）
2. **Orders pending triggers 重算**：trigger 引用 50d/200d MA / 52w 低 → 重拉；MA 变化 >5% 或现价距 trigger <3% → 主动提醒用户
3. **Portfolio Risk Budget 占比重算**（单标的/单板块/相关板块合计/低流动性/现金 ratio）→ 突破红线 → 警报进 Part 6
4. **Sectors 强度评级**：按当日走势 + KOL thesis + 反方重评，追加评级表
5. **Macro 红灯重检**（利率/VIX/DXY/行业 ETF）

**Spotlight.md 必更新**（决策单页）：A 持仓（现价+涨跌+Posture+距 trigger+**thesis 健康度**）/ B Orders pending trigger 距离 / C 你的分层信号源 / D 板块 hot / 关键事件倒计时 / 今日必做。
**Thesis 健康度算法**：① 过去 7 天 roster 主动多该标的的 KOL 数（≥3 🟢 / 1-2 🟡 / 0 🟠）② 实盘是否维持/撤（如有实盘源）③ 过去 7 天新增反方 KOL 数 → 综合 🟢强/🟡持平/🟠衰减/🔴反转/⚪无覆盖。
**Daily-Index.md 必追加一行 TLDR**（日期/关键事件/用户决策/价格关键节点）。

### Step 10.9 — 🚪 收尾门禁（落盘完整性校验）⚠️ 强制

> **为什么**：写完 Daily + dashboard 容易当成终点，漏掉 Sectors / ticker。本门禁把"逐文件确认"变成强制最后一步，用 mtime 实测代替"我以为写了"。

#### 🔍 10.9.0 — 覆盖审计（⚠️ 强制）— 修"该建没建 / 久未提没归档"根因
> 门禁只查"声明的文件动没动"（mtime），查不了 ① 该新建的没建（高频标的全靠人"注意到"）② 久未提的没归档。**机械补法**：跑 `scripts/coverage-audit.sh <今天 tool-results 目录>`：
> - **🆕 BUILD 候选**：≥5 文件提及（🔴 强）/3-4（🟡）、无 ticker 文件、非 crypto/大盘巨头 → agent **逐个判定：建档/仅记 Daily/噪音剔除（写理由）**，强候选未处置=门禁不算过。
> - **🗄️ ARCHIVE 候选**：读 `_coverage-ledger.md`，last-seen >14 天且非持仓/Orders。
> 跑完更新 `_coverage-ledger.md` 的 last-seen（日股/非 $cashtag 名脚本会漏判，手动补）。

跑完 Step 10 + 10.8 后，机械地逐项 `ls` mtime，凡当日有信号的文件 mtime 必须=当天：

| 类别 | 判定规则 |
|------|---------|
| 持仓 ticker | 有价格变动或新信号 → mtime=当天；确无 → 汇报里写明"X 无新信号故未改" |
| 在途 ticker（Orders pending）| 有新财报/卖方/异动 → 更新；否则跳过并说明 |
| **Sectors 全板块扫描** | **逐行过 `_Sectors-Index` 的固定板块 + 动态主题**，每行落 ✅已更新 / ⚪判定无信号 / 🆕有信号未到建档阈值 三态之一，不许沉默跳过。有信号的已建档板块 mtime=当天；未建档按建档标准判定。⚠️ **只改 `_Sectors-Index` 日期不算 sweep**。**日报底部写机器可读声明** `<!-- sector-sync: <更新的板块文件名，空格分隔> -->`（无更新写 `none`）——hook 解析它并逐个验证每个声明的 `Sectors/<X>.md` mtime=当天。|
| dashboard | Spotlight / Daily-Index / Portfolio / Macro 必更新 |
| roster 扩展 | 有新 RT/QT 外部账号 → 追加 Candidate-Roster |

**硬规则**：凡"漏掉" ≠ "判定无新信号"，每个持仓 ticker + 每个持仓相关 Sector 都必须被显式 touch 一次思考；mtime 实测优先于记忆；写不进时（如 iCloud dataless / EPERM）建桥接文件 `Tickers/_<标的>-待补-<日期>.md` 并标红"待补"。

**`_Sectors-Index.md` 建档标准**（明确可判，杜绝"漏建"和"建空壳"）：
- A. 用户暴露（持仓/Orders pending 有该板块标的）→ 必建
- B. 高优先级实仓源持有该板块标的 → 建
- C. 7 天内 ≥3 条**独立硬信号**（不同 KOL/实盘/卖方，同源不重复计）且覆盖 ≥2 标的 → 建
- 硬信号 = KOL 主动观点 / 实盘加减 / 卖方评级 PT 变动财报 / 政策并购内部人事件。**纯价格波动不算。**
- 不到阈值 → 只记 Daily + index 标注，不建空文件。连续 14 天 0 新硬信号且无持仓连带 → 归档。

### Step 10.95 — 🔬 完整性审查 pass（提炼校验）— 强制

> **背景**：门禁只查"文件碰没碰"，查不了"推文 dump 里每条材料是否都被提炼对、分到对的板块"。本 pass 补"提炼正确性"这层。

日报落盘后（门禁过后），**派 1 个 completeness-critic subagent**，给它：① 当天所有原始 tool-result dump 路径；② 当天落盘的 Daily + `_Sectors-Index` 信号列。

**subagent 任务**：反扫每个 dump，列窗口内每条相关材料信号（标的/事件/数字）→ 对照落盘文件 → 找出"在 dump 里但没进任何文件"的信号。特别查：① 非持仓板块信号（最易漏）② 反方信号（最易被乐观叙事盖掉）③ 被一句带过的数字。
加做：**P4 一致性校验**（同一事实在 Daily/Spotlight/Ticker/Sector 四处是否一致）；**P9 数字抽查**（随机抽 4-6 个落盘数字回 dump verbatim 比对）；**板块同步交叉校验**（日报标了新信号的板块其 `Sectors/<X>.md` mtime 必须=当天，hook 查不到这层需此处兜底）。
输出：遗漏清单 + 分类错误清单 + 不一致清单 + 数字错误清单。

**收尾**：遗漏非空 → 补落盘 + 再跑门禁；为空 → 汇报"完整性审查：0 遗漏"。**重大事件日尤其不能省。**

### Step 11 — 简短汇报

- 拉了 N 账号 / 过滤后 M 条
- 共识主题 X 个 / 涉及标的 Y 个 / 板块强度更新 Z 个
- **Step 10.9 门禁结果**：哪些已更新 / 哪些"判定无信号未改"（点名）/ 哪些"待补"（标红）
- 已落盘路径
- **1-3 个最值得立刻看的点**（最强信号 / 最大分歧 / 最有反向转向）

不要把全文复制到对话。

---

## 🛑 用户表达买卖意图时（Pre-Trade Checklist）⚠️ 强制

**触发**：用户说"我想加仓 X / 考虑止损 Y / X 现在能买吗 / 要不要 X / X 跌了能抄底吗"（**还没执行**）。

**必做**：先跑 [Pre-Trade-Checklist] 5 项 gate（① Macro 红灯数 ② 板块强度 vs 5 天前 ③ thesis KOL 是否仍多 + 实盘是否分离 ④ Risk Budget 红线 ⑤ 决策模式归纳 + 反向 prior 5 问）。每项给状态 + 颜色（🟢🟡🔴）+ 建议。
**绝不允许**：跳过 checklist 直接给"加仓 X 股"建议 / 替用户决定。
**允许**：列完整状态后让用户自己决定；用户坚持执行时记录"在 X 个 🔴 下仍执行"到 Decisions-Journal。

---

## 用户仓位变动追踪

用户告知买卖动作（"买了 X N 股 @ Y"），立即：
1. Tickers/<X>.md "我的仓位"表追加一行
2. Portfolio.md 持仓总表（股数/均价/浮盈）
3. 对应 Sectors/<板块>.md（用户暴露金额 / 强度评级 / thesis 或反方）
4. Decisions-Journal.md 新增决策 #N（含 1w/1m/3m 回顾 prompt）
5. Orders.md 已执行段
6. **不主动改用户 thesis**（除非用户明确说重写）

完成后跑 `ls -la $VAULT/Sectors/*.md` 确认相关板块文件当日更新过。

---

## 止损 policy 框架

用户问"X 给我个止损策略"——**不能编百分比**。可选 trigger 类型：
1. **技术位**：52w 低 / 关键 MA / IPO 以来低点 [数据]
2. **KOL 信号**：原 thesis KOL 撤回 / 转空 [数据]
3. **机构信号**：顶级交易员清仓 [数据]
4. **基本面信号**：财报 miss / 重大监管 [数据]
5. **板块同步性**：单独跌 + 板块未跟 = momentum 破位 / 板块同步跌 = 系统事件 [数据]

**多触发组合**：第一次破触发减半仓 / 第二次破触发全出 / thesis 大佬出局触发全出。落到 Tickers/<X>.md 形成 v1/v2/v3 累积版本。

---

## 容易踩的坑

- **"NOW" 是 ServiceNow 不是副词**——ticker 提取看上下文。
- **同一作者一天密集输出某标的（5+ 条）**——叙事可能完整但无 prior 验证，标"集中输出待验证"。
- **账号自己改口**——口风转变要单独标注。
- **分析师数据被多账号引用**——多方独立 vs 同源（看时间先后 + 首发）。
- **52w 高点附近**——KOL 共识强烈往往伴随 priced-in，风险段提醒。
- **中概股不是核心**——US-listed 但叙事属中国监管事件，定性分清。
- **IPO 新股技术分析不可用**——12 天 IPO 的 52w 低就是 IPO 以来低点，没"历史检验"过。
- **板块同步性 vs 个股独立波动**——标的单独跌 + 板块未跟 = momentum 破，比单看个股价格更有信息。

---

## 不做什么

- 不喊单。不出"买入/加仓/建议建仓多少%"结论。KOL 喊了就引用，自己不背书。
- 不预测价格。
- **不编数字**。所有具体价格/数量/阈值/百分比必须带 [数据] 或 [原则] 来源标签。
- 不替用户更新仓位表（除非用户告知）。
- 不删旧日报。
