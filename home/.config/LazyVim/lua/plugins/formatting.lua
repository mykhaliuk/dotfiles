local OXFMT_CONFIGS = { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" }

local OXFMT_FILETYPES = {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "vue",
  "svelte",
  "json",
  "jsonc",
  "css",
  "scss",
  "less",
  "html",
  "markdown",
  "yaml",
  "toml",
  "graphql",
}

local hasOxfmtConfig = function(_, ctx)
  return vim.fs.find(OXFMT_CONFIGS, { path = ctx.dirname, upward = true })[1] ~= nil
end

return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters = opts.formatters or {}
    opts.formatters.oxfmt = { condition = hasOxfmtConfig }

    opts.formatters_by_ft = opts.formatters_by_ft or {}
    for _, ft in ipairs(OXFMT_FILETYPES) do
      local current = opts.formatters_by_ft[ft] or {}
      local chain = { "oxfmt", stop_after_first = true }
      for _, name in ipairs(current) do
        if name ~= "oxfmt" then
          table.insert(chain, name)
        end
      end
      opts.formatters_by_ft[ft] = chain
    end
  end,
}
