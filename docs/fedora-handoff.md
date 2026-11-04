# Fedora handoff

This file is for an agent that has seen nothing of this project. It lists what to verify on Fedora and what to add to CI.

## Context

- This repository sets up a machine with `mise` 2026.10.25. The description of the machine is `home/.config/mise/config.toml`.
- The Mac side is built and checked. Nobody has run anything on Fedora.
- `make install` and `make apply` change the real machine. Use a test machine or a container for the checks below.
- `mise run <task> --dry-run` runs the task for real. Never use it on `upgrade` or `clean`.

## What was checked

- 15 `dnf:` package names return HTTP 200 in the Fedora 43 and rawhide repositories. These are all `dnf:` names except the COPR package and the group.
- The COPR `scottames/ghostty` has chroots for Fedora 43, 44, 45 and rawhide.
- `mole` is a tool in `[tools]`. Its registry entry limits it by `os`, so `mise` drops it on Linux.

## Open for Linux

Nobody has run these items on Linux.

1. The `op-account` doctor check in `config.toml` gives a wrong hint on Fedora. No `dnf:` entry installs `op`.
2. The `{% else %}` branches of the `upgrade` and `clean` tasks never ran.
3. The tasks call `sudo` on Fedora. That never ran.
4. The `taps` section never ran on Fedora.
5. The group `@development-tools` rests on the `mise` documentation only. Verify that `dnf:@development-tools` installs the group.
6. Fedora has no doctor check for commit signing. The user may want a check for `/opt/1Password/op-ssh-sign`.
7. Nobody ran the Linux branches of the `Makefile`.
8. Nobody ran the COPR repositories `jdxcode/mise` and `scottames/ghostty` on a real machine.
9. Nobody ran the doctor checks on Linux.

## Task: add a Fedora job to CI

Add the job to `.github/workflows/main.yml`. The macOS job `check` is the model. Keep `permissions: contents: read` and pin each action to a full commit SHA.

Use this order of steps:

1. Run the job in a Fedora container. Run `dnf install -y git dnf5-plugins` before the checkout step.
2. Check out the repository with `fetch-depth: 0` and `persist-credentials: false`.
3. Run `git config --system --add safe.directory "$GITHUB_WORKSPACE"`. Do not use `--global`.
4. Run `dnf copr enable -y jdxcode/mise && dnf install -y mise`.
5. Run `ln -s "$GITHUB_WORKSPACE" ~/dotfiles`.
6. Run `mise bootstrap --from "$(git -C ~/dotfiles remote get-url origin)" --from-dir ~/dotfiles --config-dir home/.config/mise --yes --skip tools`.
7. Assert that `~/.config/fish/config.fish` links into the checkout.
8. Assert that `~/.gitconfig` holds `/opt/1Password/op-ssh-sign`.
9. Run the bootstrap a second time without `--skip tools` and without a token. It must succeed.

## Task: verify on Fedora

- Run the Fedora path of the README on a clean machine.
- Check the `dnf:` packages, the COPR repositories and the `Makefile` branches for Fedora.
- Run `mise doctor` and read each check.
- Fix the items in "Open for Linux", or tell the user which ones need a decision.
