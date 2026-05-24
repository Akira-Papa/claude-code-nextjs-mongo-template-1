---
name: auth-better-auth
description: Use this skill when implementing sign-in, sessions, authorization checks, or protecting routes and Server Actions. Trigger words: 認証, ログイン, サインイン, セッション, 認可, 権限チェック, Better Auth, Auth.js, 保護, ミドルウェア, getSession.
---

# 認証(Better Auth / Auth.js v5)

## いつ使うか

- ログイン/サインアップ・セッション管理を実装するとき。
- ページや Server Action を「ログイン必須」「特定ロールのみ」に守るとき。

## やること

- 認証は Better Auth(または Auth.js v5)を採用し、設定は server-only に置く。
- セッション取得は server 側のヘルパー(`getSession`/`requireUser`)に集約する。
- **認証(誰か)と認可(何をしてよいか)を分けて**両方チェックする。
- 保護はレイアウト/ページの server 側と Server Action の両方で行う(クライアントだけに依存しない)。
- セッションシークレットは `.env.local`、本番は環境変数。

## 守るルール

- ✅ Server Action は冒頭で `requireUser()` → ロール検証の順。
- ✅ セッション/トークンは httpOnly Cookie。クライアント JS から読ませない。
- ✅ 認可ロジックは 1 箇所に集約し再利用する。
- ❌ クライアント側の `if (user)` だけで保護した気にならない。
- ❌ シークレット/トークンをクライアントへ返さない。

## 典型例(コード片)

```ts
// lib/auth.ts
import { headers } from 'next/headers';
import { auth } from '@/lib/auth-config'; // Better Auth インスタンス(server-only)

export async function requireUser() {
  const session = await auth.api.getSession({ headers: await headers() });
  if (!session) throw new Error('UNAUTHENTICATED');
  return { userId: session.user.id, role: session.user.role };
}

export async function requireAdmin() {
  const s = await requireUser();
  if (s.role !== 'admin') throw new Error('FORBIDDEN');
  return s;
}
```

## アンチパターン

- クライアントコンポーネントの表示制御だけで「保護」と考える。
- 認証は確認するが認可(ロール/所有者)を見落とす。
- セッション情報をログに出して漏らす。
