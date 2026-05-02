---
description: "Show the active Claude Code account"
argument-hint: ""
disable-model-invocation: true
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/account-switcher:*)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/account-switcher current`
