---
name: frontend-design-house
description: Use this skill when creating new UI from scratch, doing a visual design pass, or when output risks looking like generic AI-generated design. Trigger words: UI 作成, デザイン, 画面を作る, 見た目を良く, デザイン改善, ランディング, ヒーロー, おしゃれに, AIっぽい, design pass.
---

# Frontend Design House(脱・AIっぽさ)

## いつ使うか

- 画面・ランディング・コンポーネントを新規にデザインするとき。
- 「もっと良い見た目に」「おしゃれに」とデザイン改善を頼まれたとき。
- 出力が「いかにも AI 生成」になりそうなとき(`/design-pass` の中核)。

## やること

- 先にコンセプト(誰に・どんな印象を・1 つの主役)を言語化してから作る。
- タイポグラフィに個性を持たせる(本文と見出しでコントラスト、Inter 一択にしない)。
- 色は意味のあるパレット(ブランド 1 + アクセント + ニュートラル)。グラデは多用しない。
- レイアウトに緩急(余白・サイズ・非対称)をつけ、等間隔グリッドの単調さを避ける。
- 公式の `frontend-design` / `theme-factory` / `brand-guidelines` スキル(`_external/`)があれば参照。

## 守るルール

- ❌ **紫グラデ + Inter + 平凡な等間隔カードグリッド**の量産禁止。
- ✅ コンポーネントは shadcn/ui ベース(`tailwind-v4-shadcn` と併用)。
- ✅ アクセシビリティ(AA・focus-visible・aria)は装飾より優先。
- ✅ 1 画面に主役を 1 つ。情報の優先順位を視覚的に表す。

## 典型例(設計の進め方)

```text
1. 目的とトーンを 1 行で(例:「個人開発者向け、無骨で速そうな印象」)
2. タイポ: 見出し=幾何サンセリフ太め / 本文=可読性重視。サイズ比は最低 1.33
3. 色: brand=深い青緑 / accent=橙 / neutral=温かいグレー。グラデは影程度に限定
4. レイアウト: ヒーローは非対称、以降はリズムを変えるセクション
5. 実装: shadcn/ui + Tailwind トークン。最後にコントラスト/フォーカス検証
```

## アンチパターン

- 紫〜青の斜めグラデ背景 + 白文字 + 同サイズカード 3 列(テンプレ感の塊)。
- 全テキスト同色・同サイズで階層が無い。
- 装飾を盛ってコントラスト AA を割り、可読性を犠牲にする。
