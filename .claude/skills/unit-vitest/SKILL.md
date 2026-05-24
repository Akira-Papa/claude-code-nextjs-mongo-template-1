---
name: unit-vitest
description: Use this skill when writing unit tests, mocking dependencies, testing pure functions, or measuring coverage with Vitest. Trigger words: ユニットテスト, 単体テスト, Vitest, モック, テストを書く, カバレッジ, describe, it, expect, vi.mock.
---

# ユニットテスト(Vitest)

## いつ使うか

- 純粋関数・バリデーション・ユーティリティのロジックを検証するとき。
- 依存(DB・外部 API)をモックして単体で速くテストするとき。

## やること

- 1 テスト 1 振る舞い。AAA(Arrange / Act / Assert)で書く。
- 入出力の対応を表で考え、境界値・異常系を必ず含める。
- 外部依存は `vi.mock` で差し替え、ロジックだけを検証する。
- Zod スキーマは「通る値/弾く値」の両方をテストする。
- カバレッジは目安(ユニット ≥80%)だが、数値より重要パスの網羅を優先。

## 守るルール

- ✅ 境界値・空・異常系を含める。
- ✅ 依存はモックして単体を高速・決定的に保つ。
- ✅ テスト名は日本語で「何を期待するか」を表す。
- ❌ 実装の内部実装に密結合したテストにしない(振る舞いを検証)。
- ❌ ランダム/時刻に依存して落ちるテストを書かない(固定/注入する)。

## 典型例(コード片)

```ts
// lib/price.test.ts
import { describe, it, expect } from 'vitest';
import { applyDiscount } from './price';

describe('applyDiscount', () => {
  it('10% 割引を正しく計算する', () => {
    expect(applyDiscount(1000, 0.1)).toBe(900);
  });
  it('割引率が範囲外なら例外', () => {
    expect(() => applyDiscount(1000, 1.5)).toThrow();
  });
});
```

## アンチパターン

- 1 テストに複数の振る舞いを詰め込み、失敗箇所が分からない。
- 正常系だけ書いて境界・異常系を無視する。
- `Date.now()` を直接使い、実行時刻でテストが揺れる。
