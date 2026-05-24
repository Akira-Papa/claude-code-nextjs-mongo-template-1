---
description: MongoDB クエリの explain を取り、インデックス最適化を提案する
allowed-tools: Read, Edit, Bash, Grep, Glob
argument-hint: [クエリ or 対象ファイル:行]
---

# /mongo-explain

## 手順

1. 対象クエリを特定する($ARGUMENTS。コード片 or ファイル参照)。
2. そのクエリに `.explain('executionStats')` を付けて実行する(read-only 接続を使う)。
3. `stage` を確認する: `IXSCAN` か `COLLSCAN` か、`totalDocsExamined` と `nReturned` の比。
4. `COLLSCAN` や examined >> returned なら、ESR(Equality → Sort → Range)に沿った複合インデックスを提案する。
5. 提案インデックスを `mongoose-modeling` の方針で示し、適用後の explain を再取得する。

## 出力フォーマット

```
## explain 結果
- stage: IXSCAN / COLLSCAN
- examined / returned: 12000 / 20  ← 改善余地
## 提案
- index: { role: 1, createdAt: -1 }  // ESR
## 適用後
- stage: IXSCAN, examined/returned: 20/20
```

## ルール

- 接続は read-only ロールを使う(`.claude/rules/mongodb.md`)。
- 計測値で語る。推測で「速くなるはず」と断定しない。
