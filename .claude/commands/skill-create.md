---
description: 新しいスキルの雛形を品質基準に沿って作成する
allowed-tools: Read, Write, Edit, Glob
argument-hint: <skill-name> <用途の一言>
---

# /skill-create

## 手順

1. 引数($ARGUMENTS)から `name`(kebab-case)と用途を受け取る。未指定なら質問する。
2. `.claude/skills/<name>/SKILL.md` を作成する(既存なら上書きせず確認)。
3. テンプレートに沿って各節を埋める。`description` は必ず「Use this skill when …」で始め、トリガー語を含める。
4. `.claude/skills/README.md` のカタログに 1 行追記する。
5. 取り込み済みの公式 `skill-creator`(`_external/`)があれば、その手順も参照する。

## 出力フォーマット(SKILL.md の雛形)

```markdown
---
name: <kebab-case>
description: Use this skill when <具体的トリガー>. Trigger words: ...
---

# <タイトル>

## いつ使うか
## やること
## 守るルール
## 典型例(コード片)
## アンチパターン
```

## ルール

- `description` が曖昧(「Helps with X」等)なのは NG。起動判定の命綱なので具体的に。
- 既存スキルと重複しないか確認する。重複なら既存を更新する。
- すべて H1 から始め、`sabakyan-jp-style` のトーンに従う。
