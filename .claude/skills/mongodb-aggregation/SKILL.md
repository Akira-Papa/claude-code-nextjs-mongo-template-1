---
name: mongodb-aggregation
description: Use this skill when writing aggregation pipelines, grouping, joining collections, or optimizing slow MongoDB queries. Trigger words: 集計, aggregate, パイプライン, $group, $lookup, $match, 結合, グループ化, 遅いクエリ, explain.
---

# MongoDB Aggregation

## いつ使うか

- 集計(合計・件数・平均)やグループ化が必要なとき。
- 複数コレクションを結合(`$lookup`)するとき。
- 単純な `find` では取れない加工済みデータが欲しいとき。
- クエリが遅く、最適化したいとき。

## やること

- パイプラインは**早い段階で絞る**:`$match` と `$project` をできるだけ前に置く。
- `$match` をインデックスが効く形(先頭で等価条件)にする。
- `$lookup` は件数を絞ってから。N+1 を避けるが、巨大結合は分割も検討。
- 必ず `.explain('executionStats')` で `IXSCAN` を確認。`COLLSCAN` は赤信号。
- 読み取り目的なら結果を plain object として扱う。

## 守るルール

- ✅ `$match` / `$project` を最前段に置きデータ量を減らす。
- ✅ ソート対象フィールドにインデックス(ESR ルール)。
- ✅ `.explain('executionStats')` で `IXSCAN` 確認を習慣化。
- ✅ ユーザー入力は Zod 検証後にパイプラインへ。
- ❌ `$match` を最後に置いて全件処理してから絞る。
- ❌ ユーザー入力をそのまま `$where` / 演算子オブジェクトに展開しない。

## 典型例(コード片)

```ts
// ロール別の月間投稿数(直近 30 日)
const since = new Date(Date.now() - 30 * 864e5);
const rows = await PostModel.aggregate([
  { $match: { createdAt: { $gte: since } } },        // 先に絞る(インデックス)
  { $group: { _id: '$authorId', count: { $sum: 1 } } },
  { $sort: { count: -1 } },
  { $limit: 20 },
  { $lookup: { from: 'users', localField: '_id', foreignField: '_id', as: 'author' } },
  { $project: { count: 1, 'author.name': 1 } },       // 必要列だけ
]);
```

## アンチパターン

- パイプライン末尾で `$match` し、全件を集計してから捨てる。
- `$lookup` で巨大コレクションを無制限結合してメモリ超過。
- `explain` を見ずに「動いたから OK」とする。
