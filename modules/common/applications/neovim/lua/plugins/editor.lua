return {
  { "editorconfig/editorconfig-vim" },
  {
    "ChrisLetter/cspell-ignore",
    opts = { cspell_path = "./cspell.json" },
    commands = { "CspellIgnore" },
    keys = {
      { "<Leader>ci", "<Cmd>CspellIgnore<CR>", noremap = true, desc = "Cspell Ignore" },
    },
  },
}
