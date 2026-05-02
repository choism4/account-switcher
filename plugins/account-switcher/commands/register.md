---
description: "Register the current or named Claude Code account profile"
argument-hint: "<name> [email_hint]"
disable-model-invocation: true
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/account-switcher:*)"]
---

!`"${CLAUDE_PLUGIN_ROOT}/scripts/account-switcher" register $ARGUMENTS`
