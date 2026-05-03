# account-switcher

Switch between multiple Claude.ai accounts in Claude Code without repeating the browser login flow every time.

`account-switcher` snapshots the currently logged-in Claude Code credential and OAuth token cache into macOS Keychain under a profile name. Later, `use <name>` restores both pieces back to Claude Code.

## Requirements

- macOS
- Claude Code installed and logged in
- Claude Code plugin support

This plugin intentionally uses macOS Keychain. Linux and Windows are not supported for credential switching yet.

## Install

Add the marketplace:

```text
/plugin marketplace add choism4/claude-account-switcher
```

Install the plugin:

```text
/plugin install account-switcher
```

Reload or restart Claude Code if prompted:

```text
/reload-plugins
```

## Usage

Register the account currently logged in to Claude Code:

```text
/account-switcher:register personal
```

Log in to another Claude.ai account using Claude Code's normal login flow, then register it:

```text
/account-switcher:register work
```

List saved profiles:

```text
/account-switcher:ls
```

Switch profiles:

```text
/account-switcher:use personal
```

Check the active Claude Code account:

```text
/account-switcher:current
```

Remove a saved profile:

```text
/account-switcher:unregister work
```

## Commands

```text
/account-switcher:current
/account-switcher:ls
/account-switcher:register <name>
/account-switcher:use <name>
/account-switcher:unregister <name>
```

There is also a compatibility command:

```text
/account-switcher:account-switcher current
/account-switcher:account-switcher ls
/account-switcher:account-switcher register personal
```

## What Gets Stored

Profile metadata is stored locally:

```text
~/.claude/account-switcher/accounts.json
```

Example:

```json
{
  "accounts": [
    {
      "name": "personal",
      "credential_service": "Claude Code account-switcher: personal",
      "source_service": "Claude Code-credentials",
      "registered_at": "2026-05-02T12:00:00.000Z"
    }
  ]
}
```

The credential itself is stored in macOS Keychain as a generic password:

```text
Claude Code account-switcher: personal
```

Claude Code 2.x also keeps an OAuth token cache in:

```text
~/Library/Application Support/Claude/config.json
```

That `oauth:tokenCache` value is stored in a second Keychain item:

```text
Claude Code account-switcher config: personal
```

On switch, that saved credential is written back to the Claude Code Keychain service detected during registration, usually:

```text
Claude Code-credentials
```

The saved OAuth token cache is also restored to `config.json`. Existing profiles created before `0.2.2` should be registered again while the intended account is active.

## Manual Fallback

If Claude Code does not reload the plugin command immediately, you can run the script directly:

```bash
~/.claude/plugins/cache/account-switcher/account-switcher/0.2.4/scripts/account-switcher register personal
~/.claude/plugins/cache/account-switcher/account-switcher/0.2.4/scripts/account-switcher use personal
```

For a local checkout:

```bash
plugins/account-switcher/scripts/account-switcher register personal
plugins/account-switcher/scripts/account-switcher use personal
```

## Troubleshooting

`account-switcher` includes a `UserPromptSubmit` hook that handles `/account-switcher:*` commands locally before model invocation. This lets account switching work even when the current Claude Code account is quota-limited.

If you still see a usage-limit message before the command runs, restart Claude Code so the hook registration is loaded.

If a command hangs at `Booping...`, restart Claude Code. Some Claude Code versions keep slash command definitions and hooks in memory even after `/reload-plugins`.

If Keychain access fails, open Keychain Access and search for:

```text
Claude Code-credentials
```

Claude Code must already be logged in before registering a profile:

```bash
claude auth status
```

To verify a profile credential exists:

```bash
security find-generic-password -s "Claude Code account-switcher: personal" -w >/dev/null && echo saved
```

To verify the Claude Code 2.x OAuth token cache exists:

```bash
security find-generic-password -s "Claude Code account-switcher config: personal" -w >/dev/null && echo saved
```

## Development

Validate the plugin:

```bash
claude plugin validate plugins/account-switcher
```

Run the shell tests:

```bash
bash tests/account-switcher-keychain.test.sh
```
