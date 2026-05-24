---
description: lint・format・typecheck をまとめて実行し、自動修正する
allowed-tools: Read, Edit, Bash, Grep
argument-hint: [対象パス(省略時は全体)]
---

# /lint

## 手順

1. `pnpm lint`(eslint)を実行。可能なら `--fix` で自動修正。
2. フォーマッタ(prettier または biome)を適用する。
3. `pnpm typecheck` で型を確認する。
4. 自動修正で消えない警告/エラーは内容を要約し、対応方針を示す。

## 出力フォーマット

- lint / format / typecheck の結果。
- 残った指摘の一覧と対応案。

## ルール

- `any`/`@ts-ignore`/`export default` 違反を見つけたら必ず直す(抑制設定で隠さない)。
- 自動修正の差分が意図と合っているか確認する。
