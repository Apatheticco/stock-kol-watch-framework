#!/bin/bash
# Ticker/Sector 覆盖审计 — 机械检测"该建没建 / 久未提该归档"
# 解决根因：收尾门禁只查"声明的文件动没动"，查不了"该有的文件存不存在"。创建+长尾管理会系统性漏。
# 用法：coverage-audit.sh <tool-results 目录> [vault]
#   每次跑日报 Step 10.9 调用；输出 BUILD / ARCHIVE 候选清单，agent 必须逐条处置。
# 兼容 macOS bash 3.2（不用 declare -A）。

VAULT="${2:-$KOL_VAULT}"
[ -z "$VAULT" ] && { echo "用法: coverage-audit.sh <tool-results目录> <vault>  或先 export KOL_VAULT"; exit 1; }
DUMPDIR="${1:?用法: coverage-audit.sh <tool-results目录> [vault]}"
TICKDIR="$VAULT/Tickers"
LEDGER="$VAULT/_coverage-ledger.md"
TODAY=$(date +%Y-%m-%d)
CUT=$(date -v-14d +%Y-%m-%d 2>/dev/null || date -d '14 days ago' +%Y-%m-%d)
# 排除：crypto/术语缩写噪音
EXCLUDE='^(BTC|ETH|SOL|H|USD|USDT|AI|US|IV|PE|EPS|GW|TAM|ARR|CPU|GPU|HBM|DRAM|NAND|CPO|ASIC|LRO|ODM|OEM|SPV)$'
# 排除：大盘巨头/指数级标的（属"市场背景"，记 Macro/Daily，不单独建 ticker 除非用户持有）
MEGACAP='^(NVDA|AMD|INTC|MSFT|AMZN|META|GOOG|GOOGL|TSM|AVGO|ARM|ORCL|TSLA|IBM|QCOM|AAPL|SNOW|PLTR|SHOP|HOOD|APP|SMCI)$'

echo "=== Ticker/Sector 覆盖审计 ($TODAY) ==="
FILES=$(find "$DUMPDIR" -name 'mcp-followin-twitter-*.txt' -mtime -1 2>/dev/null)
[ -z "$FILES" ] && { echo "⚠️ 今天无 dump 文件"; exit 0; }
echo "今天 dump 文件: $(echo "$FILES" | wc -l | tr -d ' ') 个"; echo ""

# 受保护标的（持仓 + Orders）——从 Portfolio 持仓表 + Orders 动态读，不硬编码
PROTECT=$(grep -oE '\[\[[A-Z0-9]{2,8}\]\]' "$VAULT/Portfolio.md" "$VAULT/Orders.md" 2>/dev/null | tr -d '[]' | sort -u | tr '\n' '|' | sed 's/|$//')
[ -z "$PROTECT" ] && PROTECT="__none__"

TAGCOUNT=$(for f in $FILES; do grep -ohE '\$[A-Z]{2,5}\b' "$f" 2>/dev/null | tr -d '$' | sort -u; done | sort | uniq -c | sort -rn)

echo "## 🆕 BUILD 候选（无 Ticker 文件 + 非 crypto/大盘巨头）"
echo "  🔴 强候选（≥5 文件提及，优先评估建档）："
echo "$TAGCOUNT" | while read -r cnt tag; do
  [ -z "$tag" ] && continue; [ "$cnt" -lt 5 ] && continue
  echo "$tag" | grep -qE "$EXCLUDE|$MEGACAP" && continue
  { [ -f "$TICKDIR/$tag.md" ] || [ -f "$TICKDIR/Archive/$tag.md" ]; } && continue
  echo "    - \$$tag（$cnt 文件）"
done
echo "  🟡 观察（3-4 文件，记 Daily，连续多日再建）："
echo "$TAGCOUNT" | while read -r cnt tag; do
  [ -z "$tag" ] && continue; { [ "$cnt" -lt 3 ] || [ "$cnt" -ge 5 ]; } && continue
  echo "$tag" | grep -qE "$EXCLUDE|$MEGACAP" && continue
  { [ -f "$TICKDIR/$tag.md" ] || [ -f "$TICKDIR/Archive/$tag.md" ]; } && continue
  printf '%s ' "\$$tag($cnt)"
done; echo
echo "  ⚠️ 大盘巨头即便高频也不单独建档——记 Daily/Macro。agent 逐个判定强候选。"
echo ""

echo "## 🗄️ ARCHIVE 候选（Ticker：ledger 最后信号 > 14 天且非持仓/Orders）"
if [ -f "$LEDGER" ]; then
  grep -E '^\| *[A-Z]' "$LEDGER" 2>/dev/null | while IFS='|' read -r _ name last rest; do
    name=$(echo "$name" | tr -d ' '); last=$(echo "$last" | tr -d ' ')
    echo "$name" | grep -qE "^($PROTECT)$" && continue
    [[ "$last" < "$CUT" ]] && echo "  - $name（最后信号 $last < $CUT）→ 评估移 Tickers/Archive/"
  done
else
  echo "  ⚠️ ledger 不存在（$LEDGER）；首次跑用本次 dump 给现有 Tickers 记 last-seen。"
fi
echo ""
echo "## 🗄️ Sector ARCHIVE 检查"
echo "  对每个 Sectors/*.md 看强度评级表最新日期；> 14 天 且无持仓连带 → 移 Sectors/Archive/"
for s in "$VAULT/Sectors/"*.md; do
  [ "$(basename "$s")" = "_Sectors-Index.md" ] && continue
  d=$(grep -oE '20[0-9]{2}-[0-9]{2}-[0-9]{2}' "$s" 2>/dev/null | sort | tail -1)
  echo "  - $(basename "$s" .md): 文件内最新日期 $d"
done
echo ""
echo "=== 处置后更新 _coverage-ledger.md ==="
