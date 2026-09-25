import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { SessionManager } from "@earendil-works/pi-coding-agent";
import { existsSync, readdirSync, statSync } from "node:fs";
import { homedir } from "node:os";
import { join, resolve } from "node:path";

const roots = ["~/GitHub", "~/GitHub/Personal", "~"];
const home = homedir();
const expand = (p: string) => p.replace(/^~(?=$|\/)/, home);
const tilde = (p: string) => (p.startsWith(home) ? `~${p.slice(home.length)}` : p);

function repos(): string[] {
	const found = new Set<string>();
	for (const root of roots.map(expand)) {
		let names: string[] = [];
		try {
			names = readdirSync(root);
		} catch {
			continue;
		}
		for (const name of names) {
			const dir = join(root, name);
			if (existsSync(join(dir, ".git"))) found.add(tilde(dir));
		}
	}
	return [...found].sort();
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("cwd", {
		description: "Move session to another directory",
		getArgumentCompletions: (prefix) => {
			const q = prefix.toLowerCase();
			return repos()
				.filter((r) => r.toLowerCase().includes(q))
				.map((r) => ({ value: r, label: r }));
		},
		handler: async (args, ctx) => {
			const source = ctx.sessionManager.getSessionFile();
			if (!source || !existsSync(source)) {
				ctx.ui.notify("No saved session to move", "error");
				return;
			}
			const picked = args.trim() || (await ctx.ui.select(`Move session from ${tilde(ctx.cwd)}`, repos()));
			if (!picked) return;
			const target = resolve(ctx.cwd, expand(picked));
			if (!statSync(target, { throwIfNoEntry: false })?.isDirectory()) {
				ctx.ui.notify(`Not a directory: ${picked}`, "error");
				return;
			}
			if (target === ctx.cwd) return;
			await ctx.waitForIdle();
			const file = SessionManager.forkFrom(source, target).getSessionFile();
			if (file) await ctx.switchSession(file);
		},
	});
}
