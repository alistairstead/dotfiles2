return {
  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
  },
  -- {
  --   "williamboman/mason.nvim",
  --   opts = function(_, opts)
  --     opts.ensure_installed = opts.ensure_installed or {}
  --     vim.list_extend(opts.ensure_installed, { "typos_lsp" })
  --   end,
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
