# Changelog

## 0.2.3

- Fix GitHub Actions validation so plugin version bumps pass when the plugin and marketplace versions match.

## 0.2.2

- Save and restore Claude Code 2.x `oauth:tokenCache` from `~/Library/Application Support/Claude/config.json`.
- Store each profile's OAuth token cache in a separate macOS Keychain item.
- Keep the hook script working when Claude Code runs it without `CLAUDE_PLUGIN_ROOT`.

## 0.2.1

- Add a `UserPromptSubmit` hook so account-switcher commands run before model invocation, including from quota-limited sessions.

## 0.2.0

- Add macOS Keychain-backed credential save and restore for registered accounts.
- Make `register` accept only an account name.
- Make `unregister` remove the saved Keychain item for the profile.
- Add shell tests for Keychain-backed register, use, and unregister behavior.

## 0.1.0

- Add `current`, `ls`, `register`, `unregister`, and `use` commands.
- Add local profile storage at `~/.claude/account-switcher/accounts.json`.
- Add guided switch behavior that avoids direct OAuth or Keychain manipulation.
