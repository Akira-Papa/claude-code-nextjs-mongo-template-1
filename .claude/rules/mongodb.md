# MongoDB / Mongoose ルール

## インデックス

- ✅ `_id` 以外の主要クエリフィールドに必ずインデックス。
- ✅ 複合インデックスは **ESR ルール**(Equality → Sort → Range)順に並べる。
- ✅ 新規/変更クエリは `.explain('executionStats')` で `IXSCAN` を確認。`COLLSCAN` は赤信号。

## クエリ

- ✅ 読み取り専用は `.lean()` で plain object を返す(Mongoose ドキュメント生成コストを削減)。
- ✅ 必要なフィールドだけ取得(`select` / `$project`)。
- ✅ 集計は `$match`/`$project` を最前段に置き、データ量を早く減らす。

## 安全性(NoSQL Injection)

- ✅ ユーザー入力は Zod で型強制してから query に渡す。
- ❌ `find({ ...req.body })` のような spread 禁止。
- ❌ `$where` に文字列を渡さない。入力で演算子オブジェクトを受け取らない。
- ✅ フィールド名(ソートキー等)はコード側の許可リストで決める。

## 接続 / 権限

- ❌ 接続文字列のハードコード禁止(`.env.local` から読む)。
- ❌ admin / 過剰権限ロールでアプリ接続禁止。本番アプリは read-only を基本に、書き込みは最小権限で分離。
- ✅ 開発時のホットリロードで多重接続しないよう接続をキャッシュする。

## モデリング

- ✅ アクセスパターン駆動。一緒に読む/1 対少数 → 埋め込み、独立して伸びる/多対多 → 参照。
- ✅ `timestamps: true`。スキーマ型は `z.infer` / `InferSchemaType` で TS と同期。
