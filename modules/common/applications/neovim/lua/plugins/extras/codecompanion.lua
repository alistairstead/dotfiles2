local user = vim.env.USER or "User"
local fmt = string.format

return {
  {
    "olimorris/codecompanion.nvim",
    optional = true,
    cmd = {
      "CodeCompanion",
      "CodeCompanionActions",
      "CodeCompanionChat",
      "CodeCompanionCmd",
    },
    keys = {
      { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
      { "<leader>aa", "<cmd>CodeCompanionChat<cr>", mode = { "n", "v" }, desc = "Chat (CodeCompanion)" },
      { "<leader>ae", "<cmd>CodeCompanion /explain<cr>", mode = { "n", "v" }, desc = "Explain code" },
      { "<leader>al", "<cmd>CodeCompanion /lsp<cr>", mode = { "v" }, desc = "Explain LSP" },
      { "<leader>af", "<cmd>CodeCompanion /fix<cr>", mode = { "v" }, desc = "Fix code" },
      { "<leader>ap", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "Prompts" },
      {
        "<leader>acm",
        "<cmd>CodeCompanion /inline_commit<cr>",
        mode = { "n" },
        desc = "Commit message",
      },
      {
        "<leader>acw",
        "<cmd>CodeCompanion /cw<cr>",
        mode = { "n" },
        desc = "Code workflow",
      },
      {
        "<leader>abr",
        "<cmd>CodeCompanion /branch_review<cr>",
        mode = { "n" },
        desc = "Code review",
      },
      { "<leader>at", "<cmd>CodeCompanion /tests<cr>", mode = { "v" }, desc = "Generate tests" },
    },
    prompt_library = {
      ["Branch review"] = {
        strategy = "chat",
        description = "Perform a code review",
        opts = {
          short_name = "branch_review",
          auto_submit = true,
          user_prompt = false,
        },
        prompts = {
          {
            role = "user",
            contains_code = true,
            content = function(content)
              local target_branch = vim.fn.input("Target branch for merge base diff (default: master): ", "master")

              return fmt(
                [[You are a senior software engineer for the %s language performing a code review. Analyze the following code changes.
Identify any potential bugs, performance issues, security vulnerabilities, or areas that could
be refactored for better readability or maintainability.

Explain your reasoning clearly and provide specific suggestions for improvement.
Consider edge cases, error handling, and adherence to best practices and coding standards.
Here are the code changes:
```
  %s
```]],
                content.filetype,
                vim.fn.system("git diff --merge-base " .. target_branch)
              )
            end,
          },
        },
      },
      ["Auto-generate git commit message"] = {
        strategy = "inline",
        description = "Generate git commit message for current staged changes",
        opts = {
          short_name = "inline_commit",
          placement = "before|false",
          auto_submit = true,
        },
        prompts = {
          {
            role = "user",
            contains_code = true,
            content = function()
              return fmt(
                [[You are an expert at following the Conventional Commit specification.
Given the git diff listed below, please generate a commit message for me:
```diff
%s
```
Return the code only and no markdown codeblocks.]],
                vim.fn.system("git diff --no-ext-diff --staged")
              )
            end,
          },
        },
      },
    },
    opts = {
      extensions = {
        history = {
          enabled = true,
          opts = {
            keymap = "gh",
            auto_generate_title = true,
            continue_last_chat = false,
            delete_on_clearing_chat = false,
            -- picker = "snacks",
            enable_logging = true,
            dir_to_save = os.getenv("HOME") .. "/.codecompanion-history",
          },
        },
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            make_vars = true,
            make_slash_commands = true,
            show_result_in_chat = true,
          },
        },
        vectorcode = {
          opts = {
            add_tool = true,
          },
        },
      },
      adapters = {
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                default = "claude-3.7-sonnet",
              },
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = "copilot",
          roles = {
            llm = "  CodeCompanion",
            user = " " .. user,
          },
          keymaps = {
            stop = {
              modes = {
                n = { "<ESC>", "<C-c>" },
                i = { "<C-c>" },
              },
            },
            send = {
              modes = {
                i = { "<C-CR>", "<C-s>" },
                n = { "<CR>" },
              },
            },
            completion = {
              modes = {
                i = "<C-y>",
              },
            },
          },
          slash_commands = {
            ["buffer"] = {
              keymaps = {
                modes = {
                  i = "<C-b>",
                },
              },
            },
            ["help"] = {
              opts = {
                max_lines = 1000,
              },
            },
            ["image"] = {
              keymaps = {
                modes = {
                  i = "<C-i>",
                },
              },
            },
          },
          tools = {
            opts = {
              auto_submit_success = false,
              auto_submit_errors = false,
            },
          },
        },
        inline = { adapter = "copilot" },
      },
      display = {
        action_palette = {
          provider = "default",
        },
        chat = {
          show_references = true,
          -- show_header_separator = false,
          -- show_settings = false,
          start_in_insert_mode = true,
        },
      },
    },
    dependencies = {
      "j-hui/fidget.nvim", -- Display status
      "ravitemer/codecompanion-history.nvim", -- Save and load conversation history
      {
        "ravitemer/mcphub.nvim",
        cmd = "MCPHub",
        build = "npm install -g mcp-hub@latest",
        config = true,
      },
      {
        "Davidyz/VectorCode", -- Index and search code in your repositories
        version = "*",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    init = function()
      require("plugins.custom.spinner"):init()
    end,
  },
  -- Edgy integration
  {
    "folke/edgy.nvim",
    optional = true,
    opts = function(_, opts)
      opts.right = opts.right or {}
      table.insert(opts.right, {
        ft = "codecompanion",
        title = "CodeCompanion Chat",
        size = { width = 50 },
      })
    end,
  },
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "olimorris/codecompanion.nvim", "saghen/blink.compat" },
    opts = {
      sources = {
        per_filetype = {
          codecompanion = { "codecompanion" },
        },
      },
    },
  },
}
