import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const approveTools = [
  "mcp__slack__slack_send_message",
  "mcp__slack__slack_send_message_draft",
  "mcp__slack__slack_schedule_message",
  "mcp__slack__slack_add_reaction",
  "mcp__slack__slack_create_canvas",
  "mcp__slack__slack_update_canvas",
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
