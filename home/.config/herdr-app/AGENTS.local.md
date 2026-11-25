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
