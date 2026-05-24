// examples/mongoose-model-user.ts
// User モデルの参照実装。
// ポイント: named export / timestamps / ESR 複合インデックス / Zod と型を同期。

import { Schema, model, models, type InferSchemaType, type Model } from 'mongoose';
import { z } from 'zod';

// --- スキーマ定義 ---
const userSchema = new Schema(
  {
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    name: { type: String, required: true, maxlength: 80 },
    role: { type: String, enum: ['user', 'admin'] as const, default: 'user' },
  },
  { timestamps: true },
);

// 一覧クエリ: role で絞り、createdAt で並べる → ESR(Equality → Sort）
userSchema.index({ role: 1, createdAt: -1 });

// --- 型(スキーマから導出。二重管理しない) ---
export type User = InferSchemaType<typeof userSchema>;

// --- Zod(ランタイム境界の検証用。DB 応答やフォーム入力に使う) ---
export const UserInput = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(80),
  role: z.enum(['user', 'admin']).default('user'),
});
export type UserInputType = z.infer<typeof UserInput>;

// --- モデル(ホットリロード時の再定義を防ぐ) ---
export const UserModel: Model<User> =
  (models.User as Model<User>) ?? model<User>('User', userSchema);
