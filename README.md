# dotfiles

This repository holds my machine setup. It uses [mise](https://mise.jdx.dev) 2026.10.25 to install tools and packages and to link config files.

- `home/` mirrors `$HOME`. `mise` links each file from `home/` to its place in `$HOME`.
- `home/.config/mise/config.toml` is the single description of the machine. `mise.toml` in the root is a symlink to it.
- `.mise.toml` holds the tasks of this repository, for example `mise run lint`.
- The `Makefile` installs only Homebrew and `mise`. `mise` does the rest.

## Fresh Mac

This path is for Apple Silicon only. It sets my Git name, email and signing key, and it changes the login shell to fish. Fork the repository and change these values first.

`git` and `make` need the Command Line Tools. Run `xcode-select --install` first.

```sh
git clone https://github.com/mykhaliuk/dotfiles.git ~/dotfiles
cd ~/dotfiles
make install
```

The command installs Homebrew if it is missing, installs `mise`, and runs `make apply`.

## Fresh Fedora

This path is not verified yet. Nobody has run it on a real Fedora machine.

```sh
sudo dnf copr enable -y jdxcode/mise
sudo dnf install -y mise git
mise bootstrap --from https://github.com/mykhaliuk/dotfiles.git --from-dir ~/dotfiles --config-dir home/.config/mise --yes
```

## Daily use

Run `make apply` to apply the repository to the machine. It links `~/.config/mise` to the repository and runs `mise bootstrap --yes`.

If a target file exists and is not a link, `make apply` stops after the package step and does not change that file. Move the file away, or run `mise dot add <file>` to keep its content. Then run `make apply` again.

On macOS the command puts the Homebrew portable Ruby first on `PATH`. The tap definitions need Ruby 3 or newer. `/usr/bin/ruby` is older. Every direct `mise bootstrap` command on macOS needs the same path:

```sh
PATH="/opt/homebrew/Library/Homebrew/vendor/portable-ruby/current/bin:$PATH" mise bootstrap packages prune --dry-run
```

Warnings:

- `mise bootstrap packages prune` lists `icu4c@78`, `mbedtls@3`, `openssl@3` and `whisper-cpp`. Other formulae need them. Read the output of `--dry-run` first. Do not confirm that list.
- `mise run <task> --dry-run` runs the task for real. `mise` passes the flag to the task. Do not use it on `upgrade` or `clean`.

## Machine keys

Some Git settings belong to one machine only. Go to the repository that you want to maintain, then register it in the local file:

```sh
git maintenance register --config-file ~/.config/git/local
```

## Files that apps save

Some apps replace a symlink when they save. These files use copy mode. Examples are `~/.a-barrc` and `~/.config/karabiner/karabiner.json`.

After an app changes such a file, copy the edit back into the repository:

```sh
mise dot add ~/.a-barrc
mise dot add ~/.config/karabiner/karabiner.json
```

`lazy-lock.json` and `lazyvim.json` in `home/.config/LazyVim` change when plugins update. Commit them.

## By hand

`mise` does not do these steps:

- Add the ssh keys.
- Run `gh auth login`.
- Turn on the 1Password desktop app and the 1Password CLI integration.
- Import the GPG public key. Old commits need it.
- Install `rustup`, then run `cargo install cargo-nextest`.
- Install the `CartographCF` Nerd Font. Without it, the apps use another font.
- Run `set -Ux PERSONAL_PROJECTS_DIR <directory>` in fish. `herdr-fork-update` and the `yazi` hop use it.
- Add `home/.config/tmux/lib/claude.sh` if you want the Claude limits in the `tmux` status. This file is not in the repository.
- Install the `tmux` plugins. In `tmux`, press `prefix + I`.
- Run `ya pkg install` for the `yazi` packages.
- Install the CLIs that are not in the config.
- Install the code of the a-bar widgets.
- Enable RPM Fusion on Fedora, for the full `ffmpeg`.

## Secrets

The repository holds no secret values. The env files in `home/.config/secrets` hold references. Use `opr` to run a command with these secrets, for example `opr github gh repo list`.

## The `herdr` override

`herdr` is a `mise` tool. A fork build of `herdr` installs to `~/.local/bin/herdr`. That directory comes before the `mise` shims on `PATH`, so the fork wins. This is intended.
