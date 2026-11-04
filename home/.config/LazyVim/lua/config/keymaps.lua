-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- This file is automatically loaded by lazyvim.config.init
local Util = require("lazyvim.util")
local map = Util.safe_keymap_set

-- save all files
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>wa<cr><esc>", { desc = "Save all files" })

-- lazy
map("n", "<leader>cu", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- formatting
map({ "n", "v" }, "<leader>l", function()
  Util.format({ force = true })
end, { desc = "Format" })
