# TypeScript ルール

## 型安全

- ❌ `any` 禁止。外部由来の値は `unknown` で受け、型ガード/Zod で絞る。
- ❌ `// @ts-ignore` / `// @ts-expect-error` の安易な使用禁止。やむを得ない場合は理由コメント必須でレビュー対象。
- ❌ `as` での強制キャストで検証を飛ばさない(Zod 検証を通す)。
- ✅ `strict: true`。`noUncheckedIndexedAccess` も有効を推奨。

## モジュール / 命名

- ❌ `export default` 禁止(named export 強制)。
  - 理由: リファクタ時の追従性・grep 容易性・自動 import の安定性。
  - 例外: Next.js が default export を要求する `page.tsx` / `layout.tsx` 等のルート規約ファイルのみ。
- ✅ 変数/関数/型は英語。型は `PascalCase`、値は `camelCase`、定数は `UPPER_SNAKE`。
- ✅ 公開 API には明示的な戻り値型を付ける。

## ロギング

- ❌ `console.log` 直書き禁止 → `logger` 経由。
- ✅ ログは構造化(メッセージ + メタ)。秘密情報を含めない。

## 判別可能な結果型

- ✅ 失敗しうる処理は `{ ok: true, data } | { ok: false, error }` を返し、呼び出し側で分岐させる(例外と使い分け)。
