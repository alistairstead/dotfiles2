local lsp = vim.g.lazyvim_php_lsp or "phpactor"

---@return LazyPluginSpec[]
return {
  { import = "lazyvim.plugins.extras.lang.php" },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
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
    optional = true,
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
            phpcs = {
              enable = false,
            },
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
        php = {},
      },
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "olimorris/neotest-phpunit",
    },
    opts = function(_, opts)
      table.insert(
        opts.adapters,
        require("neotest-phpunit")({
          phpunit_cmd = "/etc/profiles/per-user/alistairstead/bin/dphpunit",
          root_files = { "composer.json", "phpunit.xml" },
          filter_dirs = { ".git", "node_modules" },
          type = "executable",
          env = {
            PHPUNIT_DEBUG = "false",
            APP_SERVICE = "app",
          },
          dap = require("dap").configurations.php[2],
        })
      )
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
              log = true,
              type = "php",
              request = "launch",
              name = "Listen for XDebug",
              port = 9003,
              pathMappings = {
                ["/var/www/html"] = "${workspaceFolder}",
              },
            },
            {
              type = "php",
              request = "launch",
              name = "Run test on Docker",
              port = 9003,
              log = true,
              -- hostname = "0.0.0.0",
              -- proxy = {
              --   enable = true,
              --   host = "app.bbg-website.orb.local",
              --   port = 9001,
              --   key = "neotest",
              -- },
              runtimeExecutable = "/etc/profiles/per-user/alistairstead/bin/dphp",
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
