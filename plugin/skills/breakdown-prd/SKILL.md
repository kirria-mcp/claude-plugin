---
name: breakdown-prd
description: Use when turning a published Kirria Nexus PRD into tickets ("break down this PRD", "make tickets from the spec"). Loads the breakdown-prd playbook from your Kirria server.
---

Call the Kirria `nexus_guide` tool with `topic: "playbook:breakdown-prd"` and the workspace's `workspaceId` (`list_workspaces` names it). Pass `have` with any `guide@` ids you already hold so the server skips what you have. Follow the playbook it returns; it is the current procedure, kept on the server.
