return {
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
