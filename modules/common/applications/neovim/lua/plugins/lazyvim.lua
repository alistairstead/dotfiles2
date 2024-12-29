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
  {
    "saghen/blink.cmp",
    version = "0.7.6",
  },
  {
    "snacks.nvim",
    opts = {
      indent = { enabled = false },
    },
  },
  { "SmiteshP/nvim-navic", enabled = false },
  { "RRethy/vim-illuminate", enabled = false },
}
