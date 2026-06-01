<!-- 语言：中文 | English: USER-GUIDE_EN.md -->
**语言 / Language**: 中文（本文） · [English](USER-GUIDE_EN.md)

# 用户指南 — Stock KOL Watch 怎么用

这份指南讲**人怎么上手**：装什么、配什么、**需要你输入哪些信息**、日常怎么对话。
（`README.md` = 框架概览；`SKILL.md` = 给 AI 看的工作流规范；本文件 = 给你看的操作手册。）

---

## 0. 一句话理解

你养一份"关注的股票 KOL 名单"，每天对 Claude 说一句"跑一下 KOL"，它就把这些账号的新推文拉下来、提炼成日报、更新每个标的和板块的累积笔记、盯你的持仓信号、并把所有结论落进你的 Obsidian（或任意 Markdown）笔记库——**带原文链接可追溯，不替你做买卖决定**。

---

## 两种模式（开跑前先选）

- 🅰️ **旗舰版（持久化）**：落盘日报 + 累积笔记 + 决策闭环 + 周报，价值随时间复利。需要 vault。
- 🅱️ **快速简报（无 vault）**：只在对话里出一份当日简报，零配置，单次就有用——适合试用 / 偶尔扫一眼。

怎么触发：说"**快速简报 / 试一下**"走 🅱️；说"**完整版 / 跑日报**"走 🅰️；没说就看你配没配 `KOL_VAULT`（配了默认 🅰️，没配默认 🅱️）。🅱️ 模式下持仓信号需要你**当场口头报持仓**（无 vault 读不到历史），且跨日累积/决策回顾拿不到——要长期用就升 🅰️。下面的安装/配置主要针对 🅰️；只想跑 🅱️ 的话，跳过 vault，配好数据源 MCP + 给一份 roster 即可。

## 1. 前置条件

| 需要 | 说明 |
|------|------|
| **Claude Code** | 本框架是一个 Claude Code skill |
| **一个 Markdown 笔记库** | 推荐 Obsidian vault；普通文件夹也行。结果都落这里 |
| **一个推文 + 行情数据源（MCP）** | 参考实现用 `followin` MCP（推文/行情/卖方/信号）。用别的也行，替换对应调用即可 |
| **（可选）Stop hook 权限** | 启用机械落盘门禁需要能配 Claude Code hook |

---

## 2. 安装

把整个 `stock-kol-watch-framework/` 目录放进你的 skills 目录：

```bash
cp -r stock-kol-watch-framework ~/.claude/skills/stock-kol-watch
```

（或作为 plugin 分发。skill 名取 `SKILL.md` frontmatter 里的 `name`。）

---

## 3. 配置（首次必做，约 10 分钟）

### 3.1 设 vault 路径
```bash
export KOL_VAULT="/path/to/your/vault/Stock-Watch"
```
建议写进 `~/.zshrc` / `~/.bashrc` 持久化。所有文档都落在它下面。

### 3.2 启用收尾门禁 hook（可选但强烈推荐）
在 `~/.claude/settings.json` 加：
```json
{ "hooks": { "Stop": [ { "hooks": [ { "type": "command",
  "command": "bash ~/.claude/skills/stock-kol-watch/scripts/daily-gate-check.sh",
  "timeout": 15 } ] } ] } }
```
作用：你每次跑完日报想结束时，hook 机械检查"该更新的文件是否都更新了"，没写全会拦住——把"我以为写了"变成"系统不让我糊弄"。

### 3.3 关注名单（已内置 5 个，可直接跑）
**`references/example-roster.md` 里已内置 5 个高知名度公开账号的 starter，开箱即用**（⚠️ 示例非推荐/非投资建议）：

| 角色 | 账号 |
|------|------|
| 供应链/存储 | @jukan05 |
| AI/半导体供应链 | @aleabitoreddit（Serenity）|
| 半导体/光·事件 | @nft_hu |
| 存储叙事/港美 | @xiaomustock |
| 宏观/跨资产 | @qinbafrank |

- **想立刻跑**：🅰️ 把这 5 个复制到 `$KOL_VAULT/references-roster.md`；🅱️ 直接把这 5 个告诉 Claude——即可出第一份简报。
- **想长期用**：按 `references/account-roster.md` 的方法论换成你自己的 8-15 个。⚠️ **这 5 个偏半导体、没唱空账号——正式用前务必补一个唱空/质疑账号**（别全员看多）。

选人原则（扩充时参考）：覆盖你关心的几条主线 / 视角多样（分析师·交易员·卖方·宏观）/ 至少 1-2 个稳定唱空。

选人原则（详见 roster 模板）：
- 覆盖你关心的几条主线（如存储、光通信、电源半导体…）
- **视角多样**：分析师 / 交易员 / 卖方聚合 / 宏观，各来一两个
- ⚠️ **至少留 1-2 个稳定唱空/质疑的硬声音**——别让名单变成全员看多（最危险的盲区）

---

## 4. ⚠️ 你需要给的信息（就 3 样）

| 信息 | 例子 |
|------|------|
| **持仓**（标的/成本/数量）| "我持有 $AAAA 10 股 @ $50" |
| **现金**（⚠️ 含货基/近现金）| "现金 $X + 货基 $Y" |
| **成交就报一句**（持仓准确性命脉）| "我买了 $CCCC 20 股 @ $30" |

