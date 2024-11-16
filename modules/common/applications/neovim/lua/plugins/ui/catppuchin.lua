return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 2000,
  ---@class CatppuccinOptions
  opts = function()
    return {
      flavour = "mocha",
      transparent_background = false,
      -- styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
      --   comments = { "italic" }, -- Change the style of comments
      -- },
      -- integrations = {
      --   aerial = true,
      --   alpha = true,
      --   cmp = true,
      --   dashboard = true,
      --   flash = true,
      --   grug_far = true,
      --   gitsigns = true,
      --   headlines = true,
      --   illuminate = true,
      --   indent_blankline = { enabled = true },
      --   leap = true,
      --   lsp_trouble = true,
      --   mason = true,
      --   markdown = true,
      --   mini = true,
      --   native_lsp = {
      --     enabled = true,
      --     virtual_text = {
      --       errors = { "italic" },
      --       hints = { "italic" },
      --       warnings = { "italic" },
      --       information = { "italic" },
      --     },
      --     underlines = {
      --       errors = { "underline" },
      --       hints = { "underline" },
      --       warnings = { "underline" },
      --       information = { "underline" },
      --     },
      --   },
      --   navic = { enabled = true, custom_bg = "lualine" },
      --   neotest = true,
      --   neotree = true,
      --   noice = true,
      --   notify = true,
      --   semantic_tokens = true,
      --   telescope = true,
      --   treesitter = true,
      --   treesitter_context = true,
      --   which_key = true,
      -- },
    }
  end,
}
