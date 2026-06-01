#!/bin/bash
# stock-kol-watch 收尾门禁（机械强制）
# Stop hook 调用。今天跑过日报（Daily/<today>.md mtime=今天）则强制校验：
#   (1) dashboard + Orders + manifest mtime=今天
#   (2) 日报含"账号覆盖表"+"完整性审查"标记
#   (3) 日报含 <!-- sector-sync: A B C --> 声明，且声明的每个 Sectors/<X>.md mtime=今天
# 退出码 2 = 阻止 stop 并把 stderr 反馈给模型。非日报会话静默 exit 0。
#
# 配置：设环境变量 KOL_VAULT 指向你的 vault 根（含 Daily/ Sectors/ 等子目录）。
#   export KOL_VAULT="/path/to/your/vault/Stock-Watch"

VAULT="${KOL_VAULT:?请先 export KOL_VAULT=/path/to/your/vault}"
TODAY=$(date +%Y-%m-%d)
# 跨平台 mtime → YYYY-MM-DD：先试 BSD/macOS，失败回退 GNU/Linux
mday() {
  stat -f "%Sm" -t "%Y-%m-%d" "$1" 2>/dev/null && return 0
  stat -c "%y" "$1" 2>/dev/null | cut -d' ' -f1
}

DAILY="$VAULT/Daily/$TODAY.md"
[ -f "$DAILY" ] || exit 0
[ "$(mday "$DAILY")" = "$TODAY" ] || exit 0

MISS=()

# (1) 每次日报必更新的文件 mtime=今天
for f in "Spotlight.md" "Daily/Daily-Index.md" "Sectors/_Sectors-Index.md" "Portfolio.md" "Orders.md"; do
  [ "$(mday "$VAULT/$f")" = "$TODAY" ] || MISS+=("mtime过期: $f")
done

# (2) 日报内容标记
grep -q "账号覆盖表" "$DAILY" 2>/dev/null || MISS+=("缺标记: 日报无『账号覆盖表』(Step 2 拉取覆盖未落)")
grep -q "完整性审查" "$DAILY" 2>/dev/null || MISS+=("缺标记: 日报无『完整性审查』(Step 10.95 未落)")

# (3) 板块同步声明
SYNC_LINE=$(grep -oE '<!-- sector-sync:[^>]*-->' "$DAILY" 2>/dev/null | head -1)
if [ -z "$SYNC_LINE" ]; then
  MISS+=("缺声明: 日报无 <!-- sector-sync: ... --> (改 _Sectors-Index 日期≠sweep)")
else
  SECTORS=$(printf '%s' "$SYNC_LINE" | sed -E 's/<!-- sector-sync: *//; s/ *-->//')
  for s in $SECTORS; do
    [ "$s" = "none" ] && continue
    sf="$VAULT/Sectors/$s.md"
    if [ ! -f "$sf" ]; then
      MISS+=("sector-sync 声明的 $s.md 不存在")
    elif [ "$(mday "$sf")" != "$TODAY" ]; then
      MISS+=("sector-sync 声明了 $s 但 Sectors/$s.md 今天没更新（只改日期≠sweep）")
    fi
  done
fi

if [ ${#MISS[@]} -gt 0 ]; then
  echo "🚪 stock-kol-watch 收尾门禁未通过：今天跑了日报（Daily/$TODAY.md），但：" >&2
  for m in "${MISS[@]}"; do echo "  ❌ $m" >&2; done
  echo "请补齐再结束。详见 SKILL Step 10.9 / 10.95。" >&2
  exit 2
fi
exit 0
