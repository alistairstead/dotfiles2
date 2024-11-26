return {
  {
    "ibhagwan/fzf-lua",
    keys = {
      { "<C-p>", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      local actions = require("telescope.actions")

      return table.insert(opts, {
        path_display = { "smart" },
        prompt_position = "top",
        prompt_prefix = " ",
        selection_caret = " ",
        sorting_strategy = "ascending",
        color_devicons = true,
        selection_strategy = "reset",
        scroll_strategy = "cycle",
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
        },
      })
    end,
  },
  -- {
  --   "ecthelionvi/NeoComposer.nvim",
  --   dependencies = {
  --     "kkharji/sqlite.lua",
  --     {
  --       "nvim-telescope/telescope.nvim",
  --       keys = function()
  --         require("telescope").load_extension("macros")
  --         return {
  --           { "<leader>fm", "<cmd>Telescope macros<cr>", desc = "Find macros" },
  --         }
  --       end,
  --     },
  --   },
  --   opts = {},
  --   keys = function()
  --     local wk = require("which-key")
  --
  --     wk.add({
  --       prefix = "<leader>m",
  --       group = "+MacroComposer",
  --       mode = { "v", "n" },
  --     })
  --     return {
  --       {
  --         "<leader>mr",
  --         "<cmd>lua require('NeoComposer.ui').toggle_record()<cr>",
  --         desc = "Record macro",
  --       },
  --       {
  --         "<leader>mm",
  --         "<cmd>lua require('NeoComposer.ui').toggle_macro_menu()<cr>",
  --         desc = "Macro menu",
  --       },
  --     }
  --   end,
  -- },
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
}
