###-begin-pnpm-completion-###
function _pnpm_completion
    set cmd (commandline -o)
    set cursor (commandline -C)
    set words (count $cmd)

    # Add package.json script completions for 'run' command <-- pnpm part
    if test "$words" = 2; and test "$cmd[2]" = run
        if test -f "./package.json"
            command jq -r '.scripts | to_entries | .[] | "\(.key)\t\(.value)"' package.json 2>/dev/null
            return
        end
    end

    # Add package.json script completions when just 'pnpm' is typed <-- pnpm part
    if test "$words" = 1
        if test -f "./package.json"
            command jq -r '.scripts | keys[] | . + "\tpackage.json script"' package.json 2>/dev/null
        end
    end

    set completions (eval env DEBUG=\"" \"" COMP_CWORD=\""$words\"" COMP_LINE=\""$cmd \"" COMP_POINT=\""$cursor\"" SHELL=fish pnpm completion-server -- $cmd)

    if [ "$completions" = __tabtab_complete_files__ ]
        set -l matches (commandline -ct)*
        if [ -n "$matches" ]
            __fish_complete_path (commandline -ct)
        end
    else
        for completion in $completions
            echo -e $completion
        end
    end
end

complete -f -d pnpm -c pnpm -a "(_pnpm_completion)"
###-end-pnpm-completion-###
