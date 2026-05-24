#!/usr/bin/env bash
# install.sh — 外部スキルの取り込み + MCP 登録(全部入り)
#
# 使い方:
#   bash install-scripts/install.sh            # 全部入り(デフォルト)
#   bash install-scripts/install.sh --all
#   bash install-scripts/install.sh --skills-only
#   bash install-scripts/install.sh --mcp-only
#
# 方針:
#   - 最初に claude-skill-antivirus を導入し、以降のスキルは取り込み前にスキャンする。
#   - clone は --depth 1 --filter=blob:none を使い軽量化。サブパス指定時は sparse-checkout。
#   - 取り込み先は .claude/skills/<category>/_external/<repo> に隔離する。
#   - スキャンで Critical を検出したら停止して確認する。
#   - 実在を確認できないリポ/パスは skip + 警告(捏造しない)。
#   - 末尾に「導入 N 件 / skip M 件 / warning L 件」のサマリを出す。

set -uo pipefail

MODE="all"
case "${1:-}" in
  --skills-only) MODE="skills" ;;
  --mcp-only)    MODE="mcp" ;;
  --all|"")      MODE="all" ;;
  *) echo "不明な引数: $1"; echo "usage: install.sh [--all|--skills-only|--mcp-only]"; exit 1 ;;
esac

# リポジトリルートを基準にする
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
SKILLS_ROOT=".claude/skills"
ANTIVIRUS_DIR="$SKILLS_ROOT/_external/claude-skill-antivirus"

INSTALLED=0; SKIPPED=0; WARNINGS=0

info()  { echo "ℹ️  $*"; }
warn()  { WARNINGS=$((WARNINGS+1)); echo "⚠️  $*" >&2; }
skipit(){ SKIPPED=$((SKIPPED+1)); echo "⏭️  skip: $*"; }

# リモートに存在するか(認証不要・軽量)
repo_exists() { git ls-remote "https://github.com/$1.git" >/dev/null 2>&1; }

# 軽量 clone。第3引数以降があれば sparse-checkout。
clone_repo() {
  local repo="$1" dest="$2"; shift 2
  rm -rf "$dest"; mkdir -p "$(dirname "$dest")"
  if [ "$#" -ge 1 ]; then
    git clone --depth 1 --filter=blob:none --sparse "https://github.com/$repo.git" "$dest" >/dev/null 2>&1 || return 1
    ( cd "$dest" && git sparse-checkout set "$@" >/dev/null 2>&1 ) || return 1
  else
    git clone --depth 1 --filter=blob:none "https://github.com/$repo.git" "$dest" >/dev/null 2>&1 || return 1
  fi
  return 0
}

# 組み込みヒューリスティックスキャン(antivirus の正確な CLI に依存しないフォールバック)。
# echo で CRITICAL / WARN / CLEAN のいずれかを返す。
builtin_scan() {
  local dir="$1" crit=0 warnc=0
  # 明らかに危険: ダウンロードして即実行 / 破壊 / 難読化実行
  if grep -REl --include='*.sh' --include='*.js' --include='*.ts' --include='*.py' \
      -e '(curl|wget)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(sh|bash|zsh)' \
      -e 'rm[[:space:]]+-rf[[:space:]]+/(\*|[[:space:]]|$)' \
      -e 'eval[[:space:]]*\([[:space:]]*(atob|Buffer\.from|base64)' \
      "$dir" >/dev/null 2>&1; then
    crit=1
  fi
  # 要注意: 外部送信らしき記述 / 環境変数の収集
  if grep -REl --include='*.sh' --include='*.js' --include='*.ts' --include='*.py' \
      -e 'process\.env[^=]*\)[^;]*fetch\(' \
      -e 'base64[[:space:]-]*d' \
      "$dir" >/dev/null 2>&1; then
    warnc=1
  fi
  if [ "$crit" -eq 1 ]; then echo "CRITICAL"; elif [ "$warnc" -eq 1 ]; then echo "WARN"; else echo "CLEAN"; fi
}

# antivirus 用スクリプトがあれば使い、無ければ builtin。
scan_dir() {
  local dir="$1"
  # 既知のエントリポイントを探索(無ければ builtin にフォールバック)
  local s
  for s in "$ANTIVIRUS_DIR/scan.sh" "$ANTIVIRUS_DIR/bin/scan" "$ANTIVIRUS_DIR/scan"; do
    if [ -x "$s" ]; then
      if "$s" "$dir" >/dev/null 2>&1; then echo "CLEAN"; else echo "CRITICAL"; fi
      return
    fi
  done
  builtin_scan "$dir"
}

