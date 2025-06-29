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

  -- Session management
  {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
      log_level = "error",
      auto_session_suppress_dirs = { "~/", "~/dev", "~/Downloads", "/" },
      auto_session_use_git_branch = true,
      auto_restore_enabled = true,
      auto_save_enabled = true,
    },
    keys = {
      { "<leader>qs", "<cmd>SessionSave<cr>", desc = "Save session" },
      { "<leader>qr", "<cmd>SessionRestore<cr>", desc = "Restore session" },
      { "<leader>qd", "<cmd>SessionDelete<cr>", desc = "Delete session" },
      { "<leader>qf", "<cmd>Autosession search<cr>", desc = "Find session" },
    },
  },

  -- Git signs in gutter
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- Navigation
        map("n", "]h", gs.next_hunk, "Next Hunk")
        map("n", "[h", gs.prev_hunk, "Prev Hunk")

        -- Actions
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
}
