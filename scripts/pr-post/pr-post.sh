#!/bin/zsh

# Prerequisites:
# - fzf needs to be installed
# - gh needs to be installed
# - pr-post.js needs to be next to this script

branch=$(fzfb)

if [[ "$branch" = "" ]]; then
    echo "No branches available. Run command from a valid github repo"
    return
fi

# Get the PR data from Github
pr_data=$(gh pr view --json title,body,files,comments,url $branch)

if [[ $pr_data = "" ]]; then
    echo "Exiting"
    return
fi

# Find current working directory as the node script should be next to it
cwd=(${${(%):-%x}:A:h})

formatted_message=$(node "$cwd/pr-post.js" "$pr_data")

echo "$formatted_message" | pbcopy