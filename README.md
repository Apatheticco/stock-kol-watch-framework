<!-- 语言：中文 | English: README_EN.md -->
**语言 / Language**: 中文（本文） · [English](README_EN.md)

# Stock KOL Watch — 股票 KOL 观察日报框架

> **把你关注的一堆股票 KOL，变成一套每天自动产出的盯盘 + 决策辅助系统。**
> 一句"跑一下 KOL"，它就拉全你的关注名单、提炼成带原文链接的日报、更新每个标的和板块的累积笔记、盯你的持仓信号——**不喊单、不预测、不编数字，判断权永远在你手里。**

`Claude Code skill` · `方法论框架（已脱敏，可直接用）` · `双语 中文 / English`

---

## 痛点：你关注了 15 个 KOL，然后呢？

- 推文刷过去就忘了，**没人帮你把散落的信号沉淀成可查的笔记**
- KOL 今天喊多明天改口，**你记不清谁在什么价位说过什么**
- 想复盘"我上次为什么买"，**翻不到当时的依据**
- AI 帮你看盘，结果**它张口就编一个"回调到 $X 建仓"**——没有依据的数字最危险

这套框架把上面每一条都用**机制**堵住，而不是靠自觉。

---

## 它产出什么

把你**固定关注的一组股票 KOL 账号**的近 N 小时推文，转成一套结构化、可追溯、可复盘的决策辅助资料：

- **一份合并日报**（Daily/）—— 两区结构（状态区 OVERWRITE + 事件流区 APPEND），支持一天多次拉取无缝合并
- **每标的累积笔记**（Tickers/）—— 价格快照 + 目标价追踪 + KOL 观点 + 反方 + 你的仓位
- **每板块累积笔记**（Sectors/）—— 强度评级演变 + thesis + 反方信号
- **决策闭环**（Decisions-Journal / Pre-Trade-Checklist）—— 每个决策记录"为什么"+ 1w/1m/3m 回顾，反哺买卖前 gate
- **周报**（Weekly/）—— 12 节复盘，含基准对比 + 账号评级 review + 画像深化

> 这是一套**信息整理 + 决策辅助方法论**，**不是 signal generator，不喊单、不预测价格、不编数字**。判断权永远在你手里。

---

## 这是什么 / 不是什么

- ✅ 是：把散落的 KOL 信号**结构化 + 可追溯（每条带 UTC + 账号 + 原推 URL）+ 可复盘**的工作流；一套盯盘纪律。
- ❌ 不是：买卖建议、价格预测、自动交易。所有 KOL 观点只引用不背书。

## 为什么值得用

散户盯 KOL 最大的三个坑，这套框架用机制各堵一个：

1. **信息漏**（该拉的没拉全）→ Step 2 拉取覆盖门禁 + Step 10.95 完整性审查 critic
2. **落盘漏**（拉了没写全）→ Step 10.9 收尾门禁（hook 机械校验文件 mtime + 板块同步声明）
3. **不编数字**（凭感觉给价位）→ 全程"数字必带 [数据]/[原则] 来源"硬约束

外加一条多数人没有的：**决策回顾闭环**——每个买卖决策都留底 + 定期回看对错 + 反哺下次的 pre-trade checklist。

---

## 输出长什么样（示例片段，标的为虚构示意）

日报采用「状态区 + 事件流区」两区结构，一天多次拉取无缝合并：

```markdown
# 2026-XX-XX 日报
## 📍 拉取批次
| 批次 | 时间 | 窗口 | 覆盖 | 关键新增 |
| #1 | 09:19 | 15.4h | 8/8（7✅/1⚪）| 存储链多源共振 / $XXXX 盘前破位待确认 |

=== 🟦 状态区（OVERWRITE）===
## 1 持仓快照
| 标的 | 现价 | 浮盈 | 本窗口信号 | thesis 健康度 |
| $XXXX | $X | +25% | 🟢🟢 三家卖方上修 + 实盘双持 | 🟢 强 |
| $YYYY | $X | -3%  | 🟡 板块动能转弱（间接逆风）| 🟡 持平 |

=== 🟨 事件流区（APPEND 批次块）===
### 批次#1 — 09:19（窗口 ...）
#### 🟢🟢 存储超级周期（多源）
- @账号A 11:16Z：某投行上修 X 公司盈利预测 ...（带原推 URL）
- @账号B 14:51Z（卖方 NDR）：DRAM undersupply 延至 ...（verbatim 数字）
#### 🔴 反方
- @账号C 21:08Z："这条路线是个错误" ← roster 唯一空头声音
```

每个标的还有一份累积笔记（价格快照 / 目标价追踪 / KOL 观点历史 / 反方 / 你的仓位），每个板块一份强度演变笔记，决策有日志 + 1周/1月/3月回顾。

---

## 两种模式（用户自选）

