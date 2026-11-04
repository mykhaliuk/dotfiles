function opr --description 'Run a command with one scope of 1Password secrets: opr <scope> <command...>'
    set -l env_file $HOME/.config/secrets/$argv[1].env
    if test (count $argv) -lt 2; or not test -r $env_file
        echo "opr: usage: opr <scope> <command...>; scopes are in ~/.config/secrets" >&2
        return 2
    end
    op run --account my.1password.com --env-file=$env_file -- $argv[2..-1]
end
