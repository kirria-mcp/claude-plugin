# plugin/

The installed plugin: skills, hooks and commands go here.

Never add `.claude-plugin/plugin.json` to this directory. The MCP server is declared on the marketplace entry
(`../.claude-plugin/marketplace.json`), and Claude Code ignores an entry's `mcpServers` once the plugin has its own
`plugin.json`, so adding one silently disconnects every install. `scripts/check-manifests.sh` fails CI if one appears.
