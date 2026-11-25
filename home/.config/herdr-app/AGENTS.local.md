# Local setup notes

Migrated from the herdr TUI config (`~/.config/herdr/config.toml`) on 2026-11-25.

- `theme: "catppuccin"` in settings.json → `themes/catppuccin.json` (Mocha palette,
  same as the TUI's `catppuccin`; the TUI had `auto_switch = false`, so no light variant).
- TUI `focus_agent = prefix+shift+1..9` → `cmd-alt-1..9` = `agent.select:N`
  (cmd-1..9 is tab.select, ctrl-1..9 is space.select). Agent order follows the
  agents list sort; the TUI used `agent_panel_sort = "spaces"` ("Grouped by space").
- TUI `close_pane = prefix+shift+x` (moved off prefix+x, next to zoom) → app
  default `cmd-shift-w` already deliberate; zoom is `cmd-shift-enter`. Not rebound.
- TUI `cmd+p` herdr-omni → app default `cmd-p` = shipped picker.
- Not migrated (TUI-only plugins): zoetrope, plugin-manager, reviewr (`cmd+r`),
  herdr-radar sidebar/tab-bar/theme blocks.
- keys.json is now hand-edited: new default shortcuts from app upgrades must be added by hand.

## gitview (2026-11-25)

- Installed `ChmaraX/herdr-gitview` v0.6.0 (release bundle, `install.sh --app --version v0.6.0`).
  It replaces the Changes panel with gitview mods and a `mods/gitview/bin/herdr-gitview` binary.
- The installer cloned `main` as `layouts/main-copy.json` and switched to it; that is the
  personal layout now. Upgrade: run the installer again; `--uninstall` restores the stock panel.
- Keys: `cmd-shift-g` (panel), `cmd-g` (own tab).
- The installer writes `keys.json` with tmp+rename, which replaces the dotfiles symlink.
  After an install or uninstall, copy `keys.json` back to `~/dotfiles/home/.config/herdr-app/`
  and run `mise dot apply --force`.
