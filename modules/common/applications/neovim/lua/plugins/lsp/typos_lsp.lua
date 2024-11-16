return {
  -- {
  --   "williamboman/mason.nvim",
  --   opts = {
  --     ensure_installed = {
  --       "typos_lsp",
  --     },
  --   },
  -- },
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        typos_lsp = {
          settings = {
            diagnosticSeverity = "Warning",
          },
        },
      },
    },
  },
}
