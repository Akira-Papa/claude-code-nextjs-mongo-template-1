# Git ルール

## ブランチ

- ❌ `main` / `master` の直接編集禁止(`branch-guard.sh` が警告)。
- ✅ 作業はフィーチャーブランチ(`feat/...`, `fix/...`)で行う。

## コミット

- ✅ Conventional Commits を強制(`feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`)。
- ✅ 論理単位で分割。無関係な変更を 1 コミットに混ぜない。
- ✅ コミットメッセージは「なぜ」を重視(`/commit-smart` で生成)。
- ❌ ユーザーの明示依頼なしに自動コミットしない。

## プッシュ / 履歴

- ❌ `git push --force`(`-f`)禁止。必要時はユーザー確認を取る。`main`/`master` への force は特に厳禁。
- ❌ 公開済みコミットの `amend`/`rebase` を勝手にしない。
- ✅ フックを `--no-verify` で飛ばさない。失敗したら原因を直す。

## PR

- ✅ 説明は「なぜ → 何を → どう検証したか」(`pr-japanese-summary` スキル)。
- ✅ UI 変更はビフォー/アフターを添える。破壊的変更は明示する。
