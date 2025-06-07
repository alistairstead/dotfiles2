---@return LazyPluginSpec[]
return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      preset = "classic",
    },
  },
  {
    "ibhagwan/fzf-lua",
    optional = true,
    keys = {
      { "<C-p>", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
    },
  },
  {
    "ecthelionvi/NeoComposer.nvim",
    dependencies = {
      "kkharji/sqlite.lua",
      {
        "folke/which-key.nvim",
        optional = true,
        opts = { spec = { { "<leader>m", group = "+MacroComposer", icon = { icon = "", color = "cyan" } } } },
      },
    },
    opts = {
      keymaps = {
        play_macro = "pq",
        yank_macro = "yq",
        stop_macro = "cq",
        toggle_record = "Q",
        cycle_next = "<c-j>",
        cycle_prev = "<c-k>",
        toggle_macro_menu = "<m-q>",
      },
    },
    keys = {
      -- { "<leader>m", desc = "+MacroComposer", icon = { icon = "", color = "cyan" } },
      {
        "<leader>mr",
        "<cmd>lua require('NeoComposer.ui').toggle_record()<cr>",
        desc = "Record macro",
      },
      {
        "<leader>mm",
        "<cmd>lua require('NeoComposer.ui').toggle_macro_menu()<cr>",
        desc = "Macro menu",
      },
    },
  },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
    config = function()
      vim.g.tmux_navigator_disable_when_zoomed = 1
      vim.g.tmux_navigator_no_wrap = 1
    end,
  },
  { "editorconfig/editorconfig-vim" },
  {
    "kevinhwang91/nvim-bqf", -- Better quickfix window,
    ft = "qf",
  },
}
