---
name: post-mortem
description: Use when reviewing a period of retros in Kirria Nexus ("run a post-mortem for last week", "what keeps going wrong in project X"). Loads the post-mortem playbook from your Kirria server.
---

Call the Kirria `nexus_guide` tool with `topic: "playbook:post-mortem"` and the workspace's `workspaceId` (`list_workspaces` names it). Pass `have` with any `guide@` ids you already hold so the server skips what you have. Follow the playbook it returns; it is the current procedure, kept on the server.
