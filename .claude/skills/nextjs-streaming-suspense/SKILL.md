---
name: nextjs-streaming-suspense
description: Use this skill when adding loading UI, Suspense boundaries, partial streaming, or progressive rendering in Next.js 16. Trigger words: ローディング, loading.tsx, Suspense, ストリーミング, streaming, スケルトン, 遅いデータ, 段階表示.
---

# Next.js Streaming & Suspense

## いつ使うか

- データ取得が遅く、ページ全体をブロックせず段階的に表示したいとき。
- ローディング UI(スケルトン)を出したいとき。
- 重いコンポーネントを後追いで流し込みたいとき。

## やること

- ルート単位の即時ローディングは `loading.tsx` を置く(自動で Suspense になる)。
- 部分的なストリーミングは `<Suspense fallback={...}>` で遅いコンポーネントを包む。
- データ取得はできるだけ並列化(`Promise.all` ではなく、独立したコンポーネントに分けて各々 await)。
- スケルトンは実レイアウトに寄せて CLS を防ぐ。

## 守るルール

- ✅ 遅い部分だけを Suspense で隔離し、速い部分は即座に見せる。
- ✅ fallback は最終レイアウトと同寸法(レイアウトシフト防止)。
- ✅ ストリーミング対象は Server Component のまま保つ。
- ❌ ページ全体を 1 つの await でブロックしない。
- ❌ Suspense 境界の中で `'use client'` 副作用に依存した取得をしない。

## 典型例(コード片)

```tsx
// app/dashboard/page.tsx
import { Suspense } from 'react';
import { Stats } from './stats';          // 速い
import { SlowFeed } from './slow-feed';    // 遅い(外部 API)

export default function Dashboard() {
  return (
    <section>
      <Stats />
      <Suspense fallback={<FeedSkeleton />}>
        <SlowFeed />
      </Suspense>
    </section>
  );
}
```

## アンチパターン

- 全データを親で `await` してから描画(最初の 1 バイトまで遅延)。
- fallback を `null` にして読み込み中に空白 → 突然表示(ガタつく)。
- スピナーだけで具体的な構造を見せず、体感速度を落とす。
