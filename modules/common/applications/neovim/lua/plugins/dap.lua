return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      "LiadOz/nvim-dap-repl-highlights",
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    optional = true,
    opts = {
      icons = { expanded = "", collapsed = "", current_frame = "" },
      controls = {
        icons = {
          pause = "󰏦",
          play = "",
          step_into = "",
          step_over = "",
          step_out = "",
          step_back = "",
          run_last = "",
          terminate = "",
          disconnect = "",
        },
      },
    },
  },
  -- {
  --   "nvim-lualine/lualine.nvim",
  --   optional = true,
  --   event = "VeryLazy",
  --   opts = function(_, opts)
  --     table.insert(
  --       opts.sections.lualine_x,
  --       3,
  --       LazyVim.lualine.status("", function()
  --         -- local status = require("dap").status()
  --         local session = require("dap").session()
  --         if session then
  --           -- return (status == "InProgress" and "pending") or (status == "Warning" and "error") or "ok"
  --           return "ok"
  --         end
  --       end)
  --     )
  --   end,
  -- },
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = {
      { "rcarriga/cmp-dap" },
    },
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
