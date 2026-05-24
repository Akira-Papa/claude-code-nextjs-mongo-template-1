# claude-code-nextjs-mongo-template-1

**Next.js 16 + MongoDB を Claude Code で扱うときの最強テンプレート。**
スキル・サブエージェント・スラッシュコマンド・Hooks・横断ルールを一式同梱した、すぐ使える土台です。サバキャン教材としても配布できるよう、各ファイルは「なぜ・何・どう」を解説付きで書いています。

---

## 3ステップで始める

```bash
# 1. コピー: このテンプレをプロジェクトに展開する(.claude/ ごと持ち込む)
cp -r claude-code-nextjs-mongo-template-1/. your-project/

# 2. install.sh: 外部スキル取り込み + MCP 登録 + 初期設定
cd your-project && bash install-scripts/install.sh

# 3. /init: Claude Code を起動して初期化コマンドを実行
claude
> /init
```

> `CLAUDE.md.master` は配置時にプロジェクトルートの `CLAUDE.md` へリネームして使ってください(`install.sh` が案内します)。

---

## 何が入っているか

| ディレクトリ | 中身 | 役割 |
|---|---|---|
| `.claude/skills/` | 20 スキル | Claude が状況に応じて自動起動する専門知識 |
| `.claude/agents/` | 7 サブエージェント | 領域特化の作業者(設計・レビュー・テスト等) |
| `.claude/commands/` | 13 スラッシュコマンド | `/dev` `/test` `/design-pass` などの定型操作 |
| `.claude/hooks/` | 7 スクリプト | 破壊的コマンド・シークレット・NoSQLi をブロック |
| `.claude/rules/` | 7 ルール | TypeScript/Next.js/Mongo/Git の横断規約 |
| `prompt-templates/` | 5 雛形 | 機能追加・バグ調査などの即コピペプロンプト |
| `architecture-patterns/` | ADR + 設計記録 | 設計判断を残す雛形 |
| `install-scripts/` | 4 スクリプト | 導入・更新・MCP 登録 |
| `examples/` | 5 参照実装 | 動く TypeScript サンプル |

---

## 固定スタック

このテンプレの全リソースは下記スタックを前提に書かれています。

- **Runtime**: Node 22 / pnpm
- **Framework**: Next.js 16(App Router / Turbopack / Server Components デフォルト)
- **言語**: TypeScript strict(`any` / `@ts-ignore` 禁止)
- **UI**: Tailwind v4 + shadcn/ui
- **DB**: MongoDB Atlas + Mongoose 8.x + Zod
- **認証**: Better Auth(または Auth.js v5)
- **テスト**: Vitest + Playwright
- **デプロイ**: Vercel
- **AI連携**: AI SDK 6(任意)

---

## 守ってもらう鉄則(抜粋)

詳細は `CLAUDE.md.master` と `.claude/rules/` を参照。

- `any` / `@ts-ignore` / `export default` 禁止
- API 入力・env・DB レスポンスは Zod で必ず検証
- Server Component デフォルト、`'use client'` は必要箇所のみ
- MongoDB は ESR 複合インデックス + `.explain()` で `IXSCAN` 確認
- `find({...req.body})` のような spread 禁止(NoSQL Injection)
- 紫グラデ + Inter + 平凡グリッドの「AIっぽい UI」禁止
- `main` 直編集・`git push --force` 禁止

---

## install.sh の引数

```bash
bash install-scripts/install.sh            # 全部入り(デフォルト)
bash install-scripts/install.sh --skills-only
bash install-scripts/install.sh --mcp-only
```

- 最初に `skill-antivirus` を導入し、以降の外部スキルは取り込み前にスキャン
- 外部リポは `--depth 1 --filter=blob:none --sparse` で軽量 clone
- clone 先は `.claude/skills/<category>/_external/<repo>` に隔離
- スキャンで Critical 検出時は停止して確認待ち
- 末尾に「導入 N 件 / skip M 件 / warning L 件」のサマリを出力

---

## MongoDB MCP について

`install-scripts/install-mcp.sh` が公式 `mongodb-js/mongodb-mcp-server` を `claude mcp add` で登録します。

- 接続文字列は `.env.local` から読む(テンプレ時点はプレースホルダ)
- **本番接続は read-only ロール必須**。アプリ用 admin ロールでの接続は禁止

---

## ディレクトリ構成

```
.
├── README.md / CLAUDE.md.master / .gitignore
├── .claude/{skills,agents,commands,hooks,rules}/
├── prompt-templates/
├── architecture-patterns/
├── install-scripts/
└── examples/
```

各ディレクトリの `README.md` がカタログになっています。まず `.claude/skills/README.md` から読むのがおすすめです。

---

## ライセンスと出典

取り込む外部スキルはそれぞれのライセンス(Apache 2.0 / CC BY-SA 4.0 等)に従います。`install.sh` は実在を確認できたリポジトリのみを対象とし、確認できないものは skip + 警告ログを出します。出典は各 `_external/` 配下の元リポジトリを参照してください。
