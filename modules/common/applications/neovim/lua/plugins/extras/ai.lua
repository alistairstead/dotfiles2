local prompts = {
  -- Code related prompts
  Explain = "Please explain how the following code works.",
  Review = "Please review the following code and provide suggestions for improvement.",
  Tests = "Please explain how the selected code works, then generate vitest unit tests for it using describe() and it().",
  Refactor = "Please refactor the following code to improve its clarity and readability.",
  FixCode = "Please fix the following code to make it work as intended.",
  FixError = "Please explain the error in the following text and provide a solution.",
  BetterNamings = "Please provide better names for the following variables and functions.",
  Documentation = "Please provide documentation for the following code.",
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
    -- opts = {
    --   prompts = prompts,
    -- },
    -- keys = {
    --   -- Code related commands
    --   { "<leader>ae", "<cmd>CopilotChatExplain<cr>", desc = "Explain code" },
    --   { "<leader>at", "<cmd>CopilotChatTests<cr>", desc = "Generate tests" },
    --   { "<leader>ar", "<cmd>CopilotChatReview<cr>", desc = "Review code" },
    --   { "<leader>aR", "<cmd>CopilotChatRefactor<cr>", desc = "Refactor code" },
    --   { "<leader>an", "<cmd>CopilotChatBetterNamings<cr>", desc = "Better Naming" },
    --   -- Custom input for CopilotChat
    --   {
    --     "<leader>ai",
    --     function()
    --       local input = vim.fn.input("Ask Copilot: ")
    --       if input ~= "" then
    --         vim.cmd("CopilotChat " .. input)
    --       end
    --     end,
    --     desc = "Ask input",
    --   },
    --   -- Generate commit message based on the git diff
    --   {
    --     "<leader>aM",
    --     "<cmd>CopilotChatCommit<cr>",
    --     desc = "Generate commit message for all changes",
    --   },
    --   {
    --     "<leader>am",
    --     "<cmd>CopilotChatCommitStaged<cr>",
    --     desc = "Generate commit message for staged changes",
    --   },
    --   -- Create documentation
    --   { "<leader>ad", "<cmd>CopilotChatDocs<cr>", desc = "Draft documentation" },
    -- },
    -- config = function(_, opts)
    --   local chat = require("CopilotChat")
    --   -- disable so we can use blink instead of cmp
    --   -- require("CopilotChat.integrations.cmp").setup()
    --
    --   vim.api.nvim_create_autocmd("BufEnter", {
    --     pattern = "copilot-chat",
    --     callback = function()
    --       vim.opt_local.relativenumber = false
    --       vim.opt_local.number = false
    --     end,
    --   })
    --
    --   chat.setup(opts)
    -- end,
  },
}
