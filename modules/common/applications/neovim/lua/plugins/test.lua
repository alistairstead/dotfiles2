return {
  {
    "neotest",
    opts = {
      icons = {
        child_indent = "│",
        child_prefix = "├",
        collapsed = "",
        expanded = "",
        failed = "",
        final_child_indent = " ",
        final_child_prefix = "└",
        non_collapsible = "─",
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
      status = {
        enabled = true,
        signs = true,
        virtual_text = true,
      },
    },
  },
  {
    "andythigpen/nvim-coverage",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        -- needed for nvim-coverage PHP cobertura parser. Requires `brew install luajit`
        "vhyrro/luarocks.nvim",
        priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
        opts = {
          rocks = { "lua-xmlreader" },
        },
      },
    },
    opts = function()
      return {
        highlights = {
          covered = { fg = LazyVim.ui.fg("DiagnosticOk").fg },
          uncovered = { fg = LazyVim.ui.fg("DiagnosticError").fg },
        },
        auto_reload = true,
        lcov_file = "./coverage/lcov.info",
      }
    end,
    keys = {
      {
        "<leader>tc",
        function()
          local coverage = require("coverage")
          if coverage.is_enabled() then
            coverage.clear()
          else
            coverage.load(true)
          end
        end,
        noremap = true,
        desc = "Toggle Coverage",
      },
    },
  },
}
