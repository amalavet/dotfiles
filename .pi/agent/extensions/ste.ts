import { join } from "node:path";
import { pathToFileURL } from "node:url";
import {
  getAgentDir,
  getMarkdownTheme,
  type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";
import { Container, Markdown, Text } from "@earendil-works/pi-tui";

export default async function (pi: ExtensionAPI) {
  const path = join(getAgentDir(), "npm/node_modules/agent-ste/extension.mjs");
  const { default: ste } = await import(pathToFileURL(path).href);

  ste({
    ...pi,
    registerTool(tool) {
      if (tool.name !== "say") {
        pi.registerTool(tool);
        return;
      }

      pi.registerTool({
        ...tool,
        renderShell: "self",
        renderCall: () => new Container(),
        renderResult(result, { isPartial }, theme, context) {
          if (isPartial) return new Container();
          if (context.isError) {
            return new Text(theme.fg("error", "STE rejected this reply."), 1, 0);
          }
          const text = result.content
            .filter((part) => part.type === "text")
            .map((part) => part.text)
            .join("\n");
          return new Markdown(text, 1, 0, getMarkdownTheme());
        },
      });
    },
  } satisfies ExtensionAPI);
}
