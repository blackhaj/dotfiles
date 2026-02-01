#!/usr/bin/env bun

// Link to Readwise API documentation: https://readwise.io/reader_api
// Get an access token from https://readwise.io/access_token

const READWISE_API_URL = "https://readwise.io/api/v3/save/";

type SendHtmlOptions = {
	html: string;
	title?: string;
	source?: string;
	url?: string;
};

type SendUrlOptions = {
	url: string;
	title?: string;
	source?: string;
};

function getAccessToken(): string {
	const token = process.env.READWISE_ACCESS_TOKEN;
	if (!token) {
		throw new Error("READWISE_ACCESS_TOKEN environment variable is required.");
	}
	return token;
}

async function postToReadwise(payload: Record<string, unknown>): Promise<void> {
	const response = await fetch(READWISE_API_URL, {
		method: "POST",
		headers: {
			Authorization: `Token ${getAccessToken()}`,
			"Content-Type": "application/json",
		},
		body: JSON.stringify(payload),
	});

	if (!response.ok) {
		const errorText = await response.text();
		throw new Error(
			`Readwise API error (${response.status} ${response.statusText}): ${errorText}`,
		);
	}
}

export async function sendHtml(options: SendHtmlOptions): Promise<void> {
	const fallbackUrl = `https://readwise.io/read-it-later/${Date.now()}`;
	const payload = {
		html: options.html,
		title: options.title,
		source: options.source,
		url: options.url ?? fallbackUrl,
	};

	await postToReadwise(payload);
}

export async function sendUrl(options: SendUrlOptions): Promise<void> {
	const payload = {
		url: options.url,
		title: options.title,
		source: options.source,
	};

	await postToReadwise(payload);
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
	console.log("Usage:");
	console.log("  readwise.ts url <url> [--title <title>] [--source <source>]");
	console.log(
		"  readwise.ts html <html> [--title <title>] [--source <source>] [--url <url>]",
	);
	console.log(
		"  readwise.ts html --stdin [--title <title>] [--source <source>] [--url <url>]",
	);
}

if (import.meta.main) {
	try {
		const args = process.argv.slice(2);
		const command = args.shift();

		if (!command) {
			printUsage();
			process.exit(1);
		}

		const title = stripOption(args, "--title");
		const source = stripOption(args, "--source");
		const urlOption = stripOption(args, "--url");
		const useStdin = args.includes("--stdin");
		if (useStdin) {
			args.splice(args.indexOf("--stdin"), 1);
		}

		if (command === "url") {
			const url = args[0];
			if (!url) {
				printUsage();
				process.exit(1);
			}
			await sendUrl({ url, title, source });
			console.log("URL sent to Readwise Reader.");
		} else if (command === "html") {
			const html = useStdin ? "" : args.join(" ");
			const resolvedHtml = await readStdinIfEmpty(html);
			if (!resolvedHtml) {
				printUsage();
				process.exit(1);
			}
			await sendHtml({ html: resolvedHtml, title, source, url: urlOption });
			console.log("HTML sent to Readwise Reader.");
		} else {
			printUsage();
			process.exit(1);
		}
	} catch (error) {
		console.error(
			`Error: ${error instanceof Error ? error.message : String(error)}`,
		);
		process.exit(1);
	}
}
