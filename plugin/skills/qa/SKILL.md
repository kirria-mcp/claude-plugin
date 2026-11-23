---
name: qa
description: Use when QA-testing a Kirria Nexus ticket against its criteria and proof ("QA KEY-12", "what's waiting in testing"). Loads the qa playbook from your Kirria server.
---

Call the Kirria `nexus_guide` tool with `topic: "playbook:qa"` and the workspace's `workspaceId` (`list_workspaces` names it). Pass `have` with any `guide@` ids you already hold so the server skips what you have. Follow the playbook it returns; it is the current procedure, kept on the server.
