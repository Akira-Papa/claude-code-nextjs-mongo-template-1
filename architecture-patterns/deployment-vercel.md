# デプロイ構成(Vercel)

## 採用

- ホスティング: Vercel。Next.js 16(App Router / Turbopack)。
- DB: MongoDB Atlas。接続はアプリ用の最小権限ユーザー(本番は read-only を基本に、書き込みは分離)。

## 環境変数

- Vercel のプロジェクト設定(Production / Preview / Development)で管理。
- 公開可の値のみ `NEXT_PUBLIC_`。秘密はそれ以外(`server-only` 側で利用)。
- `MONGODB_URI` / `AUTH_SECRET` などは Vercel 側に登録(コードにハードコードしない)。

## ランタイム / リージョン(プロジェクト固有 — 埋める)

- Node ランタイム前提(Node 専用 API を使う箇所は Edge にしない)。
- リージョン: <Atlas クラスタに近いリージョンを選ぶ>。
- Atlas の IP アクセスリスト: <Vercel の egress 設定 / 0.0.0.0 を避ける方針>。

## CI / プレビュー

- PR ごとに Preview デプロイ。`main` マージで Production。
- CI(GitHub Actions)で lint/typecheck/test/build を通してからデプロイ。

## 判断記録 / 注意点

- <サーバーレスでの Mongoose 接続使い回し(コネクション枯渇対策)の方針>
- <コールドスタート・タイムアウトへの対処>
- 再評価の条件: <トラフィック増・専用サーバー要件が出たら見直す>
