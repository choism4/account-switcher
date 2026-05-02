#!/usr/bin/env bash
set -euo pipefail

SCRIPT="${CLAUDE_PLUGIN_ROOT}/scripts/account-switcher"

json_escape() {
  node -e 'const fs = require("fs"); process.stdout.write(JSON.stringify(fs.readFileSync(0, "utf8")));'
}

input="$(cat)"
prompt="$(printf '%s' "$input" | node -e '
const fs = require("fs");
try {
  const data = JSON.parse(fs.readFileSync(0, "utf8"));
  process.stdout.write(String(data.user_prompt || "").trim());
} catch {
  process.exit(0);
}
')"

if [[ -z "$prompt" ]]; then
  exit 0
fi

command=""
args=""
case "$prompt" in
  /account-switcher:current)
    command="current"
    ;;
  /account-switcher:ls|/account-switcher:list)
    command="ls"
    ;;
  /account-switcher:register\ *)
    command="register"
    args="${prompt#/account-switcher:register }"
    ;;
  /account-switcher:use\ *)
    command="use"
    args="${prompt#/account-switcher:use }"
    ;;
  /account-switcher:switch\ *)
    command="use"
    args="${prompt#/account-switcher:switch }"
    ;;
  /account-switcher:unregister\ *)
    command="unregister"
    args="${prompt#/account-switcher:unregister }"
    ;;
  /account-switcher:remove\ *)
    command="unregister"
    args="${prompt#/account-switcher:remove }"
    ;;
  /account-switcher:rm\ *)
    command="unregister"
    args="${prompt#/account-switcher:rm }"
    ;;
  /account-switcher:account-switcher\ *)
    rest="${prompt#/account-switcher:account-switcher }"
    command="${rest%% *}"
    if [[ "$rest" == "$command" ]]; then
      args=""
    else
      args="${rest#"$command" }"
    fi
    ;;
  *)
    exit 0
    ;;
esac

case "$command" in
  current|ls|list|register|use|switch|unregister|remove|rm)
    ;;
  *)
    exit 0
    ;;
esac

if [[ -n "$args" && ! "$args" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*$ ]]; then
  message="account-switcher: invalid account name: ${args}"
  escaped="$(printf '%s' "$message" | json_escape)"
  printf '{"continue":false,"suppressOutput":false,"systemMessage":%s}\n' "$escaped"
  exit 0
fi

set +e
if [[ -n "$args" ]]; then
  output="$("$SCRIPT" "$command" "$args" 2>&1)"
else
  output="$("$SCRIPT" "$command" 2>&1)"
fi
status=$?
set -e

if [[ "$status" -eq 0 ]]; then
  message="${output}

Handled locally by account-switcher before model invocation."
else
  message="${output}

account-switcher failed before model invocation."
fi

escaped="$(printf '%s' "$message" | json_escape)"
printf '{"continue":false,"suppressOutput":false,"systemMessage":%s}\n' "$escaped"
exit 0
