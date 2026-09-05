# devbox

A lightweight VM for running LLM tools (Claude Code etc…)

## Install & quick start

`devbox` is a plain Ruby ≥ 2.6 script, macOS's built-in version is enough.

```sh
brew install lima
ln -s "$PWD/devbox" ~/.local/bin/devbox

# then run from a repository you want to work on
devbox shell       # first run: 5-10 min (image, apt, mise builds ruby, agent CLIs)
```

## Usage

`devbox` (or `devbox help`) lists all commands, here are the most useful:

| | |
|---|---|
| `devbox shell` | shell in the VM at your current dir |
| `devbox claude\|vibe [args…]` | run Claude Code or Mistral Vibe in auto mode |
| `devbox mount-add <path>…` | mount more host dirs RW (restart ~10s, persisted) |
| `devbox rebuild` | recreate the VM from `devbox.yaml` after editing it (state in `~/.devbox` kept) |

To commit and push from the VM, :
- either run `devbox gh-setup`. it copies the host's `gh` login + git identity into the VM
- or set `GH_TOKEN` in `~/.devbox/rc/env` and your git identity in `~/.devbox/rc/runtime.sh` by hand — cf `rc.example/`.

## What's shared with the VM

| host | in the VM | holds |
|---|---|---|
| `~/.devbox/config/` | `~/.config` (rw) | gh / git / mise config, Claude + Vibe auth & history |
| `~/.devbox/cache/` | `~/.cache` (rw) | build & package caches |
| `~/.devbox/local/` | `~/.local` (rw) | mise runtimes, npm & uv globals, shell history |
| `~/.devbox/rc/` | `~/.devbox-rc` (**ro**) | `env` + `runtime.sh` — your config, below |
| `~/.devbox/mounts` | not mounted | the `mount-add` paths, one per line |

### Configuring it

| file | when | example |
|---|---|---|
| `~/.devbox/rc/env` | env vars, loaded in every shell and `devbox run` | `ANTHROPIC_API_KEY=sk-ant-…` |
| `~/.devbox/rc/runtime.sh` | runs once per VM boot | `claude mcp add -s user context7 -- …` |
| `<project>/.devbox.sh` | runs once per VM boot, on entering the project | `npm ci`, `docker compose up -d` |

- there are commented templates: `cp rc.example/{env,runtime.sh} ~/.devbox/rc/`
- `runtime.sh` + `.devbox.sh` can be skipped with `devbox run --skip-hooks …` or `DEVBOX_NO_HOOKS=1`.
- Each runs once per boot even on failure, and isn't retried until the next — after editing one, `devbox run --skip-hooks rm -f /dev/shm/.devbox-*` (or a restart) re-runs it.
- Language versions need no config here — mise reads each project's `.tool-versions` / `.mise.toml`.

## Inspiration and design choices

A lot of inspiration came from [sylvinus/agent-vm](https://github.com/sylvinus/agent-vm).

Design choices :

- **One shared VM** for all projects, less isolation but more lightweight
- **Ruby instead of bash**, because I cannot read bash scripts over 10 lines
- **No docker inside the VM** because I do not use it
- **Persistent state lives on the host** in `~/.devbox/`
- **Provisioning re-runs every boot**, but with safe guards, only `rebuild` pays the full cost.

## Security Notes

- **Don't keep sensitive data in mounted repos** (e.g. prod secrets in `$PROJECT/.env`) — an auto-mode agent can read all of it.
- **Don't commit `~/.devbox/config/`** — it holds live tokens (gh, Claude, Vibe).
- Lima's default networking is user-mode NAT: internet works, host LAN doesn't.
