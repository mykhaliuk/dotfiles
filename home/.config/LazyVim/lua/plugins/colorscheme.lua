return {
  { "rmehri01/onenord.nvim" },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onenord",
    },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        position = "left",
        mappings = {
          ["l"] = "open",
          ["h"] = "close_node",
        },
      },

      filesystem = {
        filtered_items = {
          hide_by_name = {
            "node_modules",
          },
          hide_hidden = false,
          hide_gitignored = false,
          hide_dotfiles = false,
        },
      },
    },
  },
}
