import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { resolve } from "node:path";

export default function (pi: ExtensionAPI) {
	const tab = process.env.HERDR_TAB_ID;
	if (!tab) return;
	const sock = `/tmp/nvim-herdr-${tab.replace(/[^\w]/g, "_")}.sock`;
	const send = (expr: string) => pi.exec("nvim", ["--server", sock, "--remote-expr", expr]).catch(() => {});
	const quote = (s: string) => `'${s.replace(/'/g, "''")}'`;
	const files = new Set<string>();
	const ping = () => send(`v:lua.PiFollowSync([${[...files].map(quote).join(",")}])`);
	let timer: ReturnType<typeof setInterval> | undefined;

	const rebuild = (ctx: ExtensionContext) => {
		files.clear();
		for (const entry of ctx.sessionManager.getBranch()) {
			if (entry.type !== "message" || entry.message.role !== "assistant") continue;
			for (const part of entry.message.content) {
				if (part.type === "toolCall" && (part.name === "edit" || part.name === "write")) {
					files.add(resolve(ctx.cwd, String(part.arguments.path)));
				}
			}
		}
	};

	pi.on("session_start", async (_event, ctx) => {
		rebuild(ctx);
		ping();
		timer ??= setInterval(ping, 5000);
		timer.unref?.();
	});

	pi.on("session_tree", async (_event, ctx) => {
		rebuild(ctx);
		ping();
	});

	pi.on("session_shutdown", async () => {
		clearInterval(timer);
		timer = undefined;
		await send("execute('let g:pi_follow_seen = 0')");
	});

	pi.on("tool_result", async (event, ctx) => {
		if (event.isError || (event.toolName !== "edit" && event.toolName !== "write")) return;
		const path = resolve(ctx.cwd, String(event.input.path));
		files.add(path);
		await send(`v:lua.PiFollowOpen(${quote(path)})`);
		ping();
	});
}
