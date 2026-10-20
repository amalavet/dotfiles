import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const approveTools = [
  "mcp__slack__slack_send_message",
  "mcp__slack__slack_send_message_draft",
  "mcp__slack__slack_schedule_message",
  "mcp__slack__slack_add_reaction",
  "mcp__slack__slack_create_canvas",
  "mcp__slack__slack_update_canvas",
  "mcp__github__add_comment_to_pending_review",
  "mcp__github__add_issue_comment",
  "mcp__github__add_reply_to_pull_request_comment",
  "mcp__github__assign_copilot_to_issue",
  "mcp__github__create_branch",
  "mcp__github__create_or_update_file",
  "mcp__github__create_pull_request",
  "mcp__github__create_pull_request_with_copilot",
  "mcp__github__create_repository",
  "mcp__github__delete_file",
  "mcp__github__fork_repository",
  "mcp__github__issue_write",
  "mcp__github__merge_pull_request",
  "mcp__github__pull_request_review_write",
  "mcp__github__push_files",
  "mcp__github__request_copilot_review",
  "mcp__github__sub_issue_write",
  "mcp__github__update_issue_comment",
  "mcp__github__update_pull_request",
  "mcp__github__update_pull_request_branch",
];

export default function (pi: ExtensionAPI) {
  const approved = new Set<string>();

  pi.on("tool_call", async (event, ctx) => {
    if (!approveTools.includes(event.toolName) || approved.has(event.toolName)) return;
    if (!ctx.hasUI) return { block: true, reason: `${event.toolName} requires approval` };

    const choice = await ctx.ui.select(
      `Allow ${event.toolName}?\n\n${JSON.stringify(event.input, null, 2)}`,
      ["Allow once", "Allow for session", "Deny"],
    );
    if (choice === "Allow for session") approved.add(event.toolName);
    if (choice !== "Allow once" && choice !== "Allow for session") {
      return { block: true, reason: "You denied this tool call." };
    }
  });
}
