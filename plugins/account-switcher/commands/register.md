---
description: "Register the current Claude Code account"
argument-hint: "<name>"
disable-model-invocation: true
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/account-switcher:*)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/account-switcher register "$ARGUMENTS"`
