import { homedir } from "node:os";
import { basename, resolve } from "node:path";
import { isToolCallEventType, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

const deniedCommands = [
  /\bop\s+(?:read|inject|run)\b/,
  /\bop\s+item\s+(?:get|share)\b/,
  /\bop\s+document\s+get\b/,
];

const gatedTools = new Set([
  "mcp__slack__slack_send_message",
  "mcp__slack__slack_send_message_draft",
  "mcp__slack__slack_schedule_message",
  "mcp__slack__slack_add_reaction",
  "mcp__slack__slack_create_canvas",
  "mcp__slack__slack_update_canvas",
]);

const gatedCommands = [
  /\bgit\b[^;&|\n]*\bpush\b/,
  /\bchmod\b/,
  /\bkill\b/,
  /\bgit\b[^;&|\n]*\breset\b[^;&|\n]*--hard\b/,
  /\bgit\b[^;&|\n]*\bclean\b[^;&|\n]*(?:--force\b|-[a-zA-Z]*f[a-zA-Z]*\b)/,
  /\bgit\b[^;&|\n]*\bbranch\b[^;&|\n]*(?:-D\b|--delete\b[^;&|\n]*--force\b|--force\b[^;&|\n]*--delete\b)/,
  /\brm\s+-rf\b/,
  /\bsudo\b/,
  /\bkubectl\s+(?:apply|delete)\b/,
  /\bterraform\s+(?:apply|destroy)\b/,
  /\bnpm\s+publish\b/,
  /\bdocker\s+push\b/,
  /\b(?:curl|wget)\b[^|]*\|\s*(?:sh|bash)\b/,
  /\bgh\s+pr\s+(?:create|close|comment|edit|lock|unlock|merge|ready|reopen|revert|review|update-branch)\b/,
  /\bgh\s+issue\s+(?:create|close|comment|delete|develop|edit|lock|unlock|pin|unpin|reopen|transfer)\b/,
  /\bgh\s+repo\s+(?:create|archive|delete|edit|fork|rename|sync|unarchive)\b/,
  /\bgh\s+release\s+(?:create|delete|delete-asset|edit|upload)\b/,
  /\bgh\s+gist\s+(?:create|delete|edit|rename)\b/,
  /\bgh\s+workflow\s+(?:disable|enable|run)\b/,
  /\bgh\s+(?:secret|variable)\s+(?:set|delete)\b/,
  /\bgh\s+label\s+(?:create|delete|edit|clone)\b/,
  /\bgh\s+project\s+(?:create|close|copy|delete|edit|field-create|field-delete|item-add|item-archive|item-create|item-delete|item-edit|link|unlink)\b/,
  /\bgh\s+cache\s+delete\b/,
];

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (isToolCallEventType("read", event) && isSensitivePath(event.input.path, ctx.cwd)) {
      return { block: true, reason: `Reading sensitive path is blocked: ${event.input.path}` };
    }

    if (gatedTools.has(event.toolName)) {
      if (!ctx.hasUI) return { block: true, reason: "Tool requires interactive approval" };
      const approved = await ctx.ui.confirm(`Approve ${event.toolName}?`, JSON.stringify(event.input, null, 2));
      if (!approved) return { block: true, reason: "Blocked by user" };
      return;
    }

    if (!isToolCallEventType("bash", event)) return;

    const command = event.input.command;
    if (deniedCommands.some((pattern) => pattern.test(command))) {
      return { block: true, reason: "1Password secret-reading commands are blocked" };
    }

    if (!isGated(command)) return;
    if (!ctx.hasUI) return { block: true, reason: "Command requires interactive approval" };

    const approved = await ctx.ui.confirm("Approve command?", command);
    if (!approved) return { block: true, reason: "Blocked by user" };
  });
}

function isSensitivePath(path: string, cwd: string) {
  const expanded = path.startsWith("~/") ? resolve(homedir(), path.slice(2)) : resolve(cwd, path);
  const name = basename(expanded);
  return name === ".env"
    || name.startsWith(".env.")
    || [".pem", ".key", ".p12", ".pfx", ".jks", ".keystore"].some((extension) => name.endsWith(extension))
    || [".netrc", ".npmrc", ".pypirc"].includes(name)
    || expanded === resolve(homedir(), ".aws/credentials")
    || expanded === resolve(homedir(), ".docker/config.json")
    || expanded === resolve(homedir(), ".kube/config")
    || expanded.startsWith(resolve(homedir(), ".ssh/id_"));
}

function isGated(command: string) {
  if (/\bgh\s+api\b/.test(command) && /(?:-X|--method)(?:=|\s+)["']?(?:POST|PUT|PATCH|DELETE)\b/i.test(command)) {
    return true;
  }
  return gatedCommands.some((pattern) => pattern.test(command));
}
