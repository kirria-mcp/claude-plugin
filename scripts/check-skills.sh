#!/usr/bin/env bash
# Every skill's description loads into every Claude Code session, so these budgets keep the plugin's
# standing cost small. Each skill is a pointer to a server playbook, never a copy of it.
# Usage: check-skills.sh [repo-root]
set -euo pipefail
export LC_ALL=C.UTF-8 # ${#var} counts characters, not bytes

root="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
max_description=300   # each skill's description plus when_to_use must be under this
max_total=1200        # all skills together must be under this
max_body=600          # a pointer fits easily; a copied playbook (2,000+ characters) does not
failures=0
total=0

fail() {
  echo "FAIL: $*" >&2
  failures=$((failures + 1))
}

# Prints a frontmatter field's one-line value with surrounding quotes removed; empty when absent.
field() {
  awk -v key="$2" '
    NR == 1 && $0 != "---" { exit }
    NR > 1 && $0 == "---" { exit }
    NR > 1 && index($0, key ":") == 1 { sub("^" key ":[ ]*", ""); print; exit }
  ' "$1" | sed -E 's/^"(.*)"$/\1/; s/^'"'"'(.*)'"'"'$/\1/'
}

shopt -s nullglob
skills=("$root"/plugin/skills/*/SKILL.md)
[ "${#skills[@]}" -gt 0 ] || fail "plugin/skills has no SKILL.md files"

for skill in "${skills[@]}"; do
  dir="$(basename "$(dirname "$skill")")"
  rel="${skill#"$root"/}"
  name="$(field "$skill" name)"
  description="$(field "$skill" description)"
  when_to_use="$(field "$skill" when_to_use)"

  [ "$name" = "$dir" ] || fail "$rel: name is '$name' but the directory is '$dir'; they must match"
  case "$description" in
    "" | "|"* | ">"*) fail "$rel: description must be a non-empty single line" ;;
  esac

  length=$((${#description} + ${#when_to_use}))
  total=$((total + length))
  [ "$length" -lt "$max_description" ] ||
    fail "$rel: description is $length characters; keep it under $max_description"

  grep -qF "playbook:$dir\"" "$skill" ||
    fail "$rel: the body must fetch topic \"playbook:$dir\" through nexus_guide"
  body="$(awk 'fences >= 2 { print } $0 == "---" { fences++ }' "$skill")"
  [ "${#body}" -lt "$max_body" ] ||
    fail "$rel: the body is ${#body} characters; keep it under $max_body and fetch the playbook instead of copying it"
done

[ "$total" -lt "$max_total" ] ||
  fail "skill descriptions total $total characters; keep them under $max_total"

if [ "$failures" -gt 0 ]; then
  echo "$failures check(s) failed" >&2
  exit 1
fi
echo "skill checks passed (${#skills[@]} skills, $total description characters)"
