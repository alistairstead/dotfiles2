return {
  {
    "andythigpen/nvim-coverage",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "folke/tokyonight.nvim",
      {
        -- needed for nvim-coverage PHP cobertura parser. Requires `brew install luajit`
        "vhyrro/luarocks.nvim",
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
          if require("coverage.signs").is_enabled() then
            require("coverage").clear()
          else
            require("coverage").load(true)
          end
        end,
        noremap = true,
        desc = "Toggle Coverage",
      },
    },
  },
}
