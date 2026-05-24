# Architecture Patterns(設計判断の記録)

設計上の判断を「なぜそうしたか」とともに残す場所。後から来た人(未来の自分含む)が経緯を辿れるようにします。

## 中身

| ファイル | 役割 |
|---|---|
| `decision-records/0001-template.md` | ADR(Architecture Decision Record)の雛形 |
| `mongo-modeling-decisions.md` | スキーマ/インデックス設計の判断記録 |
| `auth-strategy.md` | 認証/認可の方針 |
| `deployment-vercel.md` | Vercel デプロイ構成 |
| `observability.md` | ロギング/監視の方針 |

## ADR の運用

- 重要な設計判断をしたら `decision-records/NNNN-<title>.md` を追加する(`0001-template.md` をコピー)。
- 番号は連番、状態は Proposed → Accepted → (必要なら)Superseded。
- 「決めなかったこと」「却下した選択肢」も書くと価値が高い。

## なぜ残すのか

設計判断はコードに現れない「なぜ」を含みます。記録が無いと、後から「これは変えていいのか?」が判断できません。ADR はその文脈を保存します。