> 其余不用操心：**关注名单**已内置 5 个 starter（想换再说）；**时区/窗口**有默认；**数据源**装 MCP 时配一次；thesis 可选。

**两条铁律**：① 持仓/成本只来自你口头告知（不接券商）——**成交忘说 → 浮盈/占比/thesis 全链静默错**；② 现金报全口径（含货基），否则它拒绝算 Risk Budget（不编分母）。

---

## 5. 第一次跑（冷启动）

新 vault 是空的。第一次直接说：

> **"初始化一下 vault，然后跑一下 KOL"**

Claude 会（对应 SKILL 的 **Step 0.0 首次初始化**，仅 🅰️ 旗舰版需要）：
1. 按 `references/vault-skeleton.md` 建目录骨架（Daily/ Tickers/ Sectors/ Watchlist/ Weekly/）+ **11 个种子文件**：references-roster / Portfolio / Orders / Decisions-Journal / Pre-Trade-Checklist / Macro / Spotlight / Daily-Index / _Sectors-Index / _last-pull / Candidate-Roster
2. 问你持仓、现金、时区（关注名单可先用**内置的 5 个 starter**，想换再说）
3. 拉一遍 roster，产出第一份日报

之后日常就只需要一句"跑一下 KOL"。（🅱️ 快速简报模式无需初始化，跳过本步。）

---

## 6. 日常怎么对话（常用指令）

| 你说 | 它做 |
|------|------|
| **"跑一下 KOL" / "拉最新数据"** | 全量拉 roster → 日报 → 更新标的/板块 → 校准 → 门禁 → 汇报 3 个最该看的点 |
| **"补一下昨晚的" / "晚拉"** | 从上次窗口增量拉，**合并**进当日同一份日报（两区协议） |
| **"我买了/卖了 X N 股 @ Y"** | 更新 Tickers + Portfolio + Sectors + Decisions-Journal + Orders（自动） |
| **"X 现在能买吗 / 要不要加仓 X"** | 先跑 5 项 Pre-Trade gate（Macro/板块/thesis/Risk Budget/反向 prior），列状态让你自己定，**不替你决定** |
| **"X 给我个止损策略"** | 给 4-5 个**有依据**的 trigger 候选（技术位/KOL/机构/基本面/板块同步），让你选 |
| **"X 账号的逻辑展开说说"** | 读日报 Part 2 对应账号段 |
| **"给我看 X 的所有观点"** | 读 `Tickers/X.md` |
| **"X 板块怎么演变"** | 读 `Sectors/X.md` 强度评级表 |
| **"跑周报" / 周末跑日报时** | 12 节周报（持仓演变/板块/KOL 评级 review/决策质量复盘/基准对比…）|
| **"加一个 @XX / 去掉 @YY"** | 本次调整名单，并问是否更新 roster 文件 |

---

## 7. 输出在哪看

| 想看 | 打开 |
|------|------|
| 今天发生了什么 | `Daily/YYYY-MM-DD.md` |
| 30 秒回查过去几天 | `Daily/Daily-Index.md` |
| 我的持仓全景 | `Portfolio.md` |
| 一页式决策视图 | `Spotlight.md`（持仓+pending+板块 hot+今日必做）|
| 某只票的全部历史 | `Tickers/<TICKER>.md` |
| 某板块怎么演变 | `Sectors/<板块>.md` |
| 我的每个决策 + 回顾 | `Decisions-Journal.md` |
| 本周复盘 | `Weekly/YYYY-W##.md` |

---

## 8. 常见问题

**Q：它会帮我下单 / 喊单吗？**
不会。它只整理信息、摆信号、跑 pre-trade gate。买卖永远你自己决定、自己操作。

**Q：KOL 喊的票它会说"准不准"吗？**
日频不评胜率，只记录事件 + 时间 + 当时价。周度按"信号质量"复盘评级（不是看票涨没涨）。评级变动要你确认。

**Q：为什么它有时拒绝给具体价位/百分比？**
"不编数字"是硬约束。没有数据或原则支撑的数字它不给，只给定性方向——这是特性不是 bug。

**Q：数据拉不全 / 漏了账号怎么办？**
框架有两道机制兜底：拉取覆盖门禁（强制列全名单覆盖表）+ 完整性审查 critic（反扫原始推文找遗漏）。但**输入端靠你**——名单是你定的，持仓是你报的。

**Q：能不接 followin、用别的数据源吗？**
能。followin 是数据源适配层，把 SKILL.md 里的 `mcp__followin__*` 调用替换成你的推文/行情 MCP 即可，方法论不变。

**Q：实盘仓位监控呢？**
框架不内置任何实盘/付费源（已脱敏）。SKILL Step 5.6 留了通用扩展点——你有可信的实盘数据流可自行接入，注意"价值列≠成本""同源计 1 个"等陷阱。

---

## 9. 一句话上手清单

1. `export KOL_VAULT=...`
2. 配 hook（可选）
3. 告诉 Claude 你的持仓 + 现金（含货基）；关注名单可先用**内置的 5 个 starter**
4. 说"初始化 vault 并跑一下 KOL"
5. 以后每天一句"跑一下 KOL"；成交了就说一句"我买了/卖了…"
