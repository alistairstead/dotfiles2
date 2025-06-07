local prompts = {
  -- Code related prompts
  BetterNamings = "Please provide better names for the following variables and functions.",
  -- Text related prompts
  Summarize = "Please summarize the following text.",
  Spelling = "Please correct any grammar and spelling errors in the following text.",
  Wording = "Please improve the grammar and wording of the following text.",
  Concise = "Please rewrite the following text to make it more concise.",
}

---@return LazyPluginSpec[]
return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    optional = true,
    opts = {
      prompts = prompts,
    },
    keys = {
      -- Code related commands
      { "<leader>ae", "<cmd>CopilotChatExplain<cr>", desc = "Explain code" },
      { "<leader>at", "<cmd>CopilotChatTests<cr>", desc = "Generate tests" },
      { "<leader>ar", "<cmd>CopilotChatReview<cr>", desc = "Review code" },
      { "<leader>ao", "<cmd>CopilotChatOptimize<cr>", desc = "Optimize code" },
      { "<leader>an", "<cmd>CopilotChatBetterNamings<cr>", desc = "Better Naming" },
      -- Custom input for CopilotChat
      {
        "<leader>ai",
        function()
          local input = vim.fn.input("Ask Copilot: ")
          if input ~= "" then
            vim.cmd("CopilotChat " .. input)
          end
        end,
        desc = "Ask input",
      },
      -- Generate commit message based on the git diff
      {
        "<leader>aM",
        "<cmd>CopilotChatCommit<cr>",
        desc = "Generate commit message for all changes",
      },
      {
        "<leader>am",
        "<cmd>CopilotChatCommit<cr>",
        desc = "Generate commit message for staged changes",
      },
      -- Create documentation
      { "<leader>ad", "<cmd>CopilotChatDocs<cr>", desc = "Draft documentation" },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")
      -- disable so we can use blink instead of cmp
      -- require("CopilotChat.integrations.cmp").setup()

      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-chat",
        callback = function()
          vim.opt_local.relativenumber = false
          vim.opt_local.number = false
        end,
      })

      chat.setup(opts)
    end,
  },
}
