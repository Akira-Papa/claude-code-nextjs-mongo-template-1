---
name: e2e-playwright
description: Use this skill when writing end-to-end tests, browser automation, or verifying user flows in a real browser. Trigger words: E2E, Playwright, ブラウザテスト, ユーザーフロー, 結合テスト, シナリオテスト, ログインテスト, getByRole, expect.
---

# E2E テスト(Playwright)

## いつ使うか

- ログイン〜目的達成までのユーザーフローを通しで検証するとき。
- フォーム送信・遷移・表示の結合的な確認が必要なとき。

## やること

- 役割/アクセシブルネームで要素を取る(`getByRole`/`getByLabel`)。CSS セレクタ依存を避ける。
- ネットワーク待ちは `await expect(...)` の自動待機に任せる(固定 `sleep` 禁止)。
- テストデータは各テストで独立に用意し、後始末する(他テストに依存しない)。
- 認証が要るフローは storageState を使い回してログインを毎回しない。
- 公式 `webapp-testing` スキル(`_external/`)があれば手順を参照。

## 守るルール

- ✅ `getByRole`/`getByLabel` 中心のアクセシブルなセレクタ。
- ✅ 自動待機(`expect` の retry)を使い、`waitForTimeout` を避ける。
- ✅ テストは独立・再実行可能(順序非依存)。
- ❌ 本番 DB に対して E2E を流さない(専用環境/シードを使う)。
- ❌ セッション・秘密をテストコードにハードコードしない。

## 典型例(コード片)

```ts
// e2e/login.spec.ts
import { test, expect } from '@playwright/test';

test('ログインしてダッシュボードに到達', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('メールアドレス').fill('user@example.com');
  await page.getByLabel('パスワード').fill('correct-horse');
  await page.getByRole('button', { name: 'ログイン' }).click();
  await expect(page.getByRole('heading', { name: 'ダッシュボード' })).toBeVisible();
});
```

## アンチパターン

- `page.waitForTimeout(3000)` で待つ(不安定・遅い)。
- `.css-1a2b3c` のような生成クラスをセレクタにする。
- テスト同士が同じレコードを共有して順序依存になる。
