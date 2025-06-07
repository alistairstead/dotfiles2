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
      {
        "<Leader>aa",
        "<cmd>CodeCompanionChat Toggle<CR>",
        desc = "Toggle chat buffer",
        mode = { "n", "v" },
      },
      {
        "<Leader>ai",
        "<cmd>CodeCompanionChat<CR>",
        desc = "New chat buffer",
        mode = { "n", "v" },
      },
      { "<leader>ae", "<cmd>CodeCompanion /explain<cr>", mode = { "n", "v" }, desc = "Explain code" },
      { "<leader>al", "<cmd>CodeCompanion /lsp<cr>", mode = { "v" }, desc = "Explain LSP" },
      { "<leader>af", "<cmd>CodeCompanion /fix<cr>", mode = { "v" }, desc = "Fix code" },
      { "<leader>ap", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "Prompts" },
      {
        "<leader>am",
        "<cmd>CodeCompanion /cm<cr>",
        mode = { "n" },
        desc = "Commit message inline",
      },
      {
        "<leader>aM",
        "<cmd>CodeCompanion /commit<cr>",
        mode = { "n" },
        desc = "Commit message",
      },
      {
        "<leader>ac",
        "<cmd>CodeCompanion /cw<cr>",
        mode = { "n" },
        desc = "Code workflow",
      },
      {
        "<leader>ar",
        "<cmd>CodeCompanion /branch_review<cr>",
        mode = { "n" },
        desc = "Code review",
      },
      { "<leader>at", "<cmd>CodeCompanion /tests<cr>", mode = { "v" }, desc = "Generate tests" },
      {
        "<C-a>",
        "<cmd>CodeCompanionActions<CR>",
        desc = "Open the action palette",
        mode = { "n", "v" },
      },
      -- {
      --   "<LocalLeader>ac",
      --   "<cmd>CodeCompanionChat Add<CR>",
      --   mode = { "v" },
      --   desc = "Add code to a chat buffer",
      -- },
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
      prompt_library = {
        ["Branch_Review"] = {
          strategy = "chat",
          description = "Perform a code review of the current changeset to the target beanch",
          opts = {
            short_name = "branch_review",
            auto_submit = true,
            user_prompt = false,
          },
          prompts = {
            {
              role = "system",
              content = function(context)
                return "I want you to act as a senior "
                  .. context.filetype
                  .. "performing a very detailed code review. "
              end,
            },
            {
              role = "user",
              content = function()
                local branch = vim.fn.input("Target branch for merge base diff (default: master): ", "master")
                local diff = vim.fn.system("git diff --merge-base " .. branch)
                return "<user_prompt>Analyze the following code changes:"
                  .. "```diff\n"
                  .. diff
                  .. "```\n"
                  .. "Identify any potential bugs, performance issues, security vulnerabilities, or areas that could"
                  .. "be refactored for better readability or maintainability."
                  .. "Create a list of isolated refactorings for any changes that are described in a way for a junior"
                  .. "developt to be able to understand and complete them.</user_prompt>"
              end,
            },
          },
        },
        ["Inline Commit Message"] = {
          strategy = "inline",
          description = "Generate an inline commit message",
          opts = {
            placement = "replace",
            short_name = "cm",
            user_prompt = false,
          },
          prompts = {
            {
              role = "system",
              content = function(context)
                return "I want you to act as a senior "
                  .. context.filetype
                  .. "engineer and an expert at following the Conventional Commit specification"
              end,
            },
            {
              role = "user",
              content = function()
                local diff = vim.fn.system("git diff --no-ext-diff --staged")
                return "<user_prompt>Given the git diff listed below, please generate a commit message for me:"
                  .. "```diff\n"
                  .. diff
                  .. "```\n"
                  .. "Return just the commit message, without any additional text or formatting.</user_prompt>"
              end,
              opts = {
                contains_code = true,
              },
            },
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
          },
          tools = {
            opts = {
              auto_submit_success = true,
              auto_submit_errors = true,
            },
          },
        },
        inline = { adapter = "copilot" },
      },
      display = {
        chat = {
          show_references = true,
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
        build = "pipx upgrade vectorcode",
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
