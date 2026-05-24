# Skills カタログ

Claude が状況に応じて**自動起動**する専門知識集。各スキルの `description`(「Use this skill when …」)が起動判定の命綱です。1 スキル = 1 フォルダのフラット配置。

## 起動の仕組み

- ユーザーの依頼やコードの文脈が `description` のトリガー語にマッチすると、Claude がそのスキルを読み込んで従う。
- 手動で促したいときは「`<skill-name>` スキルを使って」と書けばよい。
- セッション開始時はまず `_bootstrap` を読む(スタック・鉄則の地図)。

## 一覧

| スキル | 起動トリガー(要約) |
|---|---|
| `_bootstrap` | セッション開始・全体像の把握 |
| `nextjs-app-router` | ルーティング・layout・Server/Client 境界の設計 |
| `nextjs-server-actions` | フォーム送信・mutation・`'use server'` |
| `nextjs-streaming-suspense` | ローディング UI・Suspense・部分ストリーミング |
| `mongoose-modeling` | スキーマ設計・モデル定義・インデックス |
| `mongodb-aggregation` | 集計・`$group`・`$lookup`・パイプライン |
| `atlas-search-vector` | 全文検索・ベクトル検索・RAG |
| `nosql-injection-defense` | ユーザー入力をクエリへ渡す箇所のレビュー |
| `tailwind-v4-shadcn` | スタイリング・shadcn/ui コンポーネント |
| `frontend-design-house` | UI の新規作成・デザイン改善・「AIっぽさ」回避 |
| `zod-validation` | 入力・env・DB 応答のスキーマ検証 |
| `auth-better-auth` | サインイン・セッション・認可 |
| `server-only-secrets` | 秘密情報・`server-only`・env の取り扱い |
| `error-boundaries` | error.tsx・例外処理・フォールバック UI |
| `e2e-playwright` | E2E テスト・ブラウザ自動化 |
| `unit-vitest` | ユニットテスト・モック・カバレッジ |
| `api-routes-hardening` | Route Handler の堅牢化・レート制限 |
| `ci-github-actions` | CI パイプライン・GitHub Actions |
| `pr-japanese-summary` | PR 説明文・変更サマリの日本語化 |
| `sabakyan-jp-style` | 教材・ドキュメントの日本語スタイル統一 |

## 外部スキル

`install.sh` で取り込んだコミュニティ製スキルは各カテゴリの `_external/<repo>` に隔離配置されます(取り込み前に antivirus スキャン済み)。出典・ライセンスは元リポジトリを参照。
