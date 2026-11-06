test -x /opt/homebrew/bin/brew; and eval (/opt/homebrew/bin/brew shellenv)

source $__fish_config_dir/cleanpath.fish
source $__fish_config_dir/envvars.fish
source $__fish_config_dir/aliases.fish

if status is-interactive
    # ~/.local/bin leaves PATH before activation and returns in front after it:
    # mise's cd hook re-prepends its paths over every pre-activation entry
    # resolve mise first: on Fedora it lives in ~/.local/bin
    set -l mise_bin (command -s mise)
    set -l lb (contains -i -- $HOME/.local/bin $PATH); and set -e PATH[$lb]
    $mise_bin activate fish | source
    set -gx PATH $HOME/.local/bin $PATH
    # the GitHub MCP plugin and ~/.npmrc expand these from the environment
    if set -l gh_token (gh auth token 2>/dev/null)
        set -gx GITHUB_PERSONAL_ACCESS_TOKEN $gh_token
        set -gx GITHUB_TOKEN $gh_token
    end
    set -g fish_complete_path $fish_complete_path[1..-2] $HOME/.local/share/mise-completions/fish $fish_complete_path[-1]
    starship init fish | source
    fish_vi_key_bindings
    fzf --fish | source
    zoxide init fish | source
    alias cat "bat --paging=never"
    if command -q mole
        mole completion fish 2>/dev/null | source
    end
end
