#!/usr/bin/env bash
# Tests for scripts/check-skills.sh, written by Claude Opus 5.5 (NEX-24). The check is what keeps skill
# descriptions from bloating every user's context, so each case proves one rule fails at its boundary.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
check="$here/check-skills.sh"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
failures=0

# fixture <name> <dir:description>...: a repo root whose skills have exactly these descriptions.
fixture() {
  local root="$scratch/$1"
  shift
  for pair in "$@"; do
    local dir="${pair%%:*}" description="${pair#*:}"
    mkdir -p "$root/plugin/skills/$dir"
    printf -- '---\nname: %s\ndescription: %s\n---\n\nCall `nexus_guide` with `topic: "playbook:%s"`.\n' \
      "$dir" "$description" "$dir" >"$root/plugin/skills/$dir/SKILL.md"
  done
  echo "$root"
}

chars() { printf 'x%.0s' $(seq 1 "$1"); }

expect() {
  local label="$1" want="$2" root="$3" pattern="${4:-}" output status
  output="$("$check" "$root" 2>&1)"
  status=$?
  if [ "$want" = pass ] && [ "$status" -ne 0 ]; then
    echo "not ok - $label: expected pass, got exit $status: $output"
    failures=$((failures + 1))
  elif [ "$want" = fail ] && { [ "$status" -eq 0 ] || ! grep -qF -- "$pattern" <<<"$output"; }; then
    echo "not ok - $label: expected a failure naming '$pattern', got exit $status: $output"
    failures=$((failures + 1))
  else
    echo "ok - $label"
  fi
}

expect "the shipped skills pass" pass "$here/.."
expect "a 299-character description passes" pass "$(fixture at299 "a:$(chars 299)")"
expect "a 300-character description fails" fail "$(fixture at300 "a:$(chars 300)")" "a/SKILL.md: description is 300 characters"
expect "a 1,199-character total passes" pass \
  "$(fixture total1199 "a:$(chars 299)" "b:$(chars 299)" "c:$(chars 299)" "d:$(chars 299)" "e:$(chars 3)")"
expect "a 1,200-character total fails" fail \
  "$(fixture total1200 "a:$(chars 299)" "b:$(chars 299)" "c:$(chars 299)" "d:$(chars 299)" "e:$(chars 4)")" \
  "descriptions total 1200 characters"
expect "non-ASCII counts characters, not bytes" pass "$(fixture unicode "a:$(printf 'é%.0s' $(seq 1 200))")"

root="$(fixture whentouse "a:$(chars 200)")"
sed -i "s/^description:.*/&\nwhen_to_use: $(chars 100)/" "$root/plugin/skills/a/SKILL.md"
expect "when_to_use counts toward the description budget" fail "$root" "description is 300 characters"

root="$(fixture misnamed "a:short")"
sed -i 's/^name: a$/name: b/' "$root/plugin/skills/a/SKILL.md"
expect "a name that differs from its directory fails" fail "$root" "name is 'b' but the directory is 'a'"

root="$(fixture noplaybook "a:short")"
sed -i 's/playbook:a/playbook:other/' "$root/plugin/skills/a/SKILL.md"
expect "a body that fetches no matching playbook fails" fail "$root" 'must fetch topic "playbook:a"'

root="$(fixture multiline "a:short")"
sed -i 's/^description: short$/description: >/' "$root/plugin/skills/a/SKILL.md"
expect "a folded multi-line description fails" fail "$root" "must be a non-empty single line"

mkdir -p "$scratch/empty/plugin/skills"
expect "a plugin with no skills fails" fail "$scratch/empty" "has no SKILL.md files"

exit "$failures"
