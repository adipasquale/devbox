#!/usr/bin/env bash
# Copy to ~/.devbox/rc/runtime.sh — runs inside the VM once per boot, before the
# first shell/agent, as your user. Read-only inside the VM.
#
# It runs at most once per VM boot: a marker (/dev/shm/.devbox-runtime-done) is
# written before this script, so a failure here is not retried until the next
# boot. To re-run now:  devbox run --skip-hooks rm -f /dev/shm/.devbox-runtime-done
#
# Keep it idempotent and quiet. Errors go to stderr but don't block the session.

set -eu

# --- git identity + gh credential helper ------------------------------------
# `devbox gh-setup` writes all of this from the host. Uncomment here to set it by
# hand instead (pair with GH_TOKEN in ~/.devbox/rc/env), or to override.
# git config --global user.name  "Your Name"
# git config --global user.email "0000000+you@users.noreply.github.com"
# git config --global credential."https://github.com".helper     "!gh auth git-credential"
# git config --global credential."https://gist.github.com".helper "!gh auth git-credential"

# --- Claude Code: extra user-scope MCP servers ------------------------------
# Registration is idempotent (`mcp add` on an existing server is a no-op), so
# these self-heal on the next boot. Start a fresh Claude session to load them.
# command -v claude >/dev/null && \
#   claude mcp add -s user context7 -- npx -y @upstash/context7-mcp@latest

# Browser automation against the VM's chromium (start a fresh session after):
# command -v claude >/dev/null && ! claude mcp get chrome-devtools >/dev/null 2>&1 && \
#   claude mcp add -s user chrome-devtools -- \
#     npx -y chrome-devtools-mcp@latest --headless --isolated --executablePath /usr/bin/chromium

# --- shared skills / plugins ------------------------------------------------
# mkdir -p ~/.config/claude/skills
# [ -d ~/.config/claude/skills/team ] || \
#   git clone git@github.com:your-org/claude-skills.git ~/.config/claude/skills/team
