const removeDuplicates = (arr) => [...new Set(arr)];

const getLinearUrls = (comments) =>
	removeDuplicates(
		comments
			.filter((comment) => comment.author.login === "linear")
			?.flatMap(
				(comment) =>
					comment.body.match(
						/https:\/\/(linear\.app)([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])/g,
					) ?? [],
			) ?? [],
	);

const getLoomUrls = (body) =>
	removeDuplicates(
		body.match(
			/https:\/\/(www\.loom\.com)([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])/g,
		) ?? [],
	);

const formatMessage = ({ title, body, files, comments, url }) =>
	`*Review Request*

:artist::skin-tone-3: ${title}
:github: [${files?.length} files changed] ${url} 
${getLinearUrls(comments)
	.map((url) => `:linear: ${url}`)
	.join("\n")}
${getLoomUrls(body)
	.map((url) => `:loom: ${url}`)
	.join("\n")}`;

const message = formatMessage(JSON.parse(process.argv[2]));
process.stdout.write(message);
