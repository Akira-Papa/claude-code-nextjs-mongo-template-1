---
description: PR または現在の差分を独立目線でレビューする
allowed-tools: Read, Bash, Grep, Glob, Agent
argument-hint: [PR 番号 or 省略(現在の差分)]
---

# /pr-review

## 手順

1. 対象を取得する:
   - 引数が PR 番号 → `gh pr diff $ARGUMENTS` で差分を取得。
   - 省略時 → `git diff` および `git diff main...HEAD`。
2. 変更の意図を把握してから、`code-reviewer`(必要に応じて `security-auditor`)に委譲する。
3. 正しさ → 規約適合 → 保守性 → テストの順で確認する。

## 出力フォーマット

```
## レビュー結果
### ブロッカー(必ず直す)
- file:line — 理由 / 修正案
### 提案(任意)
- ...
問題なしなら「重大な問題なし」。
```

## ルール

- スタイルの好みでなく、バグと規約違反(`.claude/rules/`)に集中。
- 過剰な指摘をしない。指摘には根拠と file:line を付ける。
