---
description: "Manage Claude Code account profiles"
argument-hint: "current | ls | register <name> [email_hint] | unregister <name> | use <name>"
disable-model-invocation: true
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/account-switcher:*)"]
---

!`"${CLAUDE_PLUGIN_ROOT}/scripts/account-switcher" $ARGUMENTS`
