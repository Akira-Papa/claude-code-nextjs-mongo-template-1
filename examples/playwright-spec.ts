// examples/playwright-spec.ts
// E2E テストの参照実装。
// ポイント: getByRole/getByLabel / 自動待機(waitForTimeout 禁止) / 独立したテスト。

import { test, expect } from '@playwright/test';

test.describe('ログインフロー', () => {
  test('正しい資格情報でダッシュボードに到達する', async ({ page }) => {
    await page.goto('/login');

    await page.getByLabel('メールアドレス').fill('user@example.com');
    await page.getByLabel('パスワード').fill('correct-horse-battery');
    await page.getByRole('button', { name: 'ログイン' }).click();

    // 自動待機: 要素が見えるまで expect が retry する
    await expect(page.getByRole('heading', { name: 'ダッシュボード' })).toBeVisible();
  });

  test('誤ったパスワードでエラーを表示する', async ({ page }) => {
    await page.goto('/login');

    await page.getByLabel('メールアドレス').fill('user@example.com');
    await page.getByLabel('パスワード').fill('wrong-password');
    await page.getByRole('button', { name: 'ログイン' }).click();

    await expect(page.getByRole('alert')).toContainText('認証に失敗');
  });
});
