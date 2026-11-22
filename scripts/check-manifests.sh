#!/usr/bin/env bash
# Checks the rules `claude plugin validate` does not: these mistakes pass validation and still break every install.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
marketplace="$root/.claude-plugin/marketplace.json"
failures=0

fail() {
  echo "FAIL: $*" >&2
  failures=$((failures + 1))
}

[ -d "$root/plugin" ] || fail "plugin/ is missing; the marketplace entry's source.path points at it"

# Claude Code drops the marketplace entry's mcpServers once the plugin has a plugin.json.
[ -d "$root/plugin" ] && while IFS= read -r manifest; do
  fail "${manifest#"$root"/} exists; the plugin must not have a plugin.json (see plugin/README.md)"
done < <(find "$root/plugin" -name plugin.json -print)

count="$(jq '.plugins | length' "$marketplace")"
[ "$count" -ge 1 ] || fail "marketplace.json lists no plugins"

for i in $(seq 0 $((count - 1))); do
  entry="$(jq -c ".plugins[$i]" "$marketplace")"
  name="$(jq -r '.name' <<<"$entry")"
  version="$(jq -r '.version // empty' <<<"$entry")"
  source="$(jq -c '.source | if type == "object" then . else {source: "relative"} end' <<<"$entry")"
  ref="$(jq -r '.ref // empty' <<<"$source")"

  [ -n "$(jq -r '.mcpServers // {} | to_entries[] | select(.value.type == "http" and (.value.url | test("^https://"))) | .key' <<<"$entry")" ] ||
    fail "$name: needs an http mcpServers entry with an https url"

  [ "$(jq -r '.source' <<<"$source")" = "git-subdir" ] ||
    fail "$name: source must be git-subdir, so installs follow the release tag rather than main"
  [ "$(jq -r '.path // empty' <<<"$source")" = "plugin" ] || fail "$name: source.path must be plugin"

  if [ -z "$version" ]; then
    fail "$name: version is required"
  elif [ "$ref" != "v$version" ]; then
    fail "$name: source.ref is '$ref' but version is '$version'; they must match as v<version>"
  elif ! git -C "$root" rev-parse -q --verify "refs/tags/$ref" >/dev/null; then
    fail "$name: tag $ref does not exist; push the release tag before bumping the marketplace (README: Releases)"
  fi
done

if [ "$failures" -gt 0 ]; then
  echo "$failures check(s) failed" >&2
  exit 1
fi
echo "manifest checks passed"
