---
name: nextjs-app-router
description: Use this skill when creating routes, pages, layouts, or deciding Server vs Client Component boundaries in Next.js 16 App Router. Trigger words: ルーティング, ページ追加, layout, route, app router, Server Component, use client, dynamic route, generateMetadata.
---

# Next.js 16 App Router

## いつ使うか

- 新しいページ・ルート・レイアウトを追加するとき。
- Server Component と Client Component の境界をどこに引くか迷ったとき。
- メタデータ(title / OG)や動的ルート(`[id]`)を設定するとき。

## やること

- `app/` 配下にルートを置く。フォルダ = URL セグメント、`page.tsx` が画面、`layout.tsx` が共有レイアウト。
- **デフォルトは Server Component**。データ取得は Server 側で `await` する。
- インタラクティブ要素(state / イベント / ブラウザ API)だけを `'use client'` の小さな葉に切り出す。
- 各ルートに `generateMetadata` を置き、title と OpenGraph を設定する。
- 動的ルートは `params` を受け取り、必要なら `generateStaticParams` で SSG する。

## 守るルール

- ✅ Server Component デフォルト。`'use client'` は必要箇所のみ、できるだけ末端へ。
- ✅ 画像は `next/image`、フォントは `next/font`。
- ✅ `generateMetadata` で title / OG を必須設定。
- ❌ Edge Runtime で Node 専用 API を使わない。
- ❌ `revalidate` と `cache: 'no-store'` を同時指定しない。
- ❌ `export default` を避け…られない場合だけ page/layout の規約に従う(Next.js は page をデフォルト export 必須とするため、ここは例外。それ以外のモジュールは named export)。

## 典型例(コード片)

```tsx
// app/users/[id]/page.tsx — Server Component(デフォルト)
import type { Metadata } from 'next';
import { getUser } from '@/lib/users';

export async function generateMetadata(
  { params }: { params: Promise<{ id: string }> },
): Promise<Metadata> {
  const { id } = await params;
  const user = await getUser(id);
  return { title: `${user.name} さんのプロフィール`, openGraph: { title: user.name } };
}

export default async function UserPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const user = await getUser(id);
  return <UserProfile user={user} />; // インタラクティブ部分だけ別の 'use client' へ
}
```

## アンチパターン

- ページ全体に `'use client'` を付けてサーバー取得の利点を捨てる。
- `params` を同期アクセスする(Next.js 16 では `params`/`searchParams` は Promise)。
- 動的データなのに静的化して古い内容を配信する(キャッシュ戦略を明示する)。
