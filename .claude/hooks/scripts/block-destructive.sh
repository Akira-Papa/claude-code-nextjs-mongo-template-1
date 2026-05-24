#!/usr/bin/env bash
# block-destructive.sh
# イベント: PreToolUse(matcher: Bash)
# 役割: 明らかに破壊的な Bash コマンドを exit 2 でブロックする。
# 入力: stdin に JSON({ tool_input: { command } })。
# 終了コード: 0=許可 / 2=ブロック(stderr のメッセージが Claude に渡る)。
#
# なぜ: 取り返しのつかない操作(全削除・force push・パイプ実行)を
#       「実行前」に止めるため。回避ではなく原因再考を促す。

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

CMD="$(jget '.tool_input.command' | tr '\n' ' ')"
[ -z "$CMD" ] && exit 0

block() {
  echo "🚨 破壊的コマンドをブロックしました: $1" >&2
  echo "   コマンド: $CMD" >&2
  echo "   本当に必要なら、より安全な代替を検討するかユーザーに確認してください。" >&2
  exit 2
}

# rm -rf でルート/ホーム/ワイルドカードを狙うもの
if printf '%s' "$CMD" | grep -Eq '(^|[^[:alnum:]_])rm[[:space:]]'; then
  if printf '%s' "$CMD" | grep -Eq '\-[[:alpha:]]*r[[:alpha:]]*f|\-[[:alpha:]]*f[[:alpha:]]*r|\-r[[:space:]]+-f|\-f[[:space:]]+-r'; then
    if printf '%s' "$CMD" | grep -Eq '[[:space:]](/|~|/\*|\$HOME)([[:space:]]|/|$)'; then
      block "rm -rf による広域削除"
    fi
  fi
fi

# パイプでシェルに直接流し込む(curl | sh 等)
printf '%s' "$CMD" | grep -Eq '(curl|wget|fetch)\b[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(sh|bash|zsh)\b' \
  && block "ダウンロードしたスクリプトの直接実行(curl | sh)"

# git の強制プッシュ
printf '%s' "$CMD" | grep -Eq 'git[[:space:]]+push\b' \
  && printf '%s' "$CMD" | grep -Eq '(--force([[:space:]=]|$)|[[:space:]]-f([[:space:]]|$))' \
  && block "git push --force(履歴を破壊する可能性)"

# フォークボム
printf '%s' "$CMD" | grep -Eq ':\(\)[[:space:]]*\{[^}]*:\|[^}]*&[^}]*\}' \
  && block "フォークボム"

# ファイルシステム破壊系
printf '%s' "$CMD" | grep -Eq '\bmkfs(\.[a-z0-9]+)?\b' && block "mkfs(フォーマット)"
printf '%s' "$CMD" | grep -Eq '\bdd\b[^|]*of=/dev/' && block "dd でデバイスへ書き込み"
printf '%s' "$CMD" | grep -Eq '>[[:space:]]*/dev/(sd|nvme|disk)' && block "ブロックデバイスへのリダイレクト"
printf '%s' "$CMD" | grep -Eq 'chmod[[:space:]]+-R[[:space:]]+777[[:space:]]+/' && block "chmod -R 777 /"

exit 0
