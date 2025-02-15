---@return LazyPluginSpec[]
return {
  {
    "s1n7ax/nvim-window-picker",
    main = "window-picker",
    event = "VeryLazy",
    version = "2.*",
    -- commit = "6e98757",
    opts = {
      hint = "floating-big-letter",
      show_prompt = false,
      selection_chars = "fghj",
      filter_rules = {
        -- filter using buffer options
        bo = {
          -- if the file type is one of following, the window will be ignored
          filetype = { "NvimTree", "neo-tree", "notify", "edgy" },
          -- if the buffer type is one of following, the window will be ignored
          buftype = {},
        },
      },
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
            added = "", -- ", -- or "✚", but this is redundant info if you use git_status_colors on the name
            modified = "◦", -- "", -- or "", but this is redundant info if you use git_status_colors on the name
            deleted = "", -- "◦", -- this can only be used in the git_status source
            renamed = "", -- "", -- this can only be used in the git_status source
            -- Status type
            untracked = "◦",
            ignored = "",
            unstaged = "",
            staged = "",
            conflict = "",
          },
        },
      },
      window = {
        mappings = {
          ["e"] = function()
            vim.cmd("Neotree focus filesystem left", true)
          end,
          ["b"] = function()
            vim.cmd("Neotree focus buffers left", true)
          end,
          ["g"] = function()
            vim.cmd("Neotree focus git_status left", true)
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
        close_icon = "",
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
    optional = true,
    ---@class CatppuccinOptions
    opts = function()
      return {
        flavour = "mocha",
        transparent_background = true,
        no_bold = false,
        dim_inactive = {
          enabled = false, -- dims the background color of inactive window
          shade = "dark",
          percentage = 0.15, -- percentage of the shade to apply to the inactive window
        },
        color_overrides = {
          all = {
            -- rosewater = "#f5e0dc",
            -- flamingo = "#f2cdcd",
            -- pink = "#f5c2e7",
            -- mauve = "#cba6f7",
            -- red = "#f38ba8",
            -- maroon = "#eba0ac",
            -- peach = "#fab387",
            -- yellow = "#f9e2af",
            -- green = "#a6e3a1",
            -- teal = "#94e2d5",
            -- sky = "#89dceb",
            -- sapphire = "#74c7ec",
            -- blue = "#89b4fa",
            -- lavender = "#b4befe",
            -- text = "#cdd6f4",
            -- subtext1 = "#bac2de",
            -- subtext0 = "#a6adc8",
            -- overlay2 = "#9399b2",
            -- overlay1 = "#7f849c",
            -- overlay0 = "#6c7086",
            -- surface2 = "#585b70",
            -- surface1 = "#45475a",
            -- surface0 = "#313244",
            -- base = "#1e1e2e",
            -- mantle = "#181825",
            -- crust = "#11111b",
            --
            -- overlay2 = "#585b70",
            -- overlay1 = "#585b70",
            -- overlay0 = "#2B2C30",
            -- surface2 = "#2B2C30",
            -- surface1 = "#262626",
            surface0 = "#1D1E23",
            crust = "#2B2C30",
            mantle = "#262626",
            base = "#1D1E23",
          },
        },
        -- highlight_overrides = {
        --   all = function(cp)
        --     return {
        --       -- BufferLineFill = { bg = "#1e1e2e" },
        --       -- TabLineFill = { bg = "#1e1e2e" },
        --       -- BufferLineBackground = { bg = "#1e1e2e" },
        --       -- For base configs
        --       -- NormalFloat = { fg = cp.text, bg = cp.mantle },
        --       -- FloatBorder = {
        --       --   fg = cp.mantle,
        --       --   bg = cp.mantle,
        --       -- },
        --       -- CursorLineNr = { fg = cp.green },
        --
        --       -- For nvim-tree
        --       -- NvimTreeRootFolder = { fg = cp.pink },
        --       -- NvimTreeIndentMarker = { fg = cp.surface2 },
        --       -- NeoTreeTabInactive = { bg = cp.surface2, fg = cp.overlay0 },
        --
        --       -- For trouble.nvim
        --       -- TroubleNormal = { bg = cp.base },
        --       -- TroubleNormalNC = { bg = cp.base },
        --     }
        --   end,
        -- },
        integrations = {
          dadbod_ui = true,
          dap = true,
          dap_ui = true,
          diffview = true,
          fzf = true,
          harpoon = true,
          lsp_saga = true,
          lsp_trouble = true,
          mason = true,
          native_lsp = true,
          neogit = true,
          octo = true,
          overseer = true,
          window_picker = true,
        },
      }
    end,
  },
  {
    "folke/noice.nvim",
    optional = true,
    opts = {
      presets = {
        lsp_doc_border = true,
      },
      ---@class NoiceConfigViews
      -- views = {
      --   notify = {
      --     backend = "notify_send",
      --   },
      -- },
      -- https://github.com/folke/noice.nvim/discussions/364
      routes = {
        {
          filter = {
            event = "notify",
            find = "No information available",
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "lsp",
            find = "snyk",
          },
          opts = { skip = true },
        },
      },
    },
  },
  {
    "folke/edgy.nvim",
    optional = true,
    opts = function()
      local opts = {
        options = {
          left = { size = 40 },
          bottom = { size = 10 },
          right = { size = 40 },
          top = { size = 10 },
        },
        animate = {
          enabled = false,
        },
        bottom = {
          {
            title = "Messages",
            ft = "noice",
            size = { height = 0.4 },
            filter = function(buf, win)
              return vim.api.nvim_win_get_config(win).relative == ""
            end,
          },
          "Trouble",
          { ft = "qf", title = "QuickFix" },
          {
            ft = "help",
            title = "Help",
            size = { height = 20 },
            -- don't open help files in edgy that we're editing
            filter = function(buf)
              return vim.bo[buf].buftype == "help"
            end,
          },
          {
            title = "Test Output",
            ft = "neotest-output-panel",
            size = { height = 15 },
          },
        },
        left = {
          {
            title = "Files",
            ft = "neo-tree",
            filter = function(buf)
              return vim.b[buf].neo_tree_source == "filesystem"
            end,
            open = function()
              require("neo-tree.command").execute({ dir = LazyVim.root() })
            end,
          },
        },
        right = {
          {
            title = "Databases",
            ft = "dbui",
            open = function()
              vim.cmd("DBUI")
            end,
          },
          { title = "Search & Replace", ft = "grug-far", size = { width = 0.4 } },
          { title = "Copilot Chat", ft = "copilot-chat", size = { width = 0.4 } },
          { title = "Tests", ft = "neotest", size = { width = 0.4 } },
          { title = "Test Summary", ft = "neotest-summary", size = { width = 0.3 } },
          {
            ft = "Outline",
            open = "SymbolsOutlineOpen",
          },
        },
      }

      return opts
    end,
  },
  {
    "eero-lehtinen/oklch-color-picker.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      -- One handed keymap recommended, you will be using the mouse
      { "<leader>v", "<cmd>ColorPickOklch<cr>", desc = "Color pick under cursor" },
    },
  },
  {
    "NvChad/nvim-colorizer.lua",
    enabled = false,
    event = "BufReadPre",
    opts = {
      filetypes = { "*", "!lazy" },
      buftype = { "*", "!prompt", "!nofile" },
      user_default_options = {
        names = false, -- "Name" codes like Blue
        RGB = true, -- #RGB hex codes
        RGBA = true, -- #RGBA hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        AARRGGBB = true, -- 0xAARRGGBB hex codes
        rgb_fn = true, -- CSS rgb() and rgba() functions
        hsl_fn = true, -- CSS hsl() and hsla() functions
        css = true, -- Enable all CSS *features*:
        -- names, RGB, RGBA, RRGGBB, RRGGBBAA, AARRGGBB, rgb_fn, hsl_fn
        css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn

        -- Tailwind colors.  boolean|'normal'|'lsp'|'both'.  True sets to 'normal'
        tailwind = true, -- Enable tailwind colors
        tailwind_opts = { -- Options for highlighting tailwind names
          update_names = true, -- When using tailwind = 'both', update tailwind names from LSP results.  See tailwind section
        },
        -- parsers can contain values used in `user_default_options`
        sass = { enable = false, parsers = { "css" } }, -- Enable sass colors
        -- Highlighting mode.  'background'|'foreground'|'virtualtext'
        mode = "virtualtext", -- Set the display mode.
        -- Virtualtext character to use
        virtualtext = "■",
        -- Display virtualtext inline with color.  boolean|'before'|'after'.  True sets to 'after'
        virtualtext_inline = false,
      },
    },
  },
}
