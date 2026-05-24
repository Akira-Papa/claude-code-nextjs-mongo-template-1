---
description: 変更または指定範囲のセキュリティ監査を行う(security-auditor に委譲)
allowed-tools: Read, Bash, Grep, Glob, Agent
argument-hint: [対象パス or 'diff'(省略時は git diff)]
---

# /security-audit

## 手順

1. 監査範囲を決める($ARGUMENTS。未指定なら `git diff` の変更ファイル)。
2. `security-auditor` サブエージェントに、対象と観点を明示して委譲する。
3. 主な観点: 入力検証(Zod)・NoSQL Injection・認証/認可・シークレット漏洩・API ルート堅牢化。
4. 所見を重大度順に整理し、修正案を添える。

## 出力フォーマット

```
## セキュリティ監査結果
- [Critical] file:line — 何が危険か / 修正案
- [High] ...
- [Medium] ...
重大な問題が無ければ「重大な問題なし」と明記。
```

## ルール

- `.claude/rules/security.md` を基準にする。
- 確証のない指摘は「要確認」と明示し、断定しない。
- 発見と修正は分けて報告(勝手に大規模修正しない)。
