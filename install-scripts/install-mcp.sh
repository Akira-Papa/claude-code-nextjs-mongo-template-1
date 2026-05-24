#!/usr/bin/env bash
# install-mcp.sh — MongoDB 公式 MCP(mongodb-js/mongodb-mcp-server, Apache-2.0)を登録する。
#
# 接続文字列は .env.local の MONGODB_URI から読む。無ければ対話的に入力を求める。
# 本番接続は read-only ロール必須(アプリ用 admin ロールでの接続は禁止)。
#
# 注: claude mcp add のフラグや mongodb-mcp-server の引数は変わりうる。
#     正確な指定は公式 README を確認のこと:
#     https://github.com/mongodb-js/mongodb-mcp-server

set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v claude >/dev/null 2>&1; then
  echo "⚠️  'claude' CLI が見つかりません。Claude Code を導入してから再実行してください。" >&2
  exit 1
fi

# 接続文字列の取得(.env.local 優先、無ければ対話入力)
URI=""
if [ -f ".env.local" ]; then
  URI="$(grep -E '^MONGODB_URI=' .env.local | head -n1 | cut -d= -f2- | sed -e 's/^["'\'']//' -e 's/["'\'']$//')"
fi

if [ -z "$URI" ] || printf '%s' "$URI" | grep -q 'USER:PASSWORD'; then
  if [ -t 0 ]; then
    echo "MongoDB 接続文字列(mongodb+srv://... / 本番は read-only ロール推奨)を入力してください。"
    read -r -p "MONGODB_URI: " URI
  else
    echo "⚠️  有効な MONGODB_URI が無く、非対話環境のため登録をスキップします。" >&2
    echo "   .env.local に MONGODB_URI を設定してから再実行してください。" >&2
    exit 0
  fi
fi

if [ -z "$URI" ]; then
  echo "⚠️  接続文字列が空のため登録を中止します。" >&2
  exit 1
fi

echo "ℹ️  MongoDB MCP を 'mongodb' という名前で登録します。"
echo "    (実行: claude mcp add mongodb -- npx -y mongodb-mcp-server --connectionString <URI>)"

# 既存登録があれば置き換えのため一旦削除(エラーは無視)
claude mcp remove mongodb >/dev/null 2>&1 || true

if claude mcp add mongodb -- npx -y mongodb-mcp-server --connectionString "$URI"; then
  echo "✅ MongoDB MCP を登録しました。"
  echo "   接続権限が read-only であることを確認してください。"
else
  echo "⚠️  登録に失敗しました。公式 README でコマンド仕様を確認してください:" >&2
  echo "   https://github.com/mongodb-js/mongodb-mcp-server" >&2
  exit 1
fi
