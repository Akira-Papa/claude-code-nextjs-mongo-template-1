---
name: api-routes-hardening
description: Use this skill when creating or reviewing Next.js Route Handlers (app/api), adding rate limiting, input validation, or auth to API endpoints. Trigger words: API ルート, Route Handler, app/api, エンドポイント, レート制限, 入力検証, CORS, ヘッダー, 認証付き API, hardening.
---

# API Routes 堅牢化

## いつ使うか

- `app/api/**/route.ts`(Route Handler)を作る/レビューするとき。
- エンドポイントに認証・入力検証・レート制限を付けるとき。

## やること

- 入力(body/query/params)を Zod で検証してから処理する。
- 認証/認可を冒頭でチェック(`requireUser`/`requireAdmin`)。
- レート制限・サイズ上限を設ける(濫用・DoS 緩和)。
- 返却は明示的な型・ステータスコード。内部エラーは漏らさない。
- 動的データは適切なキャッシュ指定(`revalidate` と `no-store` を混在させない)。

## 守るルール

- ✅ 入力 Zod 検証 + 認証/認可 + レート制限の 3 点セット。
- ✅ エラー時はユーザー向け要約 + 内部ログ分離。
- ✅ 適切な HTTP ステータス(400/401/403/404/429/500)を返す。
- ❌ `req.json()` の結果を検証せず DB へ渡さない。
- ❌ スタック/DB エラー本文をレスポンスに含めない。

## 典型例(コード片)

```ts
// app/api/users/route.ts
import { NextResponse } from 'next/server';
import { z } from 'zod';
import { requireUser } from '@/lib/auth';
import { logger } from '@/lib/logger';

const Body = z.object({ name: z.string().min(1).max(80) });

export async function POST(req: Request) {
  try {
    const session = await requireUser();
    const parsed = Body.safeParse(await req.json());
    if (!parsed.success) return NextResponse.json({ error: '入力が不正です' }, { status: 400 });
    // ... 処理
    return NextResponse.json({ ok: true }, { status: 201 });
  } catch (e) {
    logger.error('users.POST failed', { message: (e as Error).message });
    return NextResponse.json({ error: '処理に失敗しました' }, { status: 500 });
  }
}
```

## アンチパターン

- 認証なしの書き込みエンドポイントを公開する。
- 入力未検証で `req.json()` を直接 DB に流す。
- 500 のレスポンスに `e.stack` を入れて内部構造を漏らす。
