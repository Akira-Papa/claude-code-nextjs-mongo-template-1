#!/usr/bin/env bash
# auto-format.sh
# イベント: PostToolUse(matcher: Write|Edit|MultiEdit)
# 役割: 変更ファイルにフォーマッタ(prettier / biome / ruff)を自動適用する。
# 入力: stdin に JSON({ tool_input: { file_path } })。
# 終了コード: 常に 0(フォーマット失敗で作業を止めない)。
#
# なぜ: スタイルの揺れを保存時に吸収し、差分をノイズなく保つため。
#       フォーマッタが未導入なら静かにスキップする。

INPUT="$(cat)"

jget() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$INPUT" | jq -r "$1 // empty" 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$INPUT" | python3 -c 'import sys,json
p=sys.argv[1].lstrip(".").split(".")
try:
 d=json.load(sys.stdin)
 for k in p:
  d=d.get(k) if isinstance(d,dict) else None
 sys.stdout.write("" if d is None else (d if isinstance(d,str) else json.dumps(d)))
except Exception:
 sys.stdout.write("")' "$1"
  fi
}

FILE="$(jget '.tool_input.file_path')"
[ -z "$FILE" ] && exit 0
[ -f "$FILE" ] || exit 0

run() { "$@" >/dev/null 2>&1 || true; }

case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.json|*.css|*.scss|*.md|*.mdx|*.html|*.yml|*.yaml)
    if [ -f biome.json ] || [ -f biome.jsonc ]; then
      command -v pnpm >/dev/null 2>&1 && run pnpm exec biome format --write "$FILE"
    elif command -v pnpm >/dev/null 2>&1 && pnpm exec prettier --version >/dev/null 2>&1; then
      run pnpm exec prettier --write "$FILE"
    elif command -v npx >/dev/null 2>&1; then
      run npx --no-install prettier --write "$FILE"
    fi
    ;;
  *.py)
    command -v ruff >/dev/null 2>&1 && run ruff format "$FILE"
    ;;
esac

exit 0
