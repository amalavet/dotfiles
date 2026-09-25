import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { resolve } from "node:path";

export default function (pi: ExtensionAPI) {
	const tab = process.env.HERDR_TAB_ID;
	if (!tab) return;
	const sock = `/tmp/nvim-herdr-${tab.replace(/[^\w]/g, "_")}.sock`;
	const send = (expr: string) => pi.exec("nvim", ["--server", sock, "--remote-expr", expr]).catch(() => {});
	const ping = () => send("execute('let g:pi_follow_seen = localtime()')");
	let timer: ReturnType<typeof setInterval> | undefined;

	pi.on("session_start", async () => {
		ping();
		timer ??= setInterval(ping, 5000);
		timer.unref?.();
	});

	pi.on("session_shutdown", async () => {
		clearInterval(timer);
		timer = undefined;
		await send("execute('let g:pi_follow_seen = 0')");
	});

	pi.on("tool_result", async (event, ctx) => {
		if (event.isError || (event.toolName !== "edit" && event.toolName !== "write")) return;
		const path = resolve(ctx.cwd, String(event.input.path)).replace(/'/g, "''");
		await send(`get(g:, 'pi_follow', v:true) ? execute(['drop ' . fnameescape('${path}'), 'checktime']) : ''`);
	});
}
