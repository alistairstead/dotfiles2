local lsp = vim.g.lazyvim_php_lsp or "phpactor"

return {
  { import = "lazyvim.plugins.extras.lang.php" },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      local function add(lang)
        if type(opts.ensure_installed) == "table" then
          table.insert(opts.ensure_installed, lang)
        end
      end

      add("twig")
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- phpcs = function()
        --   return true
        -- end,
        phpactor = {
          enabled = lsp == "phpactor",
        },
        intelephense = {
          enabled = lsp == "intelephense",
          init_options = {
            licenceKey = "/Users/alistairstead/Documents/intelephense.txt",
          },
          settings = {
            intelephense = {
              telemetry = {
                enabled = false,
              },
              completion = {
                fullyQualifyGlobalConstantsAndFunctions = true,
              },
              format = {
                enable = true,
              },
              filetypes = { "php" },
              files = {
                associations = { "*.php" },
                maxSize = 1000000,
                exclude = {
                  "**/.git/**",
                  "**/.svn/**",
                  "**/.hg/**",
                  "**/CVS/**",
                  "**/.DS_Store/**",
                  "**/node_modules/**",
                  "**/bower_components/**",
                  "**/vendor/**/{Tests,tests}/**",
                  "**/.history/**",
                  "**/vendor/**/vendor/**",
                },
              },
            },
          },
        },
        [lsp] = {
          enabled = true,
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        php = { "phpcs" },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "olimorris/neotest-phpunit",
    },
    opts = function()
      return {
        adapters = {
          ["neotest-phpunit"] = {
            phpunit_cmd = function()
              local config_path = vim.fn.stdpath("config")
              return config_path .. "/../bin/dphpunit"
            end,
            root_files = { "composer.json", "phpunit.xml" },
            filter_dirs = { ".git", "node_modules" },
            env = {
              XDEBUG_CONFIG = "idekey=neotest",
              CONTAINER = "broadbandgenie-website-app-1",
              REMOTE_PHPUNIT_BIN = "bin/phpunit",
            },
            dap = require("dap").configurations.php[1],
          },
        },
      }
    end,
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "williamboman/mason.nvim",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          table.insert(opts.ensure_installed, "js-debug-adapter")
        end,
      },
    },
    opts = function()
      local dap = require("dap")

      local php_filetypes = { "php" }

      for _, language in ipairs(php_filetypes) do
        if not dap.configurations[language] then
          dap.configurations[language] = {
            {
              type = "php",
              request = "launch",
              name = "Symfony",
              port = 9003,
              pathMappings = {
                ["${workspaceFolder}"] = "${workspaceFolder}",
                ["/var/www/html"] = "${workspaceFolder}",
              },
            },
            {
              type = "php",
              request = "launch",
              name = "Docker",
              port = 9003,
              pathMappings = {
                ["/var/www/html"] = "${workspaceFolder}",
              },
            },
          }
        end
      end
    end,
  },
  {
    "monaqa/dial.nvim",
    optional = true,
    opts = function()
      local opts = require("lazyvim.plugins.extras.editor.dial").opts()
      local augend = require("dial.augend")

      local checkboxes = augend.constant.new({
        -- pattern_regexp = "\\[.]\\s", -- TODO: doesn't work
        elements = { "[ ]", "[x]", "[-]" },
        word = false,
        cyclic = true,
      })

      table.insert(opts.groups.markdown, checkboxes)

      opts.dials_by_ft.php = "php"
      opts.groups.php = opts.groups.php or {}

      table.insert(opts.groups.php, augend.constant.new({ elements = { "public", "private", "protected" } }))
      table.insert(opts.groups.php, augend.constant.new({ elements = { "abstract", "final" } }))
      table.insert(
        opts.groups.php,
        augend.case.new({
          types = { "camelCase", "PascalCase", "snake_case", "kebab-case", "SCREAMING_SNAKE_CASE" },
          cyclic = true,
        })
      )
      table.insert(
        opts.groups.php,
        augend.constant.new({
          elements = { "&&", "||" },
          word = false,
          cyclic = true,
        })
      )
      table.insert(
        opts.groups.php,
        augend.constant.new({ elements = { "true", "false" }, word = false, cyclic = true })
      )
      table.insert(opts.groups.php, augend.integer.alias.decimal)
      table.insert(opts.groups.php, augend.date.alias["%Y-%m-%d"])

      return opts
    end,
    keys = {
      { "<CR>", "<Cmd>norm <C-a><CR>", mode = "n", noremap = true, desc = "Dial" },
    },
  },
}
