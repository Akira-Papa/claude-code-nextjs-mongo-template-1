# Next.js 16 ルール

## Server / Client 境界

- ✅ Server Component がデフォルト。データ取得は server 側で `await`。
- ✅ `'use client'` は state/イベント/ブラウザ API が要る末端のみ。できるだけ葉に寄せる。
- ✅ `params` / `searchParams` は Promise。`await` してから使う。

## メタデータ / 資産

- ✅ 各ルートに `generateMetadata` で title / OpenGraph を設定。
- ✅ 画像は `next/image`、フォントは `next/font`。任意フォントの直 import 禁止。

## キャッシュ / ランタイム

- ❌ `revalidate` と `cache: 'no-store'` の同時指定禁止(矛盾)。
- ✅ 動的データはキャッシュ方針を明示(ISR の `revalidate` か `no-store` のどちらか)。
- ❌ Edge Runtime で Node 専用 API を使わない。

## Server Actions

- ✅ `'use server'` + 入力 Zod 検証 + 認可チェックをセットにする。
- ✅ 成功後は対象パス/タグだけを `revalidatePath`/`revalidateTag`。
- ❌ 検証前の生データを DB へ渡さない。秘密をクライアントへ返さない。

## エラー UI

- ✅ ルートに `error.tsx`(再試行 `reset` 付き)/ `not-found.tsx` を用意。
- ❌ 内部エラー(スタック・DB メッセージ)を画面に出さない。
