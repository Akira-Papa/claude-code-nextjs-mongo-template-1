---
name: server-only-secrets
description: Use this skill when handling secrets, API keys, environment variables, or ensuring server-only code never reaches the client bundle. Trigger words: シークレット, 秘密鍵, API キー, 環境変数, env, server-only, クライアント漏洩, NEXT_PUBLIC, バンドル.
---

# Server-only Secrets

## いつ使うか

- API キー・接続文字列・署名鍵など秘密情報を扱うとき。
- 「このモジュールは絶対クライアントに送りたくない」とき。
- env をクライアント/サーバーで切り分けるとき。

## やること

- 秘密を含むモジュール先頭に `import 'server-only'` を置く(誤って client に import されたらビルド失敗)。
- 公開してよい値だけ `NEXT_PUBLIC_` 接頭辞にする。それ以外は接頭辞を付けない。
- env は Zod で検証(`zod-validation` 参照)し、server 設定オブジェクトとして集約。
- 秘密は `.env.local`(git 管理外)。`.env.example` にはプレースホルダのみ。

## 守るルール

- ✅ 秘密を扱うファイルに `import 'server-only'`。
- ✅ クライアントに出してよい値だけ `NEXT_PUBLIC_`。
- ✅ env は起動時に検証して型付きで公開。
- ❌ 秘密を `.env.example` 以外に書かない/コミットしない。
- ❌ 秘密を `console.log` やレスポンスに含めない。

## 典型例(コード片)

```ts
// lib/server/payments.ts
import 'server-only'; // client から import されたらビルドで弾く
import { env } from '@/lib/env';

export function chargeClient() {
  return new PaymentClient(env.PAYMENT_SECRET_KEY); // server 限定
}
```

```bash
# .env.example(プレースホルダのみ。実値は .env.local へ)
MONGODB_URI="mongodb+srv://USER:PASSWORD@CLUSTER/DB"
AUTH_SECRET="replace-with-32+chars-random"
```

## アンチパターン

- 秘密キーを `NEXT_PUBLIC_` にして全クライアントへ配布する。
- `server-only` を付けず、共有ユーティリティ経由で client バンドルに混入。
- `.env.local` を誤ってコミット(`.gitignore` を確認)。
