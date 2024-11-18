return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      "LiadOz/nvim-dap-repl-highlights",
    },
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "rcarriga/cmp-dap" },
    },
    optional = true,
    opts = function(_, opts)
      local cmp = require("cmp")
      cmp.setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
        sources = {
          { name = "dap" },
        },
      })
      opts.enabled = function()
        local buftype = nil
        buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
        return buftype ~= "prompt" or require("cmp_dap").is_dap_buffer()
      end
      return opts
    end,
  },
}
