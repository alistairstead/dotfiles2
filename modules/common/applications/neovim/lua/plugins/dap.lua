return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      { "rcarriga/cmp-dap" },
    },
  },
  {
    "hrsh7th/nvim-cmp",
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
    end,
  },
}
