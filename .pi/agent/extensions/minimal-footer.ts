import { existsSync, readFileSync, unwatchFile, watchFile } from "node:fs";
import { join } from "node:path";
import type { AssistantMessage } from "@earendil-works/pi-ai";
import { getAgentDir, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { wrapTextWithAnsi } from "@earendil-works/pi-tui";

function formatTokens(tokens: number): string {
  if (tokens < 1_000) return `${tokens}`;
  if (tokens < 10_000) return `${(tokens / 1_000).toFixed(1)}k`;
  if (tokens < 1_000_000) return `${Math.round(tokens / 1_000)}k`;
  return `${(tokens / 1_000_000).toFixed(1)}M`;
}

export default function (pi: ExtensionAPI) {
  let requestRender: (() => void) | undefined;

  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;

    ctx.ui.setFooter((tui, theme, footerData) => {
      const requestFooterRender = () => tui.requestRender();
      const unsubscribe = footerData.onBranchChange(requestFooterRender);
      requestRender = requestFooterRender;
      const fastConfigPaths = [
        join(getAgentDir(), "extensions", "pi-openai-fast.json"),
        join(ctx.cwd, ".pi", "extensions", "pi-openai-fast.json"),
      ];
      let fastConfig: { active?: boolean; supportedModels?: string[] } | undefined;
      const refreshFastConfig = () => {
        try {
          fastConfig = Object.assign({}, ...fastConfigPaths.map((path) =>
            existsSync(path) ? JSON.parse(readFileSync(path, "utf8")) : {},
          ));
        } catch {
          fastConfig = undefined;
        }
        requestFooterRender();
      };
      refreshFastConfig();
      for (const path of fastConfigPaths) {
        watchFile(path, { persistent: false, interval: 500 }, refreshFastConfig);
      }

      return {
        dispose() {
          unsubscribe();
          for (const path of fastConfigPaths) unwatchFile(path, refreshFastConfig);
          if (requestRender === requestFooterRender) requestRender = undefined;
        },
        invalidate() {},
        render(width: number): string[] {
          let input = 0;
          let output = 0;
          let cost = 0;
          for (const entry of ctx.sessionManager.getBranch()) {
            if (entry.type !== "message" || entry.message.role !== "assistant")
              continue;
            const usage = (entry.message as AssistantMessage).usage;
            input += usage.input;
            output += usage.output;
            cost += usage.cost.total;
          }

          const thinking = pi.getThinkingLevel();
          const model = `${ctx.model?.id ?? "no-model"}${thinking === "off" ? "" : `/${thinking}`}`;
          const context = ctx.getContextUsage();
          const contextPercent =
            context?.percent == null ? "?" : `${context.percent.toFixed(1)}%`;
          const contextWindow =
            context?.contextWindow ?? ctx.model?.contextWindow ?? 0;
          const dim = (text: string) => theme.fg("dim", text);
          let fast = "?";
          if (fastConfig?.active === false) fast = "off";
          if (fastConfig?.active === true && Array.isArray(fastConfig.supportedModels)) {
            fast = fastConfig.supportedModels.includes(`${ctx.model?.provider}/${ctx.model?.id}`)
              ? "on"
              : "n/a";
          }
          const segments = [
            dim(`↑${formatTokens(input)} ↓${formatTokens(output)}`),
            theme.fg("success", `$${cost.toFixed(2)}`),
            dim(`${contextPercent}/${formatTokens(contextWindow)}`),
            dim(model),
            theme.fg(fast === "on" ? "success" : "dim", `fast:${fast}`),
          ];
          return wrapTextWithAnsi(segments.filter(Boolean).join("  "), width);
        },
      };
    });
  });

  pi.on("model_select", () => requestRender?.());
  pi.on("thinking_level_select", () => requestRender?.());
  pi.on("message_end", () => requestRender?.());
}
