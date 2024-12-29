---@return LazyPluginSpec[]
return {
  {
    "monaqa/dial.nvim",
    optional = true,
    opts = function()
      local opts = require("lazyvim.plugins.extras.editor.dial").opts()
      local augend = require("dial.augend")

      opts.dials_by_ft.lua = "lua"
      opts.groups.lua = opts.groups.lua or {}

      table.insert(opts.groups.lua, augend.constant.new({ elements = { "nil", "true", "false" } }))

      return opts
    end,
  },
}
