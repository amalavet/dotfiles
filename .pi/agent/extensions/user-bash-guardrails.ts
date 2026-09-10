import { readFileSync } from "node:fs";
import { join } from "node:path";
import { getAgentDir, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

type Pattern = {
  pattern: string;
  description?: string;
  regex?: boolean;
};

type Config = {
  enabled?: boolean;
  features?: { permissionGate?: boolean };
  permissionGate?: {
    requireConfirmation?: boolean;
    patterns?: Pattern[];
    allowedPatterns?: Pattern[];
    autoDenyPatterns?: Pattern[];
  };
};

function findMatch(command: string, patterns: Pattern[] = []): Pattern | undefined {
  return patterns.find(({ pattern, regex }) => {
    if (!regex) return command.includes(pattern);
    try {
      return new RegExp(pattern).test(command);
    } catch {
      return false;
    }
  });
}

function blocked(output: string) {
  return { result: { output, exitCode: 126, cancelled: false, truncated: false } };
}

export default function (pi: ExtensionAPI) {
  pi.on("user_bash", async (event, ctx) => {
    const path = join(getAgentDir(), "extensions", "guardrails.json");
    const config = JSON.parse(readFileSync(path, "utf8")) as Config;
    const gate = config.permissionGate;
    if (config.enabled === false || config.features?.permissionGate === false || !gate) return;
    if (findMatch(event.command, gate.allowedPatterns)) return;

    const denied = findMatch(event.command, gate.autoDenyPatterns);
    if (denied) return blocked(`Guardrails denied this command: ${denied.description ?? denied.pattern}`);

    const dangerous = findMatch(event.command, gate.patterns);
    if (!dangerous) return;

    const reason = dangerous.description ?? dangerous.pattern;
    if (gate.requireConfirmation === false) {
      ctx.ui.notify(`Dangerous command detected: ${reason}`, "warning");
      return;
    }
    if (!ctx.hasUI) return blocked(`Guardrails blocked this dangerous command: ${reason}`);

    const choice = await ctx.ui.select(
      `Dangerous command: ${reason}`,
      ["Allow once", "Deny"],
    );
    if (choice !== "Allow once") return blocked("You denied this command.");
  });
}
