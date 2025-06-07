---@return LazyPluginSpec[]
return {
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "nvim-neotest/nvim-nio" },
    ---@class neotest.Config
    opts = {
      icons = {
        child_indent = " ",
        child_prefix = " ",
        collapsed = "",
        expanded = "",
        failed = "",
        final_child_indent = " ",
        final_child_prefix = " ",
        non_collapsible = " ",
        notify = "",
        passed = "",
        running = "",
        running_animated = {
          "⠋",
          "⠙",
          "⠹",
          "⠸",
          "⠼",
          "⠴",
          "⠦",
          "⠧",
          "⠇",
          "⠏",
        },
        skipped = "",
        unknown = "",
        watching = "",
      },
      -- status = {
      --   enabled = true,
      --   signs = true,
      --   virtual_text = true,
      -- },
    },
  },
  {
    "andythigpen/nvim-coverage",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        -- needed for nvim-coverage PHP cobertura parser. Requires luajit
        "vhyrro/luarocks.nvim",
        priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
        opts = {
          rocks = { "lua-xmlreader" },
        },
      },
    },
    opts = {
      -- highlights = {
      --   covered = { fg = Snacks.util.color("DiagnosticOk") },
      --   uncovered = { fg = Snacks.util.color("DiagnosticError") },
      -- },
      auto_reload = true,
      lcov_file = "./coverage/lcov.info",
    },
    keys = {
      {
        "<leader>tc",
        "<cmd>CoverageToggle<cr>",
        noremap = true,
        desc = "Toggle Coverage",
      },
    },
  },
}
