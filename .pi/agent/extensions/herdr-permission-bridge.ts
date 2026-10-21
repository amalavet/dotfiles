import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  const open = new Set<string>();

  pi.events.on("permissions:ui_prompt", (raw: any) => {
    if (typeof raw?.requestId !== "string") return;
    if (open.size === 0) {
      const label = [raw.surface, raw.value].filter(Boolean).join(": ");
      pi.events.emit("herdr:blocked", { active: true, label: label || "permission prompt" });
    }
    open.add(raw.requestId);
  });

  pi.events.on("permissions:decision", (raw: any) => {
    if (!open.delete(raw?.requestId)) return;
    if (open.size === 0) pi.events.emit("herdr:blocked", { active: false });
  });
}
