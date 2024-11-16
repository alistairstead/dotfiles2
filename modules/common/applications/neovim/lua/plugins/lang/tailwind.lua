return {
  {
    "neovim/nvim-lspconfig",
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
