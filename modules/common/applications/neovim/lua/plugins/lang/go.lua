---@return LazyPluginSpec[]
return {
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-go",
    },
    opts = function(_, opts)
      table.insert(
        opts.adapters,
        require("neotest-go")({
          experimental = {
            test_table = true,
          },
          recursive_run = true,
        })
      )
    end,
  },
}
