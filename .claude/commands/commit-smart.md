---
description: ステージ済みの変更から Conventional Commits メッセージを生成する
allowed-tools: Read, Bash, Grep
argument-hint: [補足したい意図(任意)]
---

# /commit-smart

## 手順

1. `git status` と `git diff --staged` を確認する(未ステージなら対象を相談)。
2. 変更の性質を判定する(feat / fix / refactor / docs / test / chore / perf)。
3. 変更を論理単位で捉え、必要なら複数コミットに分割する案を出す。
4. メッセージは「何を」より「なぜ」を重視。引数($ARGUMENTS)の意図を反映する。
5. ユーザーが承認したらコミットする(明示依頼があるまで自動コミットしない)。

## 出力フォーマット

```
type(scope): 要約(72 文字以内)

本文: 変更の理由・背景(なぜ)。必要に応じて箇条書き。
```

## ルール

- Conventional Commits を厳守。無関係な変更を 1 コミットに混ぜない。
- `.env`/秘密ファイルをステージに含めない。含まれていたら警告する。
- フックを `--no-verify` で飛ばさない。
