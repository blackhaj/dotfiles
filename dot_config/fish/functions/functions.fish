
# Fuzzy Git Checkout. Source: https://polothy.github.io/post/2019-08-19-fzf-git-checkout/
function fuzzy-find-branch
    git rev-parse HEAD >/dev/null 2>&1 || return

    git branch --color=always --sort=-committerdate |
        grep -v HEAD |
        fzf --height 50% --ansi --no-multi |
        sed "s/.* //"
end

function copy-branch
    set branch (fuzzy-find-branch)

    # print -s "$branch"
    echo "$branch" | pbcopy
end

alias ggb=copy-branch

function checkout-branch
    set branch (fuzzy-find-branch)

    # print -s "git checkout $branch"
    git checkout "$branch"
end

alias gcof=checkout-branch

function delete-branch
    set branch (fuzzy-find-branch)

    # print -s "git branch -d $branch"
    git branch -d "$branch"
end

alias gdf=delete-branch

function delete-branch-force
    set branch (fuzzy-find-branch)

    # print -s "git branch -D $branch"
    git branch -D "$branch"
end

alias gDf=delete-branch-force

function use-scripts
    if [ -f pnpm-lock.json ]
        set packageManager pnpm
    else if [ -f package-lock.json ]
        set packageManager npm
    else if [ -f bun.lock ]
        set packageManager bun
    else if [ -f yarn.lock ]
        set packageManager yarn
    end

    set sc (cat package.json | jq '.scripts | keys[]' | tr -d '\"' | fzf)

    if [ $status = 0 ]
        $packageManager run "$sc"
    end
end


alias sc=use-scripts

function nuke_pnpm
    rm -rf ~/.pnpm-store && pnpm -r exec rm -rf node_modules build dist lib && rm -rf node_modules apps/maze-webapp/public/ && pnpm i && say ready
end


function change_ts_hint_length
    # Add your VScode path here
    set directory_path "/Applications/Visual Studio Code.app"
    set new_length "$argv[1]"

    if test -z "$argv[1]"
        echo "No length supplied, will use default (160)"
        set new_length 160
    end

    set file_path (find "$directory_path" -name "tsserver.js" 2>/dev/null)
    if test -z "$file_path"
        echo "tsserver.js file not found within directory $directory_path after recursive search"
        exit 1
    end

    # echo "Found tsserver.js at \"$file_path\""

    # Use awk to perform the replacement
    awk -v new_length="$new_length" '{sub(/var defaultMaximumTruncationLength = [0-9]+;/, "var defaultMaximumTruncationLength = " new_length ";")}1' "$file_path" >temp_file && sudo mv temp_file "$file_path"

    echo "Length updated successfully: "
    cat "$file_path" | grep "defaultMaximumTruncationLength = "
end

alias tslen="change_ts_hint_length"

function git_prune_squash_merged
    # Get a list of all current branches
    git for-each-ref refs/heads/ "--format=%(refname:short)" | while read branch
        # Get the merge-base between main and the current branch
        set mergeBase (git merge-base origin/main "$branch")
        # Get the commit-tree for the current branch
        set commitTree (git commit-tree $(git rev-parse "$branch^{tree}") -p "$mergeBase" -m _)
        # If the commit-tree is not empty, then the branch is not merged
        if [ (git cherry origin/main "$commitTree") = "-"* ]
            then
            # Delete the branch
            git branch -D "$branch"
        end
    end
end

alias gsdall="git_prune_squash_merged"
