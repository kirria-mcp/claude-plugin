---
name: work-ticket
description: Use when picking up, building, proving or handing off a Kirria Nexus ticket ("work on KEY-12", "start this ticket", "what should I pick up next"). Loads the work-ticket playbook from your Kirria server.
---

Call the Kirria `nexus_guide` tool with `topic: "playbook:work-ticket"` and the workspace's `workspaceId` (`list_workspaces` names it). Pass `have` with any `guide@` ids you already hold so the server skips what you have. Follow the playbook it returns; it is the current procedure, kept on the server.
