---
name: pr-japanese-summary
description: Use this skill when writing a pull request description, change summary, or release notes in Japanese for this project. Trigger words: PR 説明, プルリク, 変更サマリ, リリースノート, PR 文章, レビュー依頼, 日本語で説明, pull request.
---

# PR 日本語サマリ

## いつ使うか

- PR を出すための説明文を書くとき。
- 変更内容を日本語でレビュアー向けに要約するとき。

## やること

- 「なぜ(背景・課題)→ 何を(変更点)→ どう検証したか」の順で書く。
- 変更点は箇条書きで、ファイル列挙ではなく**意味**で説明する。
- 動作確認・テスト結果・スクショ(UI 変更時)を添える。
- 破壊的変更・移行手順があれば明示する。
- コミットは Conventional Commits(`/commit-smart` で生成)。

## 守るルール

- ✅ 背景 → 変更 → 検証の 3 部構成。
- ✅ レビュアーが 1 分で要点を掴める長さに。
- ✅ UI 変更はビフォー/アフターを示す。
- ❌ 「色々直した」など中身の無い要約にしない。
- ❌ 自動生成の差分ダンプを貼るだけにしない。

## 典型例(出力フォーマット)

```markdown
## なぜ
ユーザー検索が遅く(COLLSCAN)、一覧表示が 2 秒以上かかっていた。

## 何を
- `users` に `{ role: 1, createdAt: -1 }` 複合インデックスを追加(ESR)
- 一覧クエリを `.lean()` 化し不要フィールドを `$project` で除外

## どう検証したか
- `explain('executionStats')` で IXSCAN を確認(COLLSCAN 解消)
- 一覧表示 2.1s → 180ms(ローカル計測)
- 既存ユニット/E2E グリーン
```

## アンチパターン

- 変更ファイル名を列挙するだけで意図が伝わらない。
- 検証方法を書かず「動きました」で終わる。
- 破壊的変更を本文に埋もれさせて見落とさせる。
