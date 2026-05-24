#!/usr/bin/env bash
# nosql-injection-check.sh
# イベント: PreToolUse(matcher: Write|Edit|MultiEdit)
# 役割: NoSQL Injection を招きやすいパターン(spread/$where 等)を検出して "警告" する。
# 入力: stdin に JSON。
# 終了コード: 常に 0(ブロックはしない)。警告は stderr に出す。
#
# なぜ警告止まりか: 誤検知の可能性があるため強制ブロックはしない。
#                   気づきを与え、レビューを促すのが目的。

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

added_content() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$INPUT" | jq -r '[.tool_input.content, .tool_input.new_string, (.tool_input.edits[]?.new_string)] | map(select(type=="string")) | join("\n")' 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$INPUT" | python3 -c 'import sys,json
try:
 d=json.load(sys.stdin); ti=d.get("tool_input",{}) or {}
 parts=[]
 for k in ("content","new_string"):
  v=ti.get(k)
  if isinstance(v,str): parts.append(v)
 for e in (ti.get("edits") or []):
  v=e.get("new_string") if isinstance(e,dict) else None
  if isinstance(v,str): parts.append(v)
 sys.stdout.write("\n".join(parts))
except Exception:
 sys.stdout.write("")'
  fi
}

FILE="$(jget '.tool_input.file_path')"
case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs) ;;
  *) exit 0 ;;
esac

CONTENT="$(added_content)"
[ -z "$CONTENT" ] && exit 0

# 危険パターン
P_SPREAD='(find|findOne|findOneAndUpdate|updateOne|updateMany|deleteOne|deleteMany|countDocuments|aggregate)[[:space:]]*\([[:space:]]*\{[[:space:]]*\.\.\.'
P_REQ='\{[[:space:]]*\.\.\.[[:space:]]*(req|request|ctx)\.(body|query|params)'
P_WHERE='\$where'

WARN=""
printf '%s' "$CONTENT" | grep -Eq "$P_SPREAD" && WARN="${WARN}- クエリ第一引数へのオブジェクト spread(任意の演算子を注入される恐れ)\n"
printf '%s' "$CONTENT" | grep -Eq "$P_REQ"    && WARN="${WARN}- req/request の body/query/params を直接 spread している\n"
printf '%s' "$CONTENT" | grep -Eq "$P_WHERE"  && WARN="${WARN}- \$where の使用(任意 JS 実行の恐れ)\n"

if [ -n "$WARN" ]; then
  echo "⚠️  NoSQL Injection の疑いがあるパターンを検出: ${FILE:-(unknown)}" >&2
  printf '%b' "$WARN" | sed 's/^/   /' >&2
  echo "   対応: 入力を Zod で型強制し、フィールド名はコード側で固定してください。" >&2
  echo "   (これは警告です。書き込みはブロックしていません)" >&2
fi

exit 0
