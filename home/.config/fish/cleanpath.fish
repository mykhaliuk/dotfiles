# Deterministic PATH: wiped and rebuilt from scratch on every shell start.
#
# NOTE: use `set -ga PATH`, never `fish_add_path` here. fish_add_path skips a
# path that is already listed in the universal $fish_user_paths -- but the wipe
# below has just dropped every universal entry from PATH, so the path ends up
# "registered" and absent at the same time. That silently nulled this entire
# file until 2026-08-14.
set -gx PATH
set -ga PATH /usr/local/bin
# rustup shims resolve the toolchain pinned by rust-toolchain.toml, so they
# must precede any other rustc
set -ga PATH $HOME/.cargo/bin
set -ga PATH $HOME/.local/bin
# shims before /usr/bin and brew: Apple's python3/jq and brew copies must
# never shadow a mise tool
set -ga PATH $HOME/.local/share/mise/shims
set -ga PATH /opt/homebrew/bin
set -ga PATH /opt/homebrew/sbin
set -ga PATH /usr/bin
set -ga PATH /bin
set -ga PATH /usr/sbin
set -ga PATH /sbin
set -ga PATH $HOME/.amplify/bin
set -ga PATH $HOME/.docker/bin
set -ga PATH "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
set -ga PATH $HOME/go/bin
set -ga PATH /opt/homebrew/opt/postgresql@18/bin
set -ga PATH /opt/homebrew/opt/ffmpeg-full/bin
set -ga PATH /opt/homebrew/opt/imagemagick-full/bin
set -ga PATH /usr/local/MacGPG2/bin
set -ga PATH /System/Cryptexes/App/usr/bin
