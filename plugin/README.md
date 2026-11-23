# plugin/

The installed plugin: skills, hooks and commands go here.

Each skill in `skills/` is named after a Nexus playbook and only points at it: its body calls `nexus_guide` with
`topic: "playbook:<name>"`. Never copy playbook text into a skill; the server's copy is the one that stays current.

Never add `.claude-plugin/plugin.json` to this directory. The MCP server is declared on the marketplace entry
(`../.claude-plugin/marketplace.json`), and Claude Code ignores an entry's `mcpServers` once the plugin has its own
`plugin.json`, so adding one silently disconnects every install. `scripts/check-manifests.sh` fails CI if one appears.
