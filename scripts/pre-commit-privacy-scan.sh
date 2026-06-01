#!/bin/bash
# 私有信息 pre-commit 扫描 — 挡住含个人路径/凭证/真实 handle 的提交。
# 这是 PUBLIC repo：提交前机械检查 staged 新增内容，命中即拦下（exit 1）。
#
# 安装：
#   cp scripts/pre-commit-privacy-scan.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
#
# ⚠️ 重要：本文件是公开的，所以**不要**把你的真实 handle / 用户名写进这里
#（那等于把要藏的东西公开列出来）。通用 pattern 写在下面 GENERIC；
# 你自己的私有 token（真实关注名单 handle、用户名、路径片段）写进本地
# `.privacy-patterns.local`（已被 .gitignore 忽略，不会进 repo），每行一个正则。

set -u
REPO_ROOT=$(git rev-parse --show-toplevel)

# 通用结构 pattern（不含任何真实 handle，可安全公开）：绝对家目录路径 / iCloud / TG / token / 私人邮箱
GENERIC='/Users/[a-z]|/home/[a-z]|Mobile Documents|tg-pipeline|messages\.db|gho_[A-Za-z0-9]|ghp_[A-Za-z0-9]|github_pat_|AKIA[0-9A-Z]{12}|-----BEGIN [A-Z ]*PRIVATE KEY-----|[A-Za-z0-9._%+-]+@(gmail|outlook|qq|163|foxmail)\.com'

# 本地私有 pattern（gitignored，逐行正则）。你的真实 handle 放这里。
LOCAL_FILE="$REPO_ROOT/.privacy-patterns.local"
PATTERNS="$GENERIC"
if [ -f "$LOCAL_FILE" ]; then
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    case "$line" in \#*) continue ;; esac
    PATTERNS="$PATTERNS|$line"
  done < "$LOCAL_FILE"
fi

# 不扫的文件：本扫描脚本自身（含 pattern 字面量）+ 本地 pattern 文件
SKIP='scripts/pre-commit-privacy-scan.sh'

STAGED=$(git diff --cached --name-only --diff-filter=ACM)
[ -z "$STAGED" ] && exit 0

HITS=""
while IFS= read -r f; do
  [ -f "$f" ] || continue
  [ "$f" = "$SKIP" ] && continue
  MATCH=$(git diff --cached -U0 -- "$f" | grep -E '^\+' | grep -vE '^\+\+\+' | grep -inE "$PATTERNS")
  if [ -n "$MATCH" ]; then
    HITS="${HITS}\n--- $f ---\n${MATCH}"
  fi
done <<< "$STAGED"

if [ -n "$HITS" ]; then
  echo "🛑 pre-commit 私有信息扫描未通过——以下 staged 新增内容命中私有 pattern：" >&2
  printf "%b\n" "$HITS" >&2
  echo "" >&2
  echo "这是 PUBLIC repo。删除/脱敏后再提交；确认误报可用 'git commit --no-verify' 跳过。" >&2
  exit 1
fi
exit 0
