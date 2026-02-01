#!/usr/bin/env bun

import { sendHtml } from "./readwise";

type BunMarkdown = {
  html: (markdown: string) => string;
};

const bunMarkdown = (Bun as typeof Bun & { markdown?: BunMarkdown }).markdown;
if (!bunMarkdown?.html) {
  console.error("Error: Bun.markdown.html is not available. Requires Bun v1.3.8 or newer.");
  process.exit(1);
}

function stripOption(args: string[], option: string): string | undefined {
  const index = args.indexOf(option);
  if (index !== -1 && args[index + 1]) {
    const value = args[index + 1];
    args.splice(index, 2);
    return value;
  }
  return undefined;
}

async function readStdinIfEmpty(value: string): Promise<string> {
  if (value.trim()) {
    return value;
  }
  const stdinText = await Bun.stdin.text();
  return stdinText.trim();
}

function printUsage(): void {
  console.log("Usage: send-markdown.ts <markdown> [--title <title>] [--source <source>] [--url <url>]");
  console.log("       send-markdown.ts --stdin [--title <title>] [--source <source>] [--url <url>]");
}

try {
  const args = process.argv.slice(2);
  const title = stripOption(args, "--title");
  const source = stripOption(args, "--source");
  const url = stripOption(args, "--url");
  const useStdin = args.includes("--stdin");
  if (useStdin) {
    args.splice(args.indexOf("--stdin"), 1);
  }

  const markdownInput = useStdin ? "" : args.join(" ");
  const resolvedMarkdown = await readStdinIfEmpty(markdownInput);

  if (!resolvedMarkdown) {
    printUsage();
    process.exit(1);
  }

  const html = bunMarkdown.html(resolvedMarkdown);

  await sendHtml({ html, title, source, url });
  console.log("Markdown sent to Readwise Reader.");
} catch (error) {
  console.error(`Error: ${error instanceof Error ? error.message : String(error)}`);
  process.exit(1);
}
