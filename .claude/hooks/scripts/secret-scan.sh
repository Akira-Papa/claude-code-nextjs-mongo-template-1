#!/usr/bin/env bash
# secret-scan.sh
# イベント: PreToolUse(matcher: Write|Edit|MultiEdit)
# 役割: 書き込もうとしている内容に API キー/トークン/秘密鍵が含まれていたらブロック。
# 入力: stdin に JSON({ tool_input: { file_path, content | new_string | edits[].new_string } })。
# 終了コード: 0=許可 / 2=ブロック。
#
# 除外: .env.example はプレースホルダ用途なのでスキップ。
# バイパス: 行末に "pragma: allowlist secret" を含む行は検出対象外。

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
  *.env.example|*/.env.example) exit 0 ;;
esac

CONTENT="$(added_content)"
[ -z "$CONTENT" ] && exit 0

# pragma バイパス行を除去
SCAN="$(printf '%s' "$CONTENT" | grep -v 'pragma: allowlist secret')"

PATTERNS='-----BEGIN [A-Z ]*PRIVATE KEY-----|AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9]{20,}|gh[poasu]_[A-Za-z0-9]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_\-]{35}|(API[_-]?KEY|SECRET|TOKEN|PASSWORD|PRIVATE[_-]?KEY|ACCESS[_-]?KEY|CLIENT[_-]?SECRET)[[:space:]]*[:=][[:space:]]*["'\''][A-Za-z0-9/+_\-]{16,}["'\'']|mongodb(\+srv)?://[^:@/[:space:]]+:[^@/[:space:]]+@'

HITS="$(printf '%s' "$SCAN" | grep -nE -e "$PATTERNS")"
# プレースホルダは許容(誤検知を減らす)
HITS="$(printf '%s' "$HITS" | grep -viE 'replace-with|your[-_]|example|changeme|placeholder|xxxx|dummy|sample|<[^>]+>|\$\{|process\.env|USER:PASSWORD')"

if [ -n "$HITS" ]; then
  echo "🚨 シークレットらしき文字列を検出したため書き込みをブロックしました: ${FILE:-(unknown)}" >&2
  echo "$HITS" | sed 's/^/   /' >&2
  echo "   対応: 実値は .env.local に置く / .env.example にはプレースホルダのみ。" >&2
  echo "   誤検知なら該当行に 'pragma: allowlist secret' を付けてください。" >&2
  exit 2
fi

exit 0
