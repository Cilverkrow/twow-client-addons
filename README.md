# twow-client-addons

Client addons of the private TWoW hobby server (Turtle WoW 1.18.1 client,
interface 11200), distributed through the Nostalgia Launcher addon catalogue
(twow-repo#410 §5.2).

**Own code only.** This repository contains our own Lua/XML/TOC files and
nothing else: no Blizzard or Turtle files, no art, no client data, no hosts,
IPs or credentials.

## Layout

One folder per addon, named like its `.toc`, so Nostalgia installs each
folder as one addon:

| Folder | What | Canonical source |
|---|---|---|
| `BotMenu/` | Bot command menu in the chat bubble menu, bot list | twow-core `modules/mod-playerbots/addon/BotMenu-1.12` |
| `TWPatch/` | (later) client patch version check | – |

`manifests/<Addon>.sha256` lists the sha256 of every file of the addon folder;
`manifests/<Addon>.source` records the source commit. CI (`verify.yml`)
checks both on every push.

## Releases

- Each addon has its **own tags**: `BotMenu-v<version>`, `TWPatch-v<N>`.
- A BotMenu release is synced from the **deployed** twow-core commit (the
  train pin), never from an unmerged one, because BotMenu writes chat
  commands the server must already know.
- The Nostalgia catalogue (`catalog/addons.json` on the patch host) pins each
  addon by the **commit SHA** of its tag; the tag name is only a label.

## Updating BotMenu

    tools/sync-botmenu.sh <path to twow-core> <deployed core commit>
    tools/sync-botmenu.sh --check <path to twow-core> <deployed core commit>

The script copies the whole folder byte for byte (no line-ending
conversion) and rewrites the hash list and the source record. Commit the
result, open a PR, and tag `BotMenu-v<version>` on the merge commit.

After installing or updating an addon, **restart the game completely**; the
1.12 client does not see new addon files after `/reload`.
