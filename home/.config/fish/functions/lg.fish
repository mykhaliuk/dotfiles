# Follow the LazyGit project/worktree on exit
function lg
    set -l dir_file "/tmp/lazygit-dir-$fish_pid"
    rm -f -- "$dir_file"

    env LAZYGIT_NEW_DIR_FILE="$dir_file" lazygit $argv

    if test -s "$dir_file"
        set -l target_dir (string collect < "$dir_file")
        rm -f -- "$dir_file"

        if test -d "$target_dir"
            cd -- "$target_dir"
        end
    end
end