# スキル 1 件を取り込む。
# 引数: repo  category  dest_name  [license_note]  [-- sparse_path...]
install_skill() {
  local repo="$1" category="$2" name="$3"; shift 3
  local note=""
  if [ "${1:-}" != "--" ] && [ -n "${1:-}" ]; then note="$1"; shift; fi
  if [ "${1:-}" = "--" ]; then shift; fi
  local sparse=("$@")
  local dest="$SKILLS_ROOT/$category/_external/$name"

  if ! repo_exists "$repo"; then
    skipit "$repo(リモートに存在しない/到達不可)"; warn "$repo を確認できませんでした"
    return
  fi

  info "取り込み: $repo → $dest"
  if ! clone_repo "$repo" "$dest" "${sparse[@]}"; then
    skipit "$repo(clone 失敗)"; warn "$repo の clone に失敗しました"
    rm -rf "$dest"; return
  fi

  local sev; sev="$(scan_dir "$dest")"
  if [ "$sev" = "CRITICAL" ]; then
    warn "Critical を検出: $dest"
    if [ -t 0 ]; then
      printf "   このスキルを除外して続行しますか? [y=除外して続行 / n=中止]: " >&2
      read -r ans
      if [ "$ans" = "y" ]; then rm -rf "$dest"; skipit "$repo(Critical のため除外)"; return; fi
      echo "中止しました。"; exit 1
    else
      echo "非対話環境のため安全側で中止します(Critical 検出)。" >&2; exit 1
    fi
  elif [ "$sev" = "WARN" ]; then
    warn "$repo: 要注意パターンあり(取り込みは継続。中身を確認してください)"
  fi

  [ -n "$note" ] && info "  ライセンス/注記: $note"
  INSTALLED=$((INSTALLED+1))
}

install_skills() {
  command -v git >/dev/null 2>&1 || { echo "git が必要です。" >&2; exit 1; }

  info "== antivirus を最初に導入 =="
  if repo_exists "claude-world/claude-skill-antivirus"; then
    clone_repo "claude-world/claude-skill-antivirus" "$ANTIVIRUS_DIR" \
      && { INSTALLED=$((INSTALLED+1)); info "antivirus 準備完了(MIT)"; } \
      || warn "antivirus の clone に失敗。組み込みスキャンにフォールバックします"
  else
    warn "claude-skill-antivirus を確認できませんでした。組み込みスキャンを使用します"
  fi

  info "== 公式 anthropics/skills(必要分のみ sparse) =="
  # 複数カテゴリにまたがるため _external 直下に 1 度だけ取得する。
  install_skill "anthropics/skills" "" "anthropic-skills" "Apache-2.0(一部 source-available)" -- \
    skills/frontend-design skills/theme-factory skills/brand-guidelines \
    skills/skill-creator skills/mcp-builder skills/webapp-testing

  info "== フロントエンド =="
  # 注: vercel-labs/react-best-practices は agent-skills にリネーム済み。
  install_skill "vercel-labs/agent-skills" "frontend" "vercel-agent-skills" "MIT" -- skills/react-best-practices

  info "== Next.js =="
  install_skill "laguagu/claude-code-nextjs-skills" "nextjs" "laguagu-nextjs-skills" "MIT(Next.js 16 / AI SDK 6)"
  install_skill "VoltAgent/awesome-claude-code-subagents" "nextjs" "voltagent-subagents" \
    "ライセンス未確認 → 利用前に LICENSE を確認すること" -- categories/02-language-specialists/nextjs-developer.md
  # davila7/claude-code-templates は実在するが nextjs-best-practices の正確なパスを
  # 確認できなかったため、捏造を避けて自動取得はスキップする。
  if repo_exists "davila7/claude-code-templates"; then
    skipit "davila7/claude-code-templates(nextjs-best-practices のパス未確認のため自動取得を見送り)"
    warn "davila7/claude-code-templates は存在します。必要なら手動で対象パスを確認して取り込んでください"
  fi

  info "== セキュリティ =="
  # 注: trailofbits/skills に web-app-security は存在しない。skills は plugins/ 配下。
  install_skill "trailofbits/skills" "security" "trailofbits-skills" \
    "CC-BY-SA-4.0(web-app-security は無いため plugins/ を取得)" -- plugins
  install_skill "AgentSecOps/SecOpsAgentKit" "security" "secops-agentkit" "CC-BY-SA-4.0 / MPL-2.0(dual)"

  info "== テスト・ワークフロー =="
  install_skill "obra/superpowers" "testing" "superpowers" "MIT"
  install_skill "wshobson/commands" "testing" "wshobson-commands" "MIT(参考用)"
}

install_mcp() {
  if [ -x "$ROOT/install-scripts/install-mcp.sh" ]; then
    bash "$ROOT/install-scripts/install-mcp.sh"
  else
    warn "install-mcp.sh が見つからない/実行不可のため MCP 登録をスキップ"
  fi
}

case "$MODE" in
  skills) install_skills ;;
  mcp)    install_mcp ;;
  all)    install_skills; echo; install_mcp ;;
esac

echo
echo "==================== サマリ ===================="
echo "  導入:   $INSTALLED 件"
echo "  skip:   $SKIPPED 件"
echo "  warning:$WARNINGS 件"
echo "================================================"
echo "外部スキルは $SKILLS_ROOT/<category>/_external/ に隔離配置しました。"
echo "各リポジトリのライセンス/出典を確認のうえ利用してください。"
