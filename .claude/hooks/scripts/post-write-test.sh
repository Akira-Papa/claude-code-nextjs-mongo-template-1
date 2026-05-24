#!/usr/bin/env bash
# post-write-test.sh
# イベント: PostToolUse(matcher: Write|Edit|MultiEdit)
# 役割: 変更ファイルに関連するテストだけを vitest で実行する。
# 入力: stdin に JSON({ tool_input: { file_path } })。
# 終了コード: 常に 0(テスト失敗は stderr で知らせるが作業は止めない)。
#
# なぜ: `vitest related` で関連テストだけを回し、変更の影響を即フィードバック。
#       全テストは CI に任せる。重い場合はこの hook を無効化してよい。

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
  *.ts|*.tsx|*.js|*.jsx) ;;
  *) exit 0 ;;
esac

command -v pnpm >/dev/null 2>&1 || exit 0
pnpm exec vitest --version >/dev/null 2>&1 || exit 0

# related: 変更ファイルが依存するテストのみ実行。--run で 1 回実行(watch しない)。
OUT="$(pnpm exec vitest related "$FILE" --run --passWithNoTests 2>&1)"
if [ $? -ne 0 ]; then
  echo "❌ 関連テストが失敗しました(変更: $FILE)" >&2
  printf '%s\n' "$OUT" | tail -n 30 >&2
fi

exit 0
