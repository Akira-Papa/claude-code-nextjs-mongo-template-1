#!/usr/bin/env bash
# branch-guard.sh
# イベント: UserPromptSubmit
# 役割: main/master ブランチで直接作業しようとしている場合に警告する。
# 入力: stdin に JSON({ prompt, ... })。
# 終了コード: 0(ブロックしない)。stdout に出した文字列は Claude の文脈に追加される。
#
# なぜ: main 直編集は事故の元。ブランチを切るよう促す(強制はしない)。

INPUT="$(cat)"

command -v git >/dev/null 2>&1 || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
case "$BRANCH" in
  main|master)
    # stdout はコンテキストに追加されるため、Claude への注意喚起として使う
    echo "[branch-guard] 現在のブランチは '$BRANCH' です。直接編集は避け、作業用ブランチ(例: feat/...)を切ることを検討してください。破壊的な変更前には必ずユーザーに確認を。"
    ;;
esac

exit 0
