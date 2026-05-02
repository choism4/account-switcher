# account-switcher

Claude Code plugin for people who manually use more than one Claude.ai account.

`account-switcher` does not rotate accounts automatically and does not touch OAuth tokens or the macOS Keychain. It keeps local profile labels, shows the active Claude Code login, and gives a guided manual switch flow using Claude Code's official auth commands.

## Commands

```text
/account-switcher:current
/account-switcher:ls
/account-switcher:register personal-a
/account-switcher:register personal-b b@example.com
/account-switcher:use personal-b
/account-switcher:unregister personal-b
```

The plugin also includes a compatibility command:

```text
/account-switcher:account-switcher current
/account-switcher:account-switcher ls
```

## Install

Add the marketplace:

```text
/plugin marketplace add choism4/account-switcher
```

Install the plugin:

```text
/plugin install account-switcher
```

Reload plugins if Claude Code asks you to:

```text
/reload-plugins
```

## What It Stores

Profiles are stored locally at:

```text
~/.claude/account-switcher/accounts.json
```

Example:

```json
{
  "accounts": [
    {
      "name": "personal-a",
      "email_hint": "a@example.com",
      "registered_at": "2026-05-02T12:00:00.000Z"
    }
  ]
}
```

It does not store passwords, session cookies, OAuth tokens, API keys, or Keychain entries.

## Current Behavior

`/account-switcher:current` runs:

```bash
claude auth status --json
```

Claude Code currently exposes `login`, `logout`, and `status`, but not a non-interactive command for switching between Claude.ai Max accounts. For that reason, `/account-switcher:use <name>` starts a guided switch rather than modifying credentials directly.

## Development

Validate the plugin:

```bash
claude plugin validate plugins/account-switcher
```

Test with cmux's Claude wrapper:

```bash
/Applications/cmux.app/Contents/Resources/bin/claude \
  --plugin-dir plugins/account-switcher \
  -p '/account-switcher:current' \
  --output-format text
```
