---
description: プロジェクトを初期化する(依存導入・env 雛形・CLAUDE.md 配置の確認)
allowed-tools: Read, Edit, Write, Bash, Glob
argument-hint: (なし)
---

# /init

## 手順

1. `CLAUDE.md.master` が存在し、ルートに `CLAUDE.md` が無ければ、コピー配置を提案する(上書きはしない)。
2. `package.json` を確認し、無ければ Next.js 16 / pnpm 前提のセットアップ手順を案内する。
3. `.env.example` を確認し、`.env.local` が無ければ雛形作成を提案する(値はプレースホルダ)。
4. `.claude/hooks/scripts/*.sh` に実行権限があるか確認し、無ければ付与を提案する。
5. `install-scripts/install.sh` の実行を案内する(外部スキル/MCP 導入)。

## 出力フォーマット

- チェックリスト形式で「済 / 要対応」を表示。
- 要対応項目には具体的なコマンドを添える。

## ルール

- 既存ファイルを上書きしない。配置・作成は必ず提案 → 確認の順。
- シークレットは `.env.local` のみ。`.env.example` はプレースホルダ。
