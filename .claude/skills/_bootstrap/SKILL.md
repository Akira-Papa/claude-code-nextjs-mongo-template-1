---
name: bootstrap
description: Use this skill when starting a new session, opening this project for the first time, or when you need to recall the project's tech stack, hard rules, and which other skills exist. Trigger words: セッション開始, このプロジェクト, 全体像, どのスキル, 何から, getting started, overview.
---

# Bootstrap(セッション起動ガイド)

## いつ使うか

- セッションを始めた直後で、プロジェクトの前提をまだ把握していないとき。
- 「このプロジェクトは何を使ってる?」「どのルールを守る?」と聞かれたとき。
- どのスキル/コマンドを使えばいいか分からないとき。

## やること

1. スタックを確認する(下記)。`CLAUDE.md` と `.claude/rules/` が一次情報。
2. 作業の種類から適切なスキルを選ぶ(`.claude/skills/README.md` の一覧)。
3. 定型操作はスラッシュコマンド(`.claude/commands/`)を使う。
4. 重い独立作業はサブエージェント(`.claude/agents/`)に委譲する。

## スタック(地図)

- Next.js 16(App Router / Turbopack / Server Components デフォルト)
- TypeScript strict / Tailwind v4 + shadcn/ui
- MongoDB Atlas + Mongoose 8.x + Zod
- Better Auth / Vitest + Playwright / Vercel / AI SDK 6(任意)

## 守るルール(最優先の 4 つ)

1. 型安全 > 速さ。`any` / `@ts-ignore` / `export default` 禁止。
2. 外部境界(API 入力・env・DB 応答)は Zod で必ず検証。
3. 新規実装の前に `examples/` と既存コードを探す。
4. 破壊的操作(DB 削除・force push・本番設定変更)は実行前に確認。

## 典型例(作業 → スキルの対応)

```text
「ユーザー一覧ページを作りたい」      → nextjs-app-router + mongoose-modeling
「フォーム送信を実装」                → nextjs-server-actions + zod-validation
「検索が遅い」                        → mongodb-aggregation + atlas-search-vector
「この UI を改善して」                → frontend-design-house + tailwind-v4-shadcn
「ログインを付けたい」                → auth-better-auth + server-only-secrets
「PR 出すから説明文を」               → pr-japanese-summary
```

## アンチパターン

- スタックを確認せず推測で別ライブラリを導入する。
- スキル/コマンドの存在を無視して全部手で書く。
- 鉄則(`any` 禁止など)を破って「とりあえず動く」コードを出す。
