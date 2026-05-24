---
name: atlas-search-vector
description: Use this skill when implementing full-text search, autocomplete, or vector/semantic search and RAG with MongoDB Atlas. Trigger words: 全文検索, あいまい検索, オートコンプリート, ベクトル検索, セマンティック検索, 類似検索, Atlas Search, $search, $vectorSearch, RAG, embedding.
---

# Atlas Search & Vector Search

## いつ使うか

- 全文検索・あいまい検索・オートコンプリートを実装するとき。
- 埋め込み(embedding)を使ったベクトル/セマンティック検索や RAG を作るとき。
- `find` の正規表現検索が遅い・精度不足なとき。

## やること

- 全文検索は Atlas **Search Index** を作り、`$search` ステージで使う。
- ベクトル検索は **Vector Search Index** を作り、`$vectorSearch` で近傍探索する。
- 埋め込みは AI SDK 6 経由で生成し、次元数をインデックス定義と一致させる。
- ハイブリッド検索(全文 + ベクトル)はスコア結合で精度を上げる。
- 検索クエリ文字列も Zod で長さ・型を検証する。

## 守るルール

- ✅ Search / Vector Index は Atlas 側で明示定義(コードと次元・パスを一致)。
- ✅ `$vectorSearch` には `numCandidates` と `limit` を適切に設定。
- ✅ 埋め込み生成のモデル/次元を ADR に記録する。
- ❌ 正規表現 `$regex` で全件スキャンの代替にしない(遅い)。
- ❌ API キー(埋め込み生成用)をクライアントへ露出しない。

## 典型例(コード片)

```ts
// ベクトル検索(セマンティック近傍)
const queryVector = await embed(queryText); // AI SDK 6, server-only
const hits = await DocModel.aggregate([
  {
    $vectorSearch: {
      index: 'doc_vector_index',
      path: 'embedding',
      queryVector,
      numCandidates: 200,
      limit: 10,
    },
  },
  { $project: { title: 1, score: { $meta: 'vectorSearchScore' } } },
]);
```

## アンチパターン

- インデックス未作成のまま `$search` を呼びエラー/低速になる。
- 埋め込み次元の不一致(例:1536 で作って 768 を投げる)。
- 埋め込み生成をクライアント側で行い API キーを漏らす。
