#!/usr/bin/env bash
# install-skills.sh — 外部スキルだけを取り込む(MCP 登録はしない)。
# install.sh --skills-only への薄いラッパー。

set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$HERE/install.sh" --skills-only
