# 認証 / 認可の方針

## 採用

- 認証ライブラリ: Better Auth(代替: Auth.js v5)。
- セッション: httpOnly Cookie。シークレットは `.env.local` / 本番は環境変数。

## 原則

- 認証(誰か)と認可(何をしてよいか)を分けて両方チェックする。
- 認可ロジックは `lib/auth.ts` に集約(`requireUser` / `requireAdmin` 等)し再利用する。
- 保護は server 側で行う:
  - ページ: layout/page の server 側でセッション確認。
  - Server Action / Route Handler: 冒頭で `requireUser()` → ロール/所有者検証。
- クライアントの表示制御だけに保護を依存しない。

## ロール / 権限(プロジェクト固有 — 埋める)

- ロール一覧: <user / admin / ...>
- 各ロールでできること: <...>
- 所有者チェックが必要なリソース: <例: ユーザーは自分のデータのみ更新可>

## 判断記録 / トレードオフ

- <なぜ Better Auth を選んだか / Auth.js との比較>
- <セッション戦略(JWT vs DB セッション)の選択理由>
- 再評価の条件: <例: SSO 要件が出たら見直す>
