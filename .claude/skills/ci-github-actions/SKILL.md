---
name: ci-github-actions
description: Use this skill when setting up or modifying CI pipelines, GitHub Actions workflows, or automated checks (lint, typecheck, test, build) for this project. Trigger words: CI, GitHub Actions, ワークフロー, パイプライン, 自動テスト, lint チェック, typecheck, ビルド検証, .github/workflows.
---

# CI(GitHub Actions)

## いつ使うか

- CI パイプラインを新規作成・変更するとき。
- PR で自動的に lint / typecheck / test / build を走らせたいとき。

## やること

- pnpm + Node 22 をセットアップし、依存はキャッシュする。
- ジョブは「lint → typecheck → unit test → build」を最低限通す。
- E2E は別ジョブ/必要時のみ(時間とコスト管理)。
- 秘密は GitHub Secrets。ワークフロー YAML に値を書かない。
- 失敗を握りつぶさない(`continue-on-error` を安易に使わない)。

## 守るルール

- ✅ Node 22 / pnpm / 依存キャッシュ。
- ✅ lint・typecheck・test・build を必須チェックに。
- ✅ 秘密は Secrets 経由のみ。
- ❌ YAML にトークン/接続文字列をハードコードしない。
- ❌ テスト失敗を `|| true` で無視しない。

## 典型例(コード片)

```yaml
# .github/workflows/ci.yml
name: CI
on: { pull_request: {}, push: { branches: [main] } }
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with: { node-version: 22, cache: pnpm }
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint
      - run: pnpm typecheck
      - run: pnpm test --run
      - run: pnpm build
```

## アンチパターン

- ローカルでしか通らない手順を CI に書かず「自分の環境では動く」状態。
- 秘密を YAML にベタ書きしてリポジトリに残す。
- 失敗ジョブを無視するフラグで「常に緑」を演出する。
