require("git"):setup({
	-- Order of status signs showing in the linemode
	order = 1500,
})

require("bunny"):setup({
    fuzzy_cmd = "fzf",
    ephemeral = true,
    tabs = true,
    notify = false,
    hops = {
        { key = "p", path = "~/Documents/Projects", desc = "Projects" },
        { key = "m", path = os.getenv("PERSONAL_PROJECTS_DIR") or "~/Documents/Projects", desc = "My projects" },
        { key = "c", path = "~/.config", desc = "Config" },
        { key = "y", path = "~/.config/yazi", desc = "Yazi config" },
    },
})
