# Changelog

## 0.2.0

- Add macOS Keychain-backed credential save and restore for registered accounts.
- Make `register` accept only an account name.
- Make `unregister` remove the saved Keychain item for the profile.
- Add shell tests for Keychain-backed register, use, and unregister behavior.

## 0.1.0

- Add `current`, `ls`, `register`, `unregister`, and `use` commands.
- Add local profile storage at `~/.claude/account-switcher/accounts.json`.
- Add guided switch behavior that avoids direct OAuth or Keychain manipulation.
