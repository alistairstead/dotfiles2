return {
  {
    optional = true,
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        path_display = { "smart" },
        prompt_position = "top",
        prompt_prefix = " ",
        selection_caret = " ",
        sorting_strategy = "ascending",
        color_devicons = true,
        selection_strategy = "reset",
        scroll_strategy = "cycle",
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--hidden",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--trim", -- add this value
        },
        layout_config = {
          width = 0.95,
          height = 0.85,
          prompt_position = "top",
          horizontal = {
            preview_width = function(_, cols, _)
              if cols > 200 then
                return math.floor(cols * 0.4)
              else
                return math.floor(cols * 0.6)
              end
            end,
          },
          vertical = {
            width = 0.9,
            height = 0.95,
            preview_height = 0.5,
          },
          flex = {
            horizontal = {
              preview_width = 0.9,
            },
          },
        },
        mappings = {
          i = {
            ["<C-n>"] = require("telescope.actions").cycle_history_next,
            ["<C-p>"] = require("telescope.actions").cycle_history_prev,
            ["<C-j>"] = require("telescope.actions").move_selection_next,
            ["<C-k>"] = require("telescope.actions").move_selection_previous,
            ["<C-c>"] = require("telescope.actions").close,
            ["<CR>"] = require("telescope.actions").select_default,
            ["<Tab>"] = require("telescope.actions").toggle_selection
              + require("telescope.actions").move_selection_worse,
            ["<S-Tab>"] = require("telescope.actions").toggle_selection
              + require("telescope.actions").move_selection_better,
            ["<C-q>"] = require("telescope.actions").send_to_qflist + require("telescope.actions").open_qflist,
            ["<C-l>"] = require("telescope.actions").complete_tag,
          },
          n = {
            ["<esc>"] = require("telescope.actions").close,
            ["<CR>"] = require("telescope.actions").select_default,
          },
        },
      },
      pickers = {
        git_files = {
          prompt_prefix = "󰊢 ",
          hidden = true,
          show_untracked = true,
        },
        find_files = {
          prompt_prefix = " ",
          hidden = true,
          theme = "dropdown",
          previewer = false,
        },
        buffers = {
          prompt_prefix = " ",
          previewer = false,
          theme = "dropdown",
        },
        lsp_references = {
          prompt_prefix = " ",
          previewer = true,
        },
        defaults = {
          file_ignore_patterns = { "yarn.lock", "node_modules/*" },
        },
      },
    },
    keys = {
      { "<C-t>", "<cmd>Telescope<cr>", desc = "Telescope" },
      { "<C-p>", "<cmd>Telescope git_files<CR>", desc = "git files" },
      { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
    },
  },
}
