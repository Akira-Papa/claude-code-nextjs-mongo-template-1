---
name: tailwind-v4-shadcn
description: Use this skill when styling components, adding shadcn/ui components, or configuring Tailwind v4 design tokens. Trigger words: スタイリング, Tailwind, shadcn, コンポーネント追加, デザイントークン, テーマ, CSS, クラス, ボタン, カード, ダークモード.
---

# Tailwind v4 + shadcn/ui

## いつ使うか

- コンポーネントにスタイルを当てるとき。
- ボタン・カード・ダイアログなど定番 UI を追加するとき。
- デザイントークン(色・余白・角丸)やダークモードを整えるとき。

## やること

- まず shadcn/ui に既存コンポーネントがないか探す(`npx shadcn@latest add <name>`)。自作は最後の手段。
- Tailwind v4 は CSS ファイルの `@theme` でトークンを定義(JS config 不要)。
- 色はトークン(CSS 変数)経由で参照し、ダークモードは `.dark` で切り替える。
- ユーティリティの重複は `cn()`(clsx + tailwind-merge)で衝突解決。
- 任意フォントは `next/font` で読み込む。

## 守るルール

- ✅ shadcn/ui を優先、自作前に必ず探す。
- ✅ トークン経由で色/間隔を指定(直値ハードコードを避ける)。
- ✅ コントラスト AA / focus-visible / 適切な aria を満たす。
- ❌ 紫グラデ + Inter + 平凡グリッドの「AIっぽい」既定スタイルに流れない。
- ❌ インラインの巨大 style 属性で組まない(ユーティリティ or トークン)。

## 典型例(コード片)

```css
/* app/globals.css — Tailwind v4 のトークン定義 */
@import 'tailwindcss';
@theme {
  --color-brand: oklch(0.62 0.17 250);
  --radius: 0.625rem;
}
```

```tsx
import { cn } from '@/lib/utils';

export function Badge({ active, className }: { active?: boolean; className?: string }) {
  return (
    <span className={cn('rounded-md px-2 py-0.5 text-sm', active && 'bg-brand text-white', className)} />
  );
}
```

## アンチパターン

- shadcn/ui に同等品があるのにゼロから自作する。
- 色を `#8b5cf6` のように直書きしてテーマ切替を壊す。
- focus リングを `outline-none` で消してアクセシビリティを損なう。
