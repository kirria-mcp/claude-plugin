---
name: release
description: Use when recording a production release in Kirria Nexus ("record the release", "we shipped 1.4 to prod"). Loads the release playbook from your Kirria server.
---

Call the Kirria `nexus_guide` tool with `topic: "playbook:release"` and the workspace's `workspaceId` (`list_workspaces` names it). Pass `have` with any `guide@` ids you already hold so the server skips what you have. Follow the playbook it returns; it is the current procedure, kept on the server.
