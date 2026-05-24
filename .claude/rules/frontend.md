# フロントエンド / デザインルール

## 脱・AIっぽさ

- ❌ **紫グラデ + Inter + 平凡な等間隔グリッドカード**の量産を禁止。
- ✅ 先にコンセプト(誰に・どんな印象を・主役は 1 つ)を言語化してから作る。
- ✅ タイポ・色・レイアウトに意図的な緩急をつける(`frontend-design-house` スキル参照)。

## コンポーネント

- ✅ 自作前に shadcn/ui を探す(`npx shadcn@latest add`)。
- ✅ 色/間隔は Tailwind v4 のトークン(CSS 変数)経由。直値ハードコードを避ける。
- ✅ クラス衝突は `cn()`(clsx + tailwind-merge)で解決。

## アクセシビリティ(必須)

- ✅ コントラスト WCAG AA 以上。
- ✅ `focus-visible` を消さない(`outline-none` 単独禁止)。
- ✅ 適切な `aria-*` / 役割。フォームは `label` と関連付け。
- ✅ 画像に `alt`、装飾画像は `alt=""`。

## パフォーマンス(Core Web Vitals)

- ✅ 画像は `next/image`、サイズ指定で CLS を防ぐ。
- ✅ Suspense の fallback は実レイアウトに寸法を合わせる。
- ✅ クライアント JS を増やしすぎない(Server Component 優先)。
