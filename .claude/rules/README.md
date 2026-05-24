# Rules(横断ルール)

`CLAUDE.md` から参照される、領域別の詳細ルール集。Claude は作業対象に応じて該当ファイルを読みます。`CLAUDE.md` が要約、ここが詳細という関係です。

## 一覧

| ファイル | 対象 |
|---|---|
| `typescript.md` | 型安全・命名・モジュール |
| `nextjs.md` | App Router・Server/Client・キャッシュ |
| `mongodb.md` | スキーマ・インデックス・クエリ安全性 |
| `frontend.md` | デザイン・アクセシビリティ・shadcn/ui |
| `security.md` | シークレット・入力検証・認可 |
| `testing.md` | ユニット/E2E・カバレッジ方針 |
| `git.md` | ブランチ・コミット・PR |

## 使い方

- 矛盾が生じたら `CLAUDE.md` の鉄則 > rules の詳細 > 一般論、の順で優先。
- ルールを破る必要があると判断したら、理由を明示してユーザーに確認する。
