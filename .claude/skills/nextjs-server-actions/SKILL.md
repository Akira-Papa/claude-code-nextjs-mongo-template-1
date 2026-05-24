---
name: nextjs-server-actions
description: Use this skill when implementing form submissions, data mutations, or any 'use server' function in Next.js 16. Trigger words: フォーム送信, mutation, 更新処理, 保存, Server Action, use server, useActionState, revalidatePath, データ更新.
---

# Next.js Server Actions

## いつ使うか

- フォーム送信やデータの作成・更新・削除(mutation)を実装するとき。
- クライアントから直接サーバー関数を呼びたいとき(API ルートを増やさずに)。

## やること

- mutation 関数の先頭に `'use server'` を付ける。
- 受け取った `FormData` / 引数を**必ず Zod で検証**してから処理する。
- 認可チェック(誰がこの操作をしてよいか)を関数内で行う。
- 成功後に `revalidatePath` / `revalidateTag` でキャッシュを無効化する。
- クライアント側は `useActionState` でローディング・エラーを扱う。

## 守るルール

- ✅ `'use server'` + 入力 Zod 検証 + 認可チェックを必ずセットにする。
- ✅ 返り値は判別可能な型(`{ ok: true } | { ok: false, error }`)にする。
- ✅ 成功時は適切な粒度で再検証(全体ではなく対象パス/タグ)。
- ❌ 検証前の生データを DB クエリへ渡さない。
- ❌ Server Action 内でシークレットをクライアントに返さない。

## 典型例(コード片)

```ts
// app/users/actions.ts
'use server';
import { z } from 'zod';
import { revalidatePath } from 'next/cache';
import { requireUser } from '@/lib/auth';
import { UserModel } from '@/models/user';

const UpdateName = z.object({ id: z.string().length(24), name: z.string().min(1).max(80) });

export async function updateName(_: unknown, formData: FormData) {
  const session = await requireUser();
  const parsed = UpdateName.safeParse(Object.fromEntries(formData));
  if (!parsed.success) return { ok: false as const, error: '入力が不正です' };

  const { id, name } = parsed.data;
  if (session.userId !== id) return { ok: false as const, error: '権限がありません' };

  await UserModel.updateOne({ _id: id }, { $set: { name } });
  revalidatePath(`/users/${id}`);
  return { ok: true as const };
}
```

## アンチパターン

- `Object.fromEntries(formData)` をそのまま DB へ(検証なし)。
- 認可チェックを忘れて他人のデータを更新できてしまう。
- `revalidatePath('/')` で広く無効化し、無関係なページまで再生成する。
