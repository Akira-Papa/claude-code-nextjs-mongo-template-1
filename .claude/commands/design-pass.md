---
description: 現在の UI を読み取り「AIっぽさ」(紫グラデ/Inter/平凡グリッド)を検出して改善案を出す
allowed-tools: Read, Edit, Bash, Grep, Glob
argument-hint: [対象コンポーネント/ページのパス(省略時は app/ 全体)]
---

# /design-pass

## 手順

1. 対象($ARGUMENTS、未指定なら `app/` と主要コンポーネント)を読み取る。
2. 以下の「AIっぽさ」シグナルを検出する:
   - 紫〜青の斜めグラデ背景(`from-purple`/`to-indigo`/`bg-gradient` の多用)。
   - フォントが Inter 一択で見出しと本文に差が無い。
   - 同サイズ・等間隔のカードを単純グリッドで並べただけのレイアウト。
   - 全テキストが同色・同サイズで階層が無い。
3. 検出したら `frontend-design-house` スキル経由で代替案を具体的に提示する。
4. アクセシビリティ(コントラスト AA / focus-visible / aria)も併せて点検する。

## 出力フォーマット

```
## 検出
- 紫グラデ: app/page.tsx:14(bg-gradient-to-r from-purple-500 ...)
- タイポ単調: 見出し/本文が同サイズ
## 改善案
- コンセプト: 「<誰に・どんな印象>」
- タイポ: 見出し=<案> / 本文=<案>(サイズ比 1.33+)
- 配色: brand/accent/neutral の 3 系統に整理
- レイアウト: <非対称/緩急の具体案>
## アクセシビリティ
- コントラスト/フォーカスの指摘
```

## ルール

- 紫グラデ + Inter + 平凡グリッドの量産を禁止(`.claude/rules/frontend.md`)。
- 改善は shadcn/ui + Tailwind トークンで実装する前提で示す。
- 可能ならブラウザで before/after を確認。できなければ「未確認」と明記。
