#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="${ROOT}/plugins/account-switcher/scripts/account-switcher"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_file_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq -- "$expected" "$file" || fail "expected ${file} to contain: ${expected}"
}

setup_fake_env() {
  TMPDIR="$(mktemp -d)"
  export TMPDIR
  export HOME="${TMPDIR}/home"
  export PATH="${TMPDIR}/bin:${PATH}"
  mkdir -p "${HOME}" "${TMPDIR}/bin" "${TMPDIR}/keychain"

  cat > "${TMPDIR}/bin/uname" <<'SH'
#!/usr/bin/env bash
echo Darwin
SH
  chmod +x "${TMPDIR}/bin/uname"

  cat > "${TMPDIR}/bin/claude" <<'SH'
#!/usr/bin/env bash
if [[ "$*" == "auth status --json" ]]; then
  printf '{"loggedIn":true,"email":"a@example.com","authMethod":"claude.ai","apiProvider":"anthropic"}\n'
  exit 0
fi
exit 1
SH
  chmod +x "${TMPDIR}/bin/claude"

  cat > "${TMPDIR}/bin/security" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
store="${TMPDIR}/keychain"
cmd="${1:-}"
shift || true

service=""
password=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -s)
      service="$2"
      shift 2
      ;;
    -w)
      if [[ "$cmd" == "add-generic-password" ]]; then
        password="$2"
        shift 2
      else
        shift
      fi
      ;;
    -a|-l)
      shift 2
      ;;
    -U)
      shift
      ;;
    *)
      shift
      ;;
  esac
done

path="${store}/${service//\//_}"
case "$cmd" in
  find-generic-password)
    [[ -f "$path" ]] || exit 44
    cat "$path"
    ;;
  add-generic-password)
    printf '%s' "$password" > "$path"
    printf 'add %s\n' "$service" >> "${TMPDIR}/security.log"
    ;;
  delete-generic-password)
    rm -f "$path"
    printf 'delete %s\n' "$service" >> "${TMPDIR}/security.log"
    ;;
  *)
    exit 2
    ;;
esac
SH
  chmod +x "${TMPDIR}/bin/security"
}

test_register_stores_current_claude_credentials_in_account_keychain_item() {
  setup_fake_env
  printf '{"claudeAiOauth":{"accessToken":"access-a","refreshToken":"refresh-a","expiresAt":1773980556114}}\n' \
    > "${TMPDIR}/keychain/Claude Code-credentials"

  "${SCRIPT}" register personal-a > "${TMPDIR}/register.out"

  assert_file_contains "${TMPDIR}/register.out" "Registered account: personal-a"
  assert_file_contains "${TMPDIR}/security.log" "add Claude Code account-switcher: personal-a"
  assert_file_contains "${TMPDIR}/keychain/Claude Code account-switcher: personal-a" "access-a"
  assert_file_contains "${HOME}/.claude/account-switcher/accounts.json" '"credential_service": "Claude Code account-switcher: personal-a"'
  assert_file_contains "${HOME}/.claude/account-switcher/accounts.json" '"source_service": "Claude Code-credentials"'
  ! grep -Fq '"email_hint"' "${HOME}/.claude/account-switcher/accounts.json" || fail "register should not store email_hint"
}

test_register_rejects_email_hint_argument() {
  setup_fake_env
  printf '{"claudeAiOauth":{"accessToken":"access-a","refreshToken":"refresh-a","expiresAt":1773980556114}}\n' \
    > "${TMPDIR}/keychain/Claude Code-credentials"

  if "${SCRIPT}" register personal-a a@example.com > "${TMPDIR}/register-extra.out" 2>&1; then
    fail "register should reject a second argument"
  fi

  assert_file_contains "${TMPDIR}/register-extra.out" "register accepts only <name>."
}

test_use_restores_saved_credentials_to_claude_code_keychain_item() {
  setup_fake_env
  mkdir -p "${HOME}/.claude/account-switcher"
  cat > "${HOME}/.claude/account-switcher/accounts.json" <<'JSON'
{
  "accounts": [
    {
      "name": "personal-a",
      "email_hint": "a@example.com",
      "credential_service": "Claude Code account-switcher: personal-a",
      "source_service": "Claude Code-credentials",
      "registered_at": "2026-05-02T12:00:00.000Z"
    }
  ]
}
JSON
  printf '{"claudeAiOauth":{"accessToken":"access-a","refreshToken":"refresh-a","expiresAt":1773980556114}}\n' \
    > "${TMPDIR}/keychain/Claude Code account-switcher: personal-a"
  printf '{"claudeAiOauth":{"accessToken":"access-b","refreshToken":"refresh-b","expiresAt":1773980556114}}\n' \
    > "${TMPDIR}/keychain/Claude Code-credentials"

  "${SCRIPT}" use personal-a > "${TMPDIR}/use.out"

  assert_file_contains "${TMPDIR}/use.out" "Switched to account: personal-a"
  assert_file_contains "${TMPDIR}/security.log" "add Claude Code-credentials"
  assert_file_contains "${TMPDIR}/keychain/Claude Code-credentials" "access-a"
}

test_unregister_removes_saved_keychain_item() {
  setup_fake_env
  mkdir -p "${HOME}/.claude/account-switcher"
  cat > "${HOME}/.claude/account-switcher/accounts.json" <<'JSON'
{
  "accounts": [
    {
      "name": "personal-a",
      "credential_service": "Claude Code account-switcher: personal-a",
      "source_service": "Claude Code-credentials",
      "registered_at": "2026-05-02T12:00:00.000Z"
    }
  ]
}
JSON
  printf '{"claudeAiOauth":{"accessToken":"access-a","refreshToken":"refresh-a","expiresAt":1773980556114}}\n' \
    > "${TMPDIR}/keychain/Claude Code account-switcher: personal-a"

  "${SCRIPT}" unregister personal-a > "${TMPDIR}/unregister.out"

  assert_file_contains "${TMPDIR}/unregister.out" "Unregistered account: personal-a"
  assert_file_contains "${TMPDIR}/security.log" "delete Claude Code account-switcher: personal-a"
  [[ ! -f "${TMPDIR}/keychain/Claude Code account-switcher: personal-a" ]] || fail "expected keychain item to be deleted"
}

test_register_stores_current_claude_credentials_in_account_keychain_item
test_register_rejects_email_hint_argument
test_use_restores_saved_credentials_to_claude_code_keychain_item
test_unregister_removes_saved_keychain_item

echo "account-switcher keychain tests passed"
