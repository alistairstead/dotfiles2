return {
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      keymap = {
        preset = "super-tab",
        ["<CR>"] = { "accept", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-d>"] = { "scroll_documentation_up", "fallback" },
        ["<C-u>"] = { "scroll_documentation_down", "fallback" },
      },
    },
  },
  {
    "folke/paint.nvim",
    opt = {
      ---@type PaintHighlight[]
      highlights = {
        {
          -- filter can be a table of buffer options that should match,
          -- or a function called with buf as param that should return true.
          -- The example below will paint @something in comments with Constant
          filter = { filetype = "lua" },
          pattern = "%s*%-%-%-%s*(@%w+)",
          hl = "Constant",
        },
      },
    },
  },
  {
    "echasnovski/mini.splitjoin",
    enabled = false,
    opts = { mappings = { toggle = "J" } },
    keys = {
      { "J", desc = "Split/Join" },
    },
  },
  {
    "Wansmer/treesj",
    keys = {
      { "J", "<cmd>TSJToggle<cr>", desc = "Join Toggle" },
    },
    opts = { use_default_keymaps = false, max_join_length = 150 },
  },
  {
    "anuvyklack/fold-preview.nvim",
    -- enable = false,
    event = "BufReadPost",
    dependencies = "anuvyklack/keymap-amend.nvim",
    config = true,
  },
}
