---
description: 本番ビルドと型チェックを実行し、失敗を切り分ける
allowed-tools: Read, Bash, Grep
argument-hint: (なし)
---

# /build

## 手順

1. `pnpm typecheck`(`tsc --noEmit`)を実行する。
2. `pnpm build`(Next.js / Turbopack)を実行する。
3. 失敗したら、エラーの最初の根本原因に絞って修正方針を立てる(派生エラーに惑わされない)。
4. ビルド成果物の警告(大きなバンドル等)があれば指摘する。

## 出力フォーマット

- typecheck / build の結果(成功 or 失敗)。
- 失敗時はエラー要約 + 原因の仮説 + 修正案。

## ルール

- 型エラーを `any`/`@ts-ignore` で握りつぶさない(根本原因を直す)。
- 警告を無視せず、対応するか理由を述べる。
