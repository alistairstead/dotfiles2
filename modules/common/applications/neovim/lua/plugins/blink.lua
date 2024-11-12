return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "super-tab",
        ["<CR>"] = { "accept", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-d>"] = { "scroll_documentation_up", "fallback" },
        ["<C-u>"] = { "scroll_documentation_down", "fallback" },
      },
      -- windows = {
      --   documentation = {
      --     border = "rounded",
      --   },
      --   siganature_help = {
      --     border = "rounded",
      --   },
      --   ghost_text = {
      --     enables = false,
      --   },
      -- },
    },
  },
}
