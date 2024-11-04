return {
  "chrishrb/gx.nvim",
  keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } } },
  cmd = { "Browse" },
  init = function()
    vim.g.netrw_nogx = 1 -- disable netrw gx
  end,
  dependencies = { "nvim-lua/plenary.nvim" },

  config = function()
    require("gx").setup({
      open_browser_app = "open", -- specify your browser app; default for macOS is "open", Linux "xdg-open" and Windows "powershell.exe"
      open_browser_args = {}, -- specify any arguments, such as --background for macOS' "open".
      handlers = {
        plugin = true, -- open plugin links in lua (e.g. packer, lazy, ..)
        github = true, -- open github issues
        brewfile = true, -- open Homebrew formulas and casks
        package_json = true, -- open dependencies from package.json
        search = true, -- search the web/selection on the web if nothing else is found
      },
      handler_options = {
        search_engine = "google", -- you can select between google, bing, duckduckgo, ecosia and yandex
        select_for_search = false, -- if your cursor is e.g. on a link, the pattern for the link AND for the word will always match. This disables this behaviour for default so that the link is opened without the select option for the word AND link
        git_remotes = { "upstream", "origin" }, -- list of git remotes to search for git issue linking, in priority
        git_remote_push = true, -- use the push url for git issue linking,
      },
    })
  end,
}