| | 🅰️ 旗舰版（持久化 / vault） | 🅱️ 快速简报（无 vault / 单会话） |
|---|---|---|
| 产出 | 日报 + 标的/板块累积笔记 + 决策闭环 + 周报，全部落盘 | **只在对话里**出一份当日简报，不落文件 |
| 依赖 | vault + hook + 跨会话状态 | 只需 Claude + 数据源 MCP + 一份 roster |
| 价值 | 累积可复盘、决策学习闭环（几天/几周后复利） | 即开即用、零配置尝鲜（单次就有用） |

说"快速简报 / 试一下"走 🅱️；说"完整版 / 跑日报"走 🅰️；没说则看是否配了 `KOL_VAULT`（配了默认 🅰️，没配默认 🅱️）。两模式共用同一套提炼逻辑，只在"落不落盘"分叉。🅱️ 是零门槛入口，尝到价值再升 🅰️。

## 配置（首次使用必做）

1. **设 vault 路径**：
   ```bash
   export KOL_VAULT="/path/to/your/vault/Stock-Watch"
   ```
2. **建你的 roster**：**开箱即跑——内置 5 个高知名度公开参考账号 starter**（见 `references/example-roster.md`，⚠️ 示例非推荐/非投资建议），复制即可立刻跑。建议尽快按方法论（`references/account-roster.md`）替换/扩充成你自己的 8-15 个互补账号（**自带多空冲突，别全员看多**）。
3. **接数据源**：参考实现用 `mcp__followin__*`（推文/行情/卖方/信号）。换别的推文/行情 MCP 把对应调用替换即可，方法论不变。
4. **（可选）启用 hook**：把 `scripts/daily-gate-check.sh` 配成 Claude Code Stop hook，做机械落盘校验：
   ```json
   { "hooks": { "Stop": [ { "hooks": [ { "type": "command",
     "command": "bash ~/.claude/skills/stock-kol-watch/scripts/daily-gate-check.sh" } ] } ] } }
   ```

## 用法

把这个目录作为一个 Claude Code skill 装好后，对 Claude 说"跑一下 KOL / 拉最新数据"即可。它会按 `SKILL.md` 的工作流：扫持仓 → 定窗口 → 全量拉 roster → 提炼 → 落盘三层 → 校准 → 门禁 → 完整性审查 → 汇报。

## 目录

```
LICENSE                       MIT + 非投资建议声明
USER-GUIDE.md                 用户指南：怎么装、配什么、需要输入哪些信息、日常对话
SKILL.md                      工作流主文件（Step 0.0 初始化 → Step 11 + pre-trade + 止损框架）
references/
  account-roster.md           如何建/评/养你的关注名单（方法论模板）
  example-roster.md           起步 roster 模板（按角色配齐 + 怎么找账号）
  output-templates.md         日报 / 标的 / 板块 三份落盘模板
  vault-skeleton.md           首次初始化的 11 个种子文件结构
scripts/
  daily-gate-check.sh         收尾门禁 Stop hook（mtime + 板块同步机械校验）
  filter_tweets.py            把 raw 推文 dump 按时间窗过滤成 markdown
  pre-commit-privacy-scan.sh  提交前私有信息扫描（防个人路径/真实 handle/凭证泄露）
```

> 🔒 **维护本 repo（fork 后）**：装上 `scripts/pre-commit-privacy-scan.sh` 作 git pre-commit hook，
> 它会挡住任何含个人路径 / token / 私人邮箱的提交。你自己的真实关注名单 handle 写进本地
> `.privacy-patterns.local`（已 gitignore，**不进 repo**）——这样扫描能拦住它们，又不会把它们公开。
> 装法：`cp scripts/pre-commit-privacy-scan.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit`

## 设计来源 & 边界

- 本框架从一套实际运行的个人系统提炼而来，**已剔除私有信息**：无个人路径/用户名、不含完整私有名单与持仓金额（仅附 5 个公开账号示例 starter）、无任何付费/实盘群数据源。
- `references/account-roster.md` 是方法论模板；`references/example-roster.md` 附一个 **5 个公开账号的 starter**（⚠️ 示例非推荐，仅为开箱即跑）——长期名单你自己养。
- "实盘仓位源"是一个**可选扩展点**（SKILL Step 5.6），框架本身不内置任何来源；要接你自己接，并注意同源计数 / "价值列≠成本" 等陷阱（文中已标）。
- 数据源层默认 followin。**换源不是零成本**：需改 SKILL 里的 `mcp__followin__*` 调用（约 7 处）+ `filter_tweets.py` 的 `extract_tweets()` JSON schema；方法论（窗口/提炼/落盘/门禁）不变。

## License

**MIT**（见 [LICENSE](LICENSE)）。⚠️ 无任何投资建议属性——只整理第三方观点与公开数据，不构成买卖建议/价格预测，使用风险自负。
