// examples/server-action.ts
// Server Action の参照実装。
// ポイント: 'use server' + 入力 Zod 検証 + 認可チェック + 対象だけ revalidate。

'use server';

import { z } from 'zod';
import { revalidatePath } from 'next/cache';
import { requireUser } from '@/lib/auth';
import { UserModel } from '@/models/user';

const UpdateName = z.object({
  id: z.string().length(24),
  name: z.string().min(1).max(80),
});

// 判別可能な結果型(呼び出し側で分岐できる)
export type ActionResult = { ok: true } | { ok: false; error: string };

export async function updateName(_prev: unknown, formData: FormData): Promise<ActionResult> {
  const session = await requireUser(); // 認証

  const parsed = UpdateName.safeParse(Object.fromEntries(formData));
  if (!parsed.success) {
    return { ok: false, error: '入力が不正です' };
  }

  const { id, name } = parsed.data;
  if (session.userId !== id) {
    return { ok: false, error: '権限がありません' }; // 認可(所有者チェック)
  }

  await UserModel.updateOne({ _id: id }, { $set: { name } });
  revalidatePath(`/users/${id}`); // 対象パスだけ再検証
  return { ok: true };
}
