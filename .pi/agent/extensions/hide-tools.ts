import { AssistantMessageComponent, type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Box, type Component, Spacer, Text } from "@earendil-works/pi-tui";

let hidden = false;
const originals = new WeakMap<Component, Component>();
const invalidators = new Map<string, () => void>();
const messages = new Set<any>();
const proto = AssistantMessageComponent.prototype as any;
const updateContent = proto.updateContent;

function wrap(inner: Component, shown: Component): Component {
  const outer: Component = {
    render: (width) => (hidden ? [] : shown.render(width)),
    invalidate: () => shown.invalidate(),
  };
  originals.set(outer, inner);
  return outer;
}

function frame(theme: any, context: any, children: Component[]): Box {
  const bg = context.isPartial ? "toolPendingBg" : context.isError ? "toolErrorBg" : "toolSuccessBg";
  const box = new Box(context.outputPad, 0, (text: string) => theme.bg(bg, text));
  for (const child of children) box.addChild(child);
  return box;
}

function unwrap(context: any): any {
  invalidators.set(context.toolCallId, context.invalidate);
  return { ...context, lastComponent: context.lastComponent && originals.get(context.lastComponent) };
}

function toggle(ctx: ExtensionContext) {
  hidden = !hidden;
  for (const invalidate of invalidators.values()) invalidate();
  for (const message of messages) message.updateContent(message.lastMessage);
  ctx.ui.notify(hidden ? "Tools and thinking hidden" : "Tools and thinking shown", "info");
}

export default function (pi: ExtensionAPI) {
  proto.updateContent = function (message: any, ...rest: any[]) {
    messages.add(this);
    const shown = hidden ? { ...message, content: message.content.filter((c: any) => c.type !== "thinking") } : message;
    updateContent.call(this, shown, ...rest);
    this.lastMessage = message;
  };
  pi.on("session_shutdown", () => {
    proto.updateContent = updateContent;
    messages.clear();
  });

  pi.registerToolRenderer((toolName, next) => {
    const base = next();
    const framed = base?.renderShell !== "self";
    return {
      renderShell: "self",
      renderCall: (args, theme, context) => {
        const inner = base?.renderCall
          ? base.renderCall(args, theme, unwrap(context))
          : new Text(theme.fg("toolTitle", theme.bold(toolName)), 0, 0);
        return wrap(inner, framed ? frame(theme, context, [new Spacer(1), inner]) : inner);
      },
      renderResult: (result, options, theme, context) => {
        const text = result.content.flatMap((c: any) => (c.type === "text" ? [c.text] : [])).join("\n");
        const inner = base?.renderResult
          ? base.renderResult(result, options, theme, unwrap(context))
          : new Text(theme.fg("toolOutput", options.expanded ? text : text.split("\n").slice(0, 10).join("\n")), 0, 0);
        return wrap(inner, framed ? frame(theme, context, [inner, new Spacer(1)]) : inner);
      },
    };
  });

  pi.registerCommand("hide", { description: "Hide or show tools and thinking", handler: (_args, ctx) => toggle(ctx) });
}
