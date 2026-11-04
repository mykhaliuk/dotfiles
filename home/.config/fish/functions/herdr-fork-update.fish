function herdr-fork-update --description 'Merge upstream herdr into the fork master, test, build, install and live-handoff'
    argparse h/help skip-tests rollback -- $argv
    or return 2

    if not set -q PERSONAL_PROJECTS_DIR
        echo "herdr-fork-update: set PERSONAL_PROJECTS_DIR first" >&2
        return 2
    end
    set -l repo $PERSONAL_PROJECTS_DIR/herdr
    set -l bin ~/.local/bin/herdr
    set -l prev ~/.local/bin/herdr.prev
    set -l zig zig@0.16.0
    # Fail in this environment on master too: they wait on a live server socket.
    set -l env_broken_tests \
        'test(=events_subscribe_streams_output_and_agent_status_events)' \
        'test(=live_server_holds_one_pty_master_fd_per_pane)' \
        'test(=same_tab_geometry_follows_meaningful_client_activity)' \
        'test(=api_pane_output_is_fanned_out_as_pane_surface_updates)'

    if set -q _flag_help
        echo 'usage: herdr-fork-update [--skip-tests] [--rollback]'
        echo '  default     merge upstream/master into master, test, build, install, live-handoff, push'
        echo '  --skip-tests  skip cargo nextest'
        echo "  --rollback    reinstall $prev and live-handoff to it"
        return 0
    end

    if set -q _flag_rollback
        if not test -x $prev
            echo "herdr-fork-update: no $prev to roll back to" >&2
            return 1
        end
        install -m 755 $prev $bin
        and $bin server live-handoff --import-exe $bin
        return
    end

    if not git -C $repo diff --quiet; or not git -C $repo diff --cached --quiet
        echo "herdr-fork-update: $repo has uncommitted changes" >&2
        return 1
    end

    git -C $repo switch master
    and git -C $repo pull --ff-only origin master
    and git -C $repo fetch upstream
    or return 1

    set -l before (git -C $repo rev-parse --short HEAD)
    if not git -C $repo merge --no-edit upstream/master
        echo "herdr-fork-update: merge conflict in $repo" >&2
        echo "  resolve, git commit, then rerun; or abort: git -C $repo merge --abort" >&2
        return 1
    end
    set -l after (git -C $repo rev-parse --short HEAD)
    echo "herdr-fork-update: master $before -> $after"

    pushd $repo
    if not set -q _flag_skip_tests
        mise exec $zig -- cargo nextest run --locked --retries 2 \
            --status-level fail --final-status-level fail \
            --failure-output final --success-output never \
            -E "not ("(string join ' | ' $env_broken_tests)")"
        or begin
            popd
            echo "herdr-fork-update: tests failed; nothing installed" >&2
            echo "  undo the merge: git -C $repo reset --hard $before" >&2
            return 1
        end
    end
    mise exec $zig -- cargo build --release --locked
    or begin
        popd
        echo "herdr-fork-update: build failed; nothing installed" >&2
        echo "  if Zig is too old, check the version build.rs asks for and update the zig variable" >&2
        return 1
    end
    popd

    set -l built $repo/target/release/herdr
    install -m 755 $bin $prev
    and install -m 755 $built $bin
    or return 1

    set -l want (shasum -a 256 $built | string split -f1 ' ')
    set -l got (shasum -a 256 $bin | string split -f1 ' ')
    if test "$want" != "$got"
        echo "herdr-fork-update: installed binary hash mismatch" >&2
        return 1
    end
    echo "herdr-fork-update: installed "($bin --version)" sha256 "(string sub -l 16 $got)

    git -C $repo push origin master
    or echo "herdr-fork-update: push to origin failed; the local master is ahead" >&2

    $bin server live-handoff --import-exe $bin
    or begin
        echo "herdr-fork-update: live handoff failed; the old server is still running" >&2
        echo "  from a terminal outside herdr: herdr server stop; herdr" >&2
        echo "  or roll back: herdr-fork-update --rollback" >&2
        return 1
    end
end
