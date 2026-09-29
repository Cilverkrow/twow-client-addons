#!/usr/bin/env bash
# Sync the BotMenu addon from a twow-core commit into BotMenu/ (twow-repo#410 §5.2).
#
# The canonical source is twow-core modules/mod-playerbots/addon/BotMenu-1.12.
# The WHOLE folder is copied (no fixed file list: BotMenu.xml loads BotList.lua
# with <Script>, not the .toc), byte for byte (no line-ending conversion), and
# manifests/BotMenu.sha256 + manifests/BotMenu.source record what was synced.
# Use the core commit that is DEPLOYED (the train pin), never an unmerged one:
# BotMenu writes chat commands the server must already know.
#
# Usage:
#   tools/sync-botmenu.sh <twow-core repo> <core commit>          # sync
#   tools/sync-botmenu.sh --check <twow-core repo> <core commit>  # verify only
set -euo pipefail

check=0
if [ "${1:-}" = "--check" ]; then check=1; shift; fi
core="${1:?twow-core repository path}"
commit="${2:?core commit (the deployed pin)}"
src_path="modules/mod-playerbots/addon/BotMenu-1.12"

root="$(cd "$(dirname "$0")/.." && pwd)"
full="$(git -C "$core" rev-parse --verify "${commit}^{commit}")"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

git -C "$core" -c core.autocrlf=false archive "$full" "$src_path" | tar -x -C "$tmp"
[ -f "$tmp/$src_path/BotMenu.toc" ] || { echo "no BotMenu.toc at $full:$src_path" >&2; exit 1; }
version="$(sed -n 's/^## Version: *//p' "$tmp/$src_path/BotMenu.toc" | tr -d '\r')"

hashes() { (cd "$1" && find . -type f | sed 's|^\./||' | LC_ALL=C sort | xargs -d '\n' sha256sum); }

if [ "$check" = 1 ]; then
    if diff <(hashes "$tmp/$src_path") <(hashes "$root/BotMenu") >/dev/null; then
        echo "BotMenu/ matches twow-core $full (BotMenu $version)"
        exit 0
    fi
    echo "BotMenu/ differs from twow-core $full:" >&2
    diff <(hashes "$tmp/$src_path") <(hashes "$root/BotMenu") >&2 || true
    exit 1
fi

rm -rf "$root/BotMenu"
cp -R "$tmp/$src_path" "$root/BotMenu"
mkdir -p "$root/manifests"
hashes "$root/BotMenu" > "$root/manifests/BotMenu.sha256"
cat > "$root/manifests/BotMenu.source" <<EOF
addon=BotMenu
version=$version
core_repo=Cilverkrow/twow-core
core_commit=$full
core_path=$src_path
tag=BotMenu-v$version
EOF
echo "synced BotMenu $version from twow-core $full"
cat "$root/manifests/BotMenu.sha256"
