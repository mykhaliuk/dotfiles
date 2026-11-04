# GH CLI Actions searcher/previewer
function ghrns
    set -x GH_FORCE_TTY 100%
    gh run list | fzf --ansi --reverse --delimiter '  +' --preview "set -x GH_FORCE_TTY 100%; gh run view (echo {6})" --preview-window down | awk -F '  +' '{print $6}' | xargs gh run watch
end
