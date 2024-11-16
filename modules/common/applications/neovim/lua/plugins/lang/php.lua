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
              return "/Users/alistairstead/.local/share/bin/dphpunit"
            end,
            root_files = { "composer.json", "phpunit.xml" },
            filter_dirs = { ".git", "node_modules" },
            env = {
              CONTAINER = "broadbandgenie-website-app-1",
              REMOTE_PHPUNIT_BIN = "bin/phpunit",
            }, -- for example {XDEBUG_CONFIG = 'idekey=neotest'}
            dap = nil,
          },
        },
      }
    end,
  },
}
