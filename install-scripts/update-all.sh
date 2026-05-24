#!/usr/bin/env bash
# update-all.sh — 取り込み済みの外部スキルを最新化する。
# 各 _external リポジトリで git pull、その後 install.sh --skills-only を再実行して
# 欠けているものを補完する。

set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
SKILLS_ROOT=".claude/skills"

UPDATED=0
echo "== 既存の外部スキルを更新 =="
while IFS= read -r gitdir; do
  repo_dir="$(dirname "$gitdir")"
  echo "→ $repo_dir"
  if ( cd "$repo_dir" && git pull --ff-only >/dev/null 2>&1 ); then
    UPDATED=$((UPDATED+1))
  else
    echo "  ⚠️  更新できませんでした(手動確認を推奨): $repo_dir" >&2
  fi
done < <(find "$SKILLS_ROOT" -type d -path '*/_external/*' -name '.git' 2>/dev/null)

echo "更新: $UPDATED 件"
echo
echo "== 不足分の補完(install.sh --skills-only)=="
exec bash "$ROOT/install-scripts/install.sh" --skills-only
