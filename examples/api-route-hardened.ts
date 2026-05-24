// examples/api-route-hardened.ts
// Route Handler(app/api/users/route.ts 相当)の堅牢化参照実装。
// ポイント: 入力 Zod 検証 + 認証/認可 + 明示的なステータス + 内部エラーを漏らさない。

import { NextResponse } from 'next/server';
import { z } from 'zod';
import { requireUser } from '@/lib/auth';
import { logger } from '@/lib/logger';
import { UserModel } from '@/models/user';

const CreateBody = z.object({
  name: z.string().min(1).max(80),
});

export async function POST(req: Request): Promise<NextResponse> {
  try {
    const session = await requireUser(); // 認証(未ログインは例外 → 下で 401 相当に変換も可)

    const json: unknown = await req.json();
    const parsed = CreateBody.safeParse(json);
    if (!parsed.success) {
      return NextResponse.json({ error: '入力が不正です' }, { status: 400 });
    }

    const created = await UserModel.create({
      name: parsed.data.name,
      email: `placeholder+${session.userId}@example.com`,
    });

    return NextResponse.json({ id: String(created._id) }, { status: 201 });
  } catch (e) {
    // 内部詳細はログへ。レスポンスには安全な要約のみ。
    logger.error('users.POST failed', { message: (e as Error).message });
    return NextResponse.json({ error: '処理に失敗しました' }, { status: 500 });
  }
}
