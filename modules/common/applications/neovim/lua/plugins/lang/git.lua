---@return LazyPluginSpec[]
return {
  {
    "TimUntersberger/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      -- Only one of these is needed.
      "ibhagwan/fzf-lua", -- optional
      -- "echasnovski/mini.pick", -- optional
    },
    opts = {
      disable_hint = false,
      disable_commit_confirmation = "auto",
      console_timeout = 2000,
      auto_show_console = false,
      disable_insert_on_commit = true,
      graph_style = "unicode",
      integrations = {
        -- If enabled, use telescope for menu selection rather than vim.ui.select.
        -- Allows multi-select and some things that vim.ui.select doesn't.
        telescope = nil,
        -- Neogit only provides inline diffs. If you want a more traditional way to look at diffs, you can use `diffview`.
        -- The diffview integration enables the diff popup.
        --
        -- Requires you to have `sindrets/diffview.nvim` installed.
        diffview = nil,

        -- If enabled, uses fzf-lua for menu selection. If the telescope integration
        -- is also selected then telescope is used instead
        -- Requires you to have `ibhagwan/fzf-lua` installed.
        fzf_lua = true,

        -- If enabled, uses mini.pick for menu selection. If the telescope integration
        -- is also selected then telescope is used instead
        -- Requires you to have `echasnovski/mini.pick` installed.
        mini_pick = nil,
      },
      -- signs = {
      --   -- { CLOSED, OPENED }
      --   hunk = { "", "" },
      --   item = { "", "" },
      --   section = { "", "" },
      -- },
    },
    keys = {
      { "<leader>gc", "<cmd>lua require('neogit').open({'commit'})<CR>", desc = "Git commit" },
      {
        "<leader>gg",
        function()
          require("neogit").open({ cwd = vim.fn.expand("%:p:h") })
        end,
        desc = "Neogit",
      },
    },
  },
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
    opts = function()
      return {
        keymaps = {
          file_panel = {
            ["q"] = "<cmd>DiffviewClose<cr>",
          },
        },
      }
    end,
    keys = { { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" } },
  },
  {
    "lewis6991/gitsigns.nvim",
    optional = true,
    opts = {
      signs_staged = {
        delete = { text = "" },
        topdelete = { text = "" },
      },
      signs = {
        delete = { text = "" },
        topdelete = { text = "" },
        untracked = { text = "┆" },
        --   add = { text = "┊" },
        --   change = { text = "┊" },
        --   delete = { text = "┊" },
        --   topdelete = { text = "┊" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        map({ "n", "v" }, "<leader>gx", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map("n", "<leader>gS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>gh", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>gu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>gX", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>gp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>gB", function()
          gs.blame_line({ full = true })
        end, "Blame Line")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
    keys = {
      -- git hunk navigation - previous / next
      { "gh", ":Gitsigns next_hunk<CR>", desc = "Goto next git hunk" },
      { "gH", ":Gitsigns prev_hunk<CR>", desc = "Goto previous git hunk" },
      { "]g", ":Gitsigns next_hunk<CR>", desc = "Goto next git hunk" },
      { "[g", ":Gitsigns prev_hunk<CR>", desc = "Goto previous git hunk" },
    },
  },
  {
    "ruifm/gitlinker.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    opts = {},
    keys = {
      {
        "<leader>gy",
        function()
          require("gitlinker").get_buf_range_url("n")
        end,
        desc = "Yank Repo URL",
      },
    },
  },
}
