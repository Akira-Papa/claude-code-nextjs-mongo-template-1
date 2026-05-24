# Hooks(自動で効く安全網)

Claude Code の Hooks は、ツール実行の前後やプロンプト送信時に**シェルスクリプトを自動実行**する仕組みです。登録は `.claude/settings.json` の `hooks`。各スクリプトは stdin で JSON を受け取り、終了コードで挙動を制御します。

- **exit 0**: 続行(PreToolUse なら許可)
- **exit 2**: ブロック(PreToolUse でツール実行を止め、stderr の内容を Claude に渡す)
- それ以外の非ゼロ: 非ブロックのエラー(ユーザーに表示)

## 登録一覧

| イベント | matcher | スクリプト | 役割 | ブロック |
|---|---|---|---|---|
| PreToolUse | Bash | `block-destructive.sh` | `rm -rf /`・`git push -f`・`curl \| sh` 等を検出 | ✅ exit 2 |
| PreToolUse | Write/Edit/MultiEdit | `secret-scan.sh` | API キー/トークン/秘密鍵を検出 | ✅ exit 2 |
| PreToolUse | Write/Edit/MultiEdit | `nosql-injection-check.sh` | `find({...req.body})` 等を検出 | ⚠️ 警告のみ |
| PostToolUse | Write/Edit/MultiEdit | `auto-format.sh` | prettier/biome/ruff を自動適用 | なし |
| PostToolUse | Write/Edit/MultiEdit | `post-write-lint.sh` | 変更ファイルに `eslint --fix` | なし |
| PostToolUse | Write/Edit/MultiEdit | `post-write-test.sh` | 関連テストだけ `vitest related` | なし |
| UserPromptSubmit | — | `branch-guard.sh` | main/master 直作業を警告 | なし |

## 前提

- JSON 解析に `jq`(推奨)または `python3` のいずれかが必要。両方無い場合は解析できず、安全側に倒して何もしません。
- フォーマッタ/リンタ/テストは `pnpm` 経由。未導入なら静かにスキップします。
- スクリプトはすべて実行権限が必要(`chmod +x`)。`install.sh` が付与します。

## バイパス / 調整

- `secret-scan.sh`: 行末に `pragma: allowlist secret` を付けるとその行を除外。`.env.example` は常にスキップ。
- `post-write-test.sh` が重い場合は `.claude/settings.json` から該当エントリを外してください。
- パターンを足したいときは各スクリプトの `PATTERNS` / 正規表現を編集。

## なぜ Hooks を使うのか

LLM の「うっかり」を**仕組みで止める**ためです。プロンプトでお願いするより、実行直前にスクリプトで弾く方が確実。ブロックされたら回避せず、原因(秘密の混入・危険なクエリ)を直すのが正しい対応です。
