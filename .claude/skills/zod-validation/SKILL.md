---
name: zod-validation
description: Use this skill when validating API input, environment variables, form data, or DB responses at runtime boundaries. Trigger words: バリデーション, 入力検証, Zod, スキーマ, env 検証, 型強制, parse, safeParse, ランタイム境界.
---

# Zod バリデーション

## いつ使うか

- API / Server Action の入力を受け取るとき。
- 環境変数(`process.env`)を読むとき。
- 外部 API や DB の応答を信用する前。

## やること

- ランタイム境界(入力・env・外部応答)に Zod スキーマを置く。
- 失敗を例外にするか値で返すかを使い分ける(`parse` vs `safeParse`)。
- env は起動時に 1 度だけ検証し、型付き設定オブジェクトとして公開する。
- Zod の `infer` で TypeScript 型を導出し、二重定義を避ける。

## 守るルール

- ✅ 入力・env・DB 応答は必ず Zod を通す。
- ✅ ユーザー向け入力は `safeParse` でエラーを丁寧に返す。
- ✅ env スキーマは `server-only` 側に置き、クライアント露出を防ぐ。
- ❌ `as` キャストで検証を飛ばさない(`unknown` → Zod が正解)。
- ❌ 同じ形を Zod と interface で二重管理しない(`z.infer` を使う)。

## 典型例(コード片)

```ts
// lib/env.ts — 起動時に env を検証
import { z } from 'zod';

const EnvSchema = z.object({
  MONGODB_URI: z.string().url(),
  AUTH_SECRET: z.string().min(32),
  NODE_ENV: z.enum(['development', 'test', 'production']),
});

export const env = EnvSchema.parse(process.env); // 失敗時は起動で落とす
export type Env = z.infer<typeof EnvSchema>;
```

## アンチパターン

- 入力を `as MyType` でキャストして検証した気になる。
- env を直接 `process.env.X!` で参照し、欠落に実行時まで気づかない。
- 型と検証ロジックがズレて、通るはずの値が弾かれる。
