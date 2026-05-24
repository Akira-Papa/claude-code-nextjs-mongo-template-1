# Commands(スラッシュコマンド)

定型操作を 1 コマンドで実行するためのプロンプトテンプレート。`/<name>` で呼び出します。各ファイルは frontmatter(`description` / `allowed-tools` / `argument-hint`)+ 本文(手順・出力・ルール)で構成。

## 一覧

| コマンド | 用途 |
|---|---|
| `/init` | プロジェクト初期化(依存・env・CLAUDE.md 配置の案内) |
| `/dev` | 開発サーバー起動と動作確認 |
| `/build` | 本番ビルド + 型チェック |
| `/test` | テスト実行(ユニット/E2E) |
| `/lint` | lint + format + typecheck |
| `/security-audit` | セキュリティ監査(security-auditor 委譲) |
| `/pr-review` | PR/差分のレビュー |
| `/commit-smart` | Conventional Commits 生成 |
| `/mongo-explain` | クエリの explain と最適化提案 |
| `/design-pass` | UI の「AIっぽさ」検出と改善案 |
| `/refactor-safe` | 振る舞いを変えない安全なリファクタ |
| `/explain-codebase` | コードベースの構造を解説 |
| `/skill-create` | 新しいスキルの雛形作成 |

## 引数

- `$ARGUMENTS` で引数を受け取る。各コマンドの `argument-hint` を参照。
- 例: `/mongo-explain UserModel.find({ role: 'admin' })`
