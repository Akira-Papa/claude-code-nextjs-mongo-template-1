---
description: テストを実行する(ユニット/E2E)。引数で対象を絞れる
allowed-tools: Read, Bash, Grep, Glob
argument-hint: [unit|e2e|ファイルパス(省略時は全ユニット)]
---

# /test

## 手順

1. 引数($ARGUMENTS)を解釈する:
   - `unit` または未指定 → `pnpm test --run`(Vitest)。
   - `e2e` → `pnpm test:e2e`(Playwright)。
   - ファイルパス → そのファイル/関連テストのみ実行。
2. 失敗テストは最小再現に絞って原因を特定する。
3. 必要ならカバレッジを確認する(`pnpm test --coverage`)。

## 出力フォーマット

- 実行種別・結果(pass/fail 件数)。
- 失敗があれば、失敗テスト名・原因の仮説・修正案。

## ルール

- 落ちるテストをスキップ/握りつぶして「完了」にしない。
- 本番 DB に E2E を流さない(専用環境/シード)。
- `.claude/rules/testing.md` に従う。
