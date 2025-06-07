---@return LazyPluginSpec[]
return {
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        tailwindcss = {
          root_dir = require("lspconfig.util").root_pattern(".git"),
          settings = {
            tailwindCSS = {
              emmetCompletions = true,
            },
          },
        },
      },
    },
  },
}
