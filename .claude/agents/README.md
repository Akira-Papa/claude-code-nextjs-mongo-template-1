# Agents(サブエージェント)

領域特化の作業者。重い独立作業や、専門観点でのレビューを委譲します。Claude は `description` を見て自動的に適切なエージェントを起動するか、明示的に呼び出せます。

各ファイルは YAML frontmatter(`name` / `description` / `tools` / `model`)+ システムプロンプト本文で構成されます。

## 一覧

| エージェント | 役割 | いつ呼ぶか |
|---|---|---|
| `nextjs-developer` | Next.js 16 実装 | ページ/Server Action/ルーティングの実装 |
| `mongo-architect` | DB 設計・最適化 | スキーマ設計・インデックス・遅いクエリ |
| `frontend-designer` | UI/UX デザイン | 画面デザイン・脱 AIっぽさ・アクセシビリティ |
| `security-auditor` | セキュリティ監査 | 入力検証・認可・シークレット・NoSQLi |
| `code-reviewer` | コードレビュー | 変更の正しさ・規約適合の独立確認 |
| `test-engineer` | テスト設計・実装 | ユニット/E2E の追加・失敗調査 |
| `docs-writer` | ドキュメント執筆 | README・解説・PR 説明文(日本語) |

## 使い方のコツ

- 並行できる独立作業は複数エージェントに同時委譲できる。
- レビュー系(`code-reviewer` / `security-auditor`)は実装と分けて呼ぶと、独立した目線で精度が上がる。
- エージェントは会話の文脈を引き継がないので、依頼は自己完結させる(対象ファイル・目的を明示)。
