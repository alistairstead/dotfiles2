return {
  {
    "s1n7ax/nvim-window-picker",
    main = "window-picker",
    event = "VeryLazy",
    version = "2.*",
    -- commit = "6e98757",
    opts = {
      hint = "statusline-winbar",
      show_prompt = true,
      selection_chars = "dfghjkl;",
      filter_rules = {
        -- filter using buffer options
        bo = {
          -- if the file type is one of following, the window will be ignored
          filetype = { "NvimTree", "neo-tree", "notify", "edgy" },
          -- if the buffer type is one of following, the window will be ignored
          buftype = {},
        },
      },
      fg_color = "#EF87BD",
      -- if you have include_current_win == true, then current_win_hl_color will
      -- be highlighted using this background color
      current_win_hl_color = "#454158",
      -- all the windows except the current window will be highlighted using this color
      other_win_hl_color = "#454158",
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      {
        "s1n7ax/nvim-window-picker",
      },
    },
    opts = {
      open_files_do_not_replace_types = { "edgy" },
      enable_git_status = true,
      enable_diagnostics = true,
      sync_root_with_cwd = false,
      -- source_selector = {
      --   winbar = true,
      --   statusline = true,
      -- },
      filesystem = {
        use_libuv_file_watcher = true,
        follow_current_file = {
          enabled = true, -- This will find and focus the file in the active buffer every time
          leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
        },
      },
      update_focused_file = {
        enable = true,
        update_root = false,
      },
      default_component_configs = {
        indent = {
          indent_marker = " ",
          last_indent_marker = " ",
        },
        name = {
          use_git_status_colors = false,
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "",
        },
        git_status = {
          symbols = {
            -- Change type
            added = "", -- ", -- or "✚", but this is redundant info if you use git_status_colors on the name
            modified = "◦", -- "", -- or "", but this is redundant info if you use git_status_colors on the name
            deleted = "", -- "◦", -- this can only be used in the git_status source
            renamed = "", -- "", -- this can only be used in the git_status source
            -- Status type
            untracked = "◦",
            ignored = "",
            unstaged = "",
            staged = "",
            conflict = "",
          },
        },
        event_handlers = {
          {
            event = "file_opened",
            handler = function(file_path)
              -- auto close
              -- vimc.cmd("Neotree close")
              -- OR
              require("neo-tree.command").execute({ action = "close" })
            end,
          },
          {
            event = "neo_tree_buffer_enter",
            handler = function()
              vim.cmd("highlight! Cursor blend=100")
            end,
          },
          {
            event = "neo_tree_buffer_leave",
            handler = function()
              vim.cmd("highlight! Cursor guibg=#5f87af blend=0")
            end,
          },
        },
      },
      window = {
        mappings = {
          ["e"] = function()
            vim.api.nvim_exec("Neotree focus filesystem left", true)
          end,
          ["b"] = function()
            vim.api.nvim_exec("Neotree focus buffers left", true)
          end,
          ["g"] = function()
            vim.api.nvim_exec("Neotree focus git_status left", true)
          end,
          ["l"] = "open",
          ["L"] = "open_with_window_picker",
          ["o"] = "open_with_window_picker",
          ["h"] = "close_node",
          ["S"] = "split_with_window_picker",
          ["s"] = "open_split",
          ["V"] = "vsplit_with_window_picker",
          ["v"] = "open_vsplit",
        },
      },
    },
  },
  {
    "akinsho/bufferline.nvim",
    optional = true,
    opts = {
      options = {
        color_icons = false,
        show_buffer_close_icons = false,
        show_close_icon = false,
        modified_icon = "◦",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        groups = {
          items = {
            require("bufferline.groups").builtin.pinned:with({ icon = "" }),
          },
        },
      },
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 2000,
    ---@class CatppuccinOptions
    opts = function()
      return {
        flavour = "mocha",
        transparent_background = false,
      }
    end,
  },
  {
    "folke/noice.nvim",
    optional = true,
    opts = function(_, opts)
      opts.debug = false
      opts.routes = opts.routes or {}
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = { skip = true },
      })
      local focused = true
      vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
          focused = true
        end,
      })
      vim.api.nvim_create_autocmd("FocusLost", {
        callback = function()
          focused = false
        end,
      })

      table.insert(opts.routes, 1, {
        filter = {
          ["not"] = {
            event = "lsp",
            kind = "progress",
          },
          cond = function()
            return not focused
          end,
        },
        view = "notify_send",
        opts = { stop = false },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(event)
          vim.schedule(function()
            require("noice.text.markdown").keys(event.buf)
          end)
        end,
      })
      return opts
    end,
  },
  {
    "folke/edgy.nvim",
    optional = true,
    opts = {
      wo = {
        spell = false,
      },
      animate = {
        enabled = true,
      },
      bottom = {
        {
          ft = "lazyterm",
          title = "LazyTerm",
          size = { height = 0.4 },
          filter = function(buf)
            return not vim.b[buf].lazyterm_cmd
          end,
        },
        "Trouble",
        { ft = "qf", title = "QuickFix" },
        {
          ft = "help",
          size = { height = 20 },
          -- only show help buffers
          filter = function(buf)
            return vim.bo[buf].buftype == "help"
          end,
        },
        {
          title = "DB Query Result",
          ft = "dbout",
        },
      },
      left = {
        {
          title = "Neo-Tree",
          ft = "neo-tree",
          filter = function(buf)
            return vim.b[buf].neo_tree_source == "filesystem"
          end,
          open = function()
            require("neo-tree.command").execute({ dir = LazyVim.root() })
          end,
          size = { width = 0.3 },
        },
        {
          title = "Database",
          ft = "dbui",
          open = function()
            vim.cmd("DBUI")
          end,
        },
      },
      right = {
        { title = "CopilotChat.nvim", ft = "copilot-chat", size = { width = 0.5 } },
        { title = "Neotest", ft = "neotest", size = { width = 0.5 } },
        { title = "Neotest Summary", ft = "neotest-summary", size = { width = 0.3 } },
        { title = "Neotest Output", ft = "neotest-output-panel", size = { width = 0.5 } },
        {
          ft = "Outline",
          open = "SymbolsOutlineOpen",
        },
      },
    },
  },
  {
    "folke/zen-mode.nvim",
    dependencies = {
      "b0o/incline.nvim",
    },
    cmd = "ZenMode",
    keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
  },
  {
    "NvChad/nvim-colorizer.lua",
    enabled = false,
    event = "BufReadPre",
    opts = {
      filetypes = { "*", "!lazy" },
      buftype = { "*", "!prompt", "!nofile" },
      user_default_options = {
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = false, -- "Name" codes like Blue
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        AARRGGBB = true, -- 0xAARRGGBB hex codes
        rgb_fn = true, -- CSS rgb() and rgba() functions
        hsl_fn = true, -- CSS hsl() and hsla() functions
        css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
        -- Available modes: foreground, background
        -- Available modes for `mode`: foreground, background,  virtualtext
        mode = "virtualtext", -- Set the display mode.
        virtualtext = "■",
      },
    },
  },
}
