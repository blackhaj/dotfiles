# Shell functions

# Add a command to the active shell's history.
unifiedAddHistory() {
	local command

	if [[ $# -eq 0 ]]; then
		print -u2 -- "Usage: unifiedAddHistory <command>"
		return 1
	fi

	command="$*"

	if [[ -n "${ZSH_VERSION-}" ]]; then
		print -s -- "$command"
	elif [[ -n "${BASH_VERSION-}" ]]; then
		history -s "$command"
	else
		print -u2 -- "unifiedAddHistory: unsupported shell"
		return 1
	fi
}

# Fuzzy find a git branch.
fzfb() {
	git rev-parse HEAD >/dev/null 2>&1 || return 1

	git branch --color=always --sort=-committerdate |
		grep -v HEAD |
		fzf --height 50% --ansi --no-multi |
		sed "s/.* //"
}

# Delete all local git branches except main.
gdall() {
	git branch | grep -v ' main$' | xargs git branch -d
}

# Fuzzy find and checkout a git branch.
gcof() {
	local branch

	branch=$(fzfb) || return

	unifiedAddHistory "git checkout $branch"
	git checkout "$branch"
}

# Fuzzy find and delete a git branch.
gdf() {
	local branch

	branch=$(fzfb) || return

	unifiedAddHistory "git branch -d $branch"
	git branch -d "$branch"
}

# Fuzzy find and delete a git branch forcefully.
gdff() {
	local branch

	branch=$(fzfb) || return

	unifiedAddHistory "git branch -D $branch"
	git branch -D "$branch"
}

# Fuzzy find and copy a git branch to clipboard.
ggb() {
	local branch

	branch=$(fzfb) || return

	unifiedAddHistory "$branch"
	echo "$branch" | pbcopy
}

# Get the audio bitrate for a media file.
getbitrate() {
	ffprobe -v error -select_streams a:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 "$1" | awk '{print $1/1000 " kbs"}'
}

# Get a song from YouTube and save it to the music inbox.
getsong() {
	yt-dlp -x \
		--audio-format m4a \
		--audio-quality 0 \
		--embed-thumbnail \
		--add-metadata \
		--parse-metadata "title:%(title)s" \
		--parse-metadata "artist:%(uploader)s" \
		-o "${MUSIC_INBOX}/%(title)s.%(ext)s" \
		"$@"
}

# Kills all processes on Maze ports.
kill-maze() {
	local -a PORTS=(
		11700
		11701
		15025
		16233
		3005
		3006
		3007
		3014
		3020
		4000
		6002
		6003
		6010
		6060
		7860
		8000
		8001
		8002
		8003
		8004
		8080
		9000
	)

	local PORT PIDS

	for PORT in "${PORTS[@]}"; do
		PIDS=$(lsof -ti tcp:"$PORT" || true)
		if [ -n "$PIDS" ]; then
			echo "Killing processes on port $PORT: $PIDS"
			kill -9 $PIDS
		else
			echo "No process running on port $PORT"
		fi
	done

	echo "Done"
}

# Fuzzy find and run a package.json script with the correct package manager.
sc() {
	local repo_root package_manager selected_script

	repo_root=$(git rev-parse --show-toplevel 2>/dev/null)

	if [[ -f pnpm-lock.yaml ]]; then
		package_manager="pnpm"
	elif [[ -n "$repo_root" && -f "$repo_root/pnpm-lock.yaml" ]]; then
		package_manager="pnpm"
	elif [[ -f package-lock.json ]]; then
		package_manager="npm"
	elif [[ -n "$repo_root" && -f "$repo_root/bun.lock" ]]; then
		package_manager="bun"
	elif [[ -f yarn.lock ]]; then
		package_manager="yarn"
	fi

	selected_script=$(jq '.scripts | keys[]' package.json | tr -d '"' | fzf) || return

	unifiedAddHistory "$package_manager run $selected_script"
	"$package_manager" run "$selected_script"
}

# Fuzzy project directory navigator and change into the selected directory.
try() {
	local dir
	dir=$(command try "$@") && cd "$dir"
}

# zsh wrapper for `wt` so directory changes happen in the parent shell.
# The `wt` binary prints `cd ...` commands, which can only take effect
# when executed by a shell function (not when running as a plain external command).
wt() {
	local worktree_root="${WORKTREE_ROOT:-$HOME/worktrees}"
	local wt_binary="${WT_BACKEND:-${HOME}/bin/wt}"
	local wt_output wt_exit_code

	if [[ ! -x "$wt_binary" ]]; then
		print -u2 -- "wt: backend binary not found or not executable"
		return 127
	fi

	if [[ "$PWD" == "$worktree_root"/* ]]; then
		mkdir -p "$worktree_root"
		echo "$PWD" >"$worktree_root/.workout_prev"
	fi

	wt_output="$("$wt_binary" "$@")"
	wt_exit_code=$?
	if (( wt_exit_code == 0 )); then
		if [[ "$wt_output" == cd\ * ]]; then
			eval -- "$wt_output"
		else
			print -r -- "$wt_output"
		fi
	fi
	return "$wt_exit_code"
}
