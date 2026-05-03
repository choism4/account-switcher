---
description: "Switch profiles and verify Claude Code can answer"
argument-hint: "[name]"
disable-model-invocation: true
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/account-switcher:*)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/account-switcher smoke $ARGUMENTS`
