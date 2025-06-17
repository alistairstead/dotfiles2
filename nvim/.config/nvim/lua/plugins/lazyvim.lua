---@return LazyPluginSpec[]
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
      icons = {
        diagnostics = {
          Error = " ",
          Warn = " ",
          Hint = " ",
          Info = " ",
        },
        git = {
          added = " ",
          modified = " ",
          removed = " ",
        },
      },
    },
  },
  -- {
  --   "saghen/blink.cmp",
  --   version = "0.7.6",
  -- },
  {
    "snacks.nvim",
    opts = {
      indent = { enabled = false },
    },
  },
  { "rafamadriz/friendly-snippets", enabled = false },
  { "SmiteshP/nvim-navic", enabled = false },
  { "RRethy/vim-illuminate", enabled = false },
  -- {
  --   "zbirenbaum/copilot.lua",
  --   optional = true,
  --   opts = function()
  --     require("copilot.api").status = require("copilot.status")
  --   end,
  -- },
  -- Fix based on this thread
  -- https://github.com/LazyVim/LazyVim/issues/6039
  { "mason-org/mason.nvim", version = "1.11.0" },
  { "mason-org/mason-lspconfig.nvim", version = "1.32.0" },
}
