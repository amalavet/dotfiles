import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isBashToolResult, isToolCallEventType } from "@earendil-works/pi-coding-agent";

const LIMIT = 20;

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event) => {
		if (!isToolCallEventType("bash", event)) return;
		event.input.timeout = Math.min(event.input.timeout ?? LIMIT, LIMIT);
	});

	pi.on("tool_result", async (event) => {
		if (!isBashToolResult(event) || !event.isError) return;
		const text = event.content.map((c) => (c.type === "text" ? c.text : "")).join("");
		if (!text.includes("Command timed out after")) return;
		return {
			content: [
				...event.content,
				{ type: "text", text: `Killed after ${LIMIT}s. Always run long running commands using the pi-processes tool.` },
			],
		};
	});
}
