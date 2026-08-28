import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { wrapTextWithAnsi } from "@earendil-works/pi-tui";
import { basename } from "node:path";

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

			return {
				dispose() {
					unsubscribe();
					if (requestRender === requestFooterRender) requestRender = undefined;
				},
				invalidate() {},
				render(width: number): string[] {
					let input = 0;
					let output = 0;
					let cost = 0;
					for (const entry of ctx.sessionManager.getBranch()) {
						if (entry.type !== "message" || entry.message.role !== "assistant") continue;
						const usage = (entry.message as AssistantMessage).usage;
						input += usage.input;
						output += usage.output;
						cost += usage.cost.total;
					}

					const directory = basename(ctx.cwd);
					const branch = footerData.getGitBranch();
					const location = branch ? `${directory} (${branch})` : directory;
					const thinking = pi.getThinkingLevel();
					const model = `${ctx.model?.id ?? "no-model"}${thinking === "off" ? "" : `/${thinking}`}`;
					const context = ctx.getContextUsage();
					const contextPercent = context?.percent == null ? "?" : `${context.percent.toFixed(1)}%`;
					const contextWindow = context?.contextWindow ?? ctx.model?.contextWindow ?? 0;
					const cavemanEnabled = Boolean(footerData.getExtensionStatuses().get("caveman")?.trim());
					const dim = (text: string) => theme.fg("dim", text);
					const segments = [
						dim(location),
						dim(model),
						dim(`↑${formatTokens(input)} ↓${formatTokens(output)}`),
						theme.fg("success", `$${cost.toFixed(2)}`),
						dim(`${contextPercent}/${formatTokens(contextWindow)}`),
						cavemanEnabled ? dim("🪨") : undefined,
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
