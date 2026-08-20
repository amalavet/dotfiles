import { homedir } from "node:os";
import { basename, resolve } from "node:path";
import { isToolCallEventType, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

type CommandRule = {
  all: string[];
  any?: string[];
};

const gatedTools = new Set([
  "mcp__slack__slack_send_message",
  "mcp__slack__slack_send_message_draft",
  "mcp__slack__slack_schedule_message",
  "mcp__slack__slack_add_reaction",
  "mcp__slack__slack_create_canvas",
  "mcp__slack__slack_update_canvas",
]);

const gatedCommands: CommandRule[] = [
  { all: ["op"] },
  { all: ["git", "push"] },
  { all: ["chmod"] },
  { all: ["kill"] },
  { all: ["git", "reset", "--hard"] },
  { all: ["git", "clean"] },
  { all: ["git", "branch", "-d"] },
  { all: ["rm", "-rf"] },
  { all: ["sudo"] },
  { all: ["kubectl"], any: ["apply", "delete"] },
  { all: ["terraform"], any: ["apply", "destroy"] },
  { all: ["npm", "publish"] },
  { all: ["docker", "push"] },
  { all: ["curl", "|"], any: ["sh", "bash"] },
  { all: ["wget", "|"], any: ["sh", "bash"] },
  { all: ["gh", "pr"], any: ["create", "close", "comment", "edit", "lock", "unlock", "merge", "ready", "reopen", "revert", "review", "update-branch"] },
  { all: ["gh", "issue"], any: ["create", "close", "comment", "delete", "develop", "edit", "lock", "unlock", "pin", "unpin", "reopen", "transfer"] },
  { all: ["gh", "repo"], any: ["create", "archive", "delete", "edit", "fork", "rename", "sync", "unarchive"] },
  { all: ["gh", "release"], any: ["create", "delete", "delete-asset", "edit", "upload"] },
  { all: ["gh", "gist"], any: ["create", "delete", "edit", "rename"] },
  { all: ["gh", "workflow"], any: ["disable", "enable", "run"] },
  { all: ["gh", "set"], any: ["secret", "variable"] },
  { all: ["gh", "delete"], any: ["secret", "variable"] },
  { all: ["gh", "label"], any: ["create", "delete", "edit", "clone"] },
  { all: ["gh", "project"], any: ["create", "close", "copy", "delete", "edit", "field-create", "field-delete", "item-add", "item-archive", "item-create", "item-delete", "item-edit", "link", "unlink"] },
  { all: ["gh", "cache", "delete"] },
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

    if (event.toolName !== "bash") return;

    const command = event.input.command as string;
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
  const parts = command.toLowerCase().match(/\||[^\s;&|]+/g) ?? [];
  if (parts.includes("gh") && parts.includes("api")
    && ["post", "put", "patch", "delete"].some((method) => parts.includes(method))) {
    return true;
  }
  return matchesCommand(parts, gatedCommands);
}

function matchesCommand(parts: string[], rules: CommandRule[]) {
  return rules.some(({ all, any }) =>
    all.every((part) => parts.includes(part))
      && (!any || any.some((part) => parts.includes(part)))
  );
}
