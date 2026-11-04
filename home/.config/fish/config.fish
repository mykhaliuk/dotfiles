test -x /opt/homebrew/bin/brew; and eval (/opt/homebrew/bin/brew shellenv)

source $__fish_config_dir/cleanpath.fish
source $__fish_config_dir/envvars.fish
source $__fish_config_dir/aliases.fish

if status is-interactive
    # ~/.local/bin leaves PATH before activation and returns in front after it:
    # mise's cd hook re-prepends its paths over every pre-activation entry
    set -l lb (contains -i -- $HOME/.local/bin $PATH); and set -e PATH[$lb]
    mise activate fish | source
    set -gx PATH $HOME/.local/bin $PATH
    # the GitHub MCP plugin expands this from the environment of Claude Code
    set -l gh_token (gh auth token 2>/dev/null); and set -gx GITHUB_PERSONAL_ACCESS_TOKEN $gh_token
    set -g fish_complete_path $fish_complete_path[1..-2] $HOME/.local/share/mise-completions/fish $fish_complete_path[-1]
    starship init fish | source
    fish_vi_key_bindings
    fzf --fish | source
    zoxide init fish | source
    alias cat "bat --paging=never"
    set -l mole_completion (mole completion fish 2>/dev/null); and echo "$mole_completion" | source
end
