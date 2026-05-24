---
name: nosql-injection-defense
description: Use this skill whenever user-controlled input flows into a MongoDB query, filter, or update. Trigger words: NoSQL Injection, ユーザー入力, req.body, クエリに渡す, find, filter, spread, $where, 検索条件, security review.
---

# NoSQL Injection 防御

## いつ使うか

- ユーザー入力(リクエストボディ・クエリ文字列・フォーム)がクエリの条件に入るとき。
- 既存コードのクエリ構築箇所をセキュリティレビューするとき。

## やること

- 入力は**まず Zod で型強制**し、想定する型(string/number 等)に確定させてから query へ。
- クエリのキー(フィールド名)と値を明示的に組み立てる。入力でキーを決めさせない。
- 演算子(`$gt` `$where` 等)を含むオブジェクトを入力から受け取らない。
- 必要なら `sanitizeFilter` 相当の方針で `$`/`.` を含むキーを拒否する。

## 守るルール

- ❌ `find({ ...req.body })` のような spread 禁止(任意の演算子を注入される)。
- ❌ `$where` に文字列を渡さない(任意 JS 実行)。
- ✅ 入力は Zod で `string()`/`number()` 等に強制してから比較に使う。
- ✅ 検索条件のフィールド名はコード側の許可リストで決める。

## 典型例(コード片)

```ts
import { z } from 'zod';

// ❌ 危険:{ email: { $ne: null } } を送られると全件一致
async function badLogin(body: unknown) {
  return UserModel.findOne({ ...(body as object) });
}

// ✅ 安全:型強制 + フィールド固定
const Login = z.object({ email: z.string().email(), password: z.string().min(1) });
async function login(body: unknown) {
  const { email } = Login.parse(body);     // string に確定
  return UserModel.findOne({ email });      // 演算子注入の余地なし
}
```

## アンチパターン

- `req.query` をそのままフィルタに展開する。
- 「型は string のはず」と決めつけ、検証なしで比較に使う。
- 入力にフィールド名(ソートキー等)を自由に指定させる。
