#!/usr/bin/env bash
# post-write-lint.sh
# イベント: PostToolUse(matcher: Write|Edit|MultiEdit)
# 役割: 変更した JS/TS ファイルだけに eslint --fix を適用する。
# 入力: stdin に JSON({ tool_input: { file_path } })。
# 終了コード: 常に 0(lint 警告で作業を止めない。重大なら Claude が後段で対処)。
#
# なぜ: 変更箇所だけを対象にすることで高速。全体 lint は CI に任せる。

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

case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs) ;;
  *) exit 0 ;;
esac

command -v pnpm >/dev/null 2>&1 || exit 0
# eslint が未導入なら何もしない
pnpm exec eslint --version >/dev/null 2>&1 || exit 0

OUT="$(pnpm exec eslint --fix "$FILE" 2>&1)"
if [ $? -ne 0 ]; then
  echo "ℹ️  eslint が修正しきれない問題を報告しています: $FILE" >&2
  printf '%s\n' "$OUT" | tail -n 20 >&2
fi

exit 0
