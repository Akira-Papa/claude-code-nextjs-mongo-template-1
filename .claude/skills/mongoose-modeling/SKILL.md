---
name: mongoose-modeling
description: Use this skill when designing MongoDB schemas, defining Mongoose models, choosing embed-vs-reference, or adding indexes. Trigger words: スキーマ設計, モデル定義, Mongoose, コレクション, インデックス, 埋め込み, 参照, embed, reference, index.
---

# Mongoose モデリング

## いつ使うか

- 新しいコレクションのスキーマを設計するとき。
- 埋め込み(embed)か参照(reference)かを判断するとき。
- インデックスを設計・追加するとき。

## やること

- スキーマは「どうクエリするか」から逆算して設計する(アクセスパターン駆動)。
- 一緒に読む・1 対少数・更新が一体 → **埋め込み**。独立して伸びる・多対多 → **参照**。
- 主要クエリフィールドにインデックスを張る。複合は **ESR(Equality → Sort → Range)** 順。
- Mongoose の型と Zod スキーマを 1 箇所で同期させる(DB 境界も Zod 検証)。
- 接続は使い回す(開発時のホットリロードで多重接続しないようキャッシュ)。

## 守るルール

- ✅ `_id` 以外の主要クエリフィールドへインデックス必須。
- ✅ 複合インデックスは ESR ルール順。
- ✅ 読み取り専用は `.lean()` で plain object を返す。
- ✅ `timestamps: true` で `createdAt`/`updatedAt` を持たせる。
- ❌ `export default` でモデルを出さない(named export)。
- ❌ 接続文字列をハードコードしない。

## 典型例(コード片)

```ts
// models/user.ts
import { Schema, model, models, type InferSchemaType } from 'mongoose';

const userSchema = new Schema(
  {
    email: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    role: { type: String, enum: ['user', 'admin'], default: 'user' },
  },
  { timestamps: true },
);

userSchema.index({ role: 1, createdAt: -1 }); // ESR: role=Equality, createdAt=Sort

export type User = InferSchemaType<typeof userSchema>;
export const UserModel = models.User ?? model('User', userSchema);
```

## アンチパターン

- 巨大配列を無限に埋め込む(ドキュメント 16MB 上限・更新コスト増)。
- インデックスを張らずに `find` を量産 → `COLLSCAN`。
- スキーマと TypeScript 型が二重管理でズレる。
