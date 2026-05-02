---
description: "Remove a registered Claude Code account profile"
argument-hint: "<name>"
disable-model-invocation: true
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/account-switcher:*)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/account-switcher unregister "$ARGUMENTS"`
