---
name: error-boundaries
description: Use this skill when handling runtime errors, adding error.tsx or not-found.tsx, designing fallback UI, or deciding what to surface to users vs logs. Trigger words: エラー処理, error.tsx, not-found, 例外, フォールバック, エラーバウンダリ, try catch, ユーザー向けエラー, ログ.
---

# Error Boundaries & 例外処理

## いつ使うか

- 実行時エラーを安全に扱い、ユーザーに壊れた画面を見せたくないとき。
- ルート単位のエラー UI(`error.tsx`)や 404(`not-found.tsx`)を用意するとき。
- 何をユーザーに見せ、何をログに残すか設計するとき。

## やること

- ルートごとに `error.tsx`(Client Component、`reset` で再試行)と `not-found.tsx` を置く。
- 例外は意味のある型/メッセージで投げ、境界で捕捉してフォールバック表示。
- ユーザーには安全な要約、詳細(スタック・内部情報)は logger へ。
- 予期する失敗(検証エラー等)は例外ではなく値で返し、UI で扱う。

## 守るルール

- ✅ ルートに `error.tsx` / `not-found.tsx` を用意。
- ✅ ユーザー向けメッセージと内部ログを分離(内部情報を露出しない)。
- ✅ 再試行可能な失敗には `reset()` を提供。
- ❌ `catch (e) {}` で握りつぶさない(必ずログ or 再送出)。
- ❌ スタックトレースや DB エラー文をそのまま画面に出さない。

## 典型例(コード片)

```tsx
// app/dashboard/error.tsx
'use client';
import { logger } from '@/lib/logger';

export default function DashboardError({ error, reset }: { error: Error; reset: () => void }) {
  logger.error('dashboard render failed', { message: error.message });
  return (
    <div role="alert">
      <p>ダッシュボードの読み込みに失敗しました。</p>
      <button onClick={reset}>再試行</button>
    </div>
  );
}
```

## アンチパターン

- すべてを 1 つの try/catch で包み、どこで何が失敗したか分からなくする。
- エラー詳細を `alert(error.stack)` で表示し内部構造を漏らす。
- 例外を握りつぶして「成功」扱いし、後段でデータ不整合を起こす。
