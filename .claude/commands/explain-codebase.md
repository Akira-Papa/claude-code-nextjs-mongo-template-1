---
description: コードベースの構造・データフロー・主要モジュールを解説する
allowed-tools: Read, Bash, Grep, Glob
argument-hint: [知りたい領域(例: auth, 一覧表示)or 省略(全体)]
---

# /explain-codebase

## 手順

1. ルート構成(`app/`・`lib/`・`models/`・`components/`)を俯瞰する。
2. 引数($ARGUMENTS)で領域指定があれば、その入口から呼び出しを辿る。
3. データフロー(リクエスト → Server Component/Action → Mongoose → DB)を追う。
4. 主要な規約(Server/Client 境界、Zod 境界、認可の入り方)がどこにあるか示す。

## 出力フォーマット

```
## 全体像
- 役割別ディレクトリの説明
## データフロー
- 例: /users 表示 = page.tsx → lib/users.ts → UserModel(lean) → 描画
## 注目ポイント
- 認可は lib/auth.ts に集約 など(file:line 付き)
```

## ルール

- 読者は「このリポを初めて見る開発者」。専門語は初出で 1 行補足。
- 推測でなく、実ファイルを根拠に説明する(file:line を添える)。
- `sabakyan-jp-style` のトーンに従う。
