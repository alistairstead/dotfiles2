-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

opt.laststatus = 3 -- show a single global status line
opt.foldlevel = 20
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.swapfile = false
opt.mouse = ""
opt.spelllang = "en_gb"

vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- this is necessary because nvim-treesitter is first in the runtimepath
vim.o.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
vim.o.spelloptions = table.concat({
  "noplainbuffer",
  "camel",
}, ",")
-- :h dictionary
if vim.fn.filereadable("/usr/share/dict/words") == 1 then
  opt.dictionary:append("/usr/share/dict/words")
end

-- prettier hidden chars. turn on with :set list or yol (different symbols)
opt.listchars = {
  space = " ",
  eol = " ", -- "↲",
  nbsp = "␣",
  trail = "·",
  precedes = "←",
  extends = "→",
  tab = "¬ ",
  conceal = "※",
}
vim.opt.list = false

-- show vert lines at the psr-2 suggested column limits
-- vim.o.colorcolumn = table.concat({
--   80,
--   120,
-- }, ",")

vim.api.nvim_create_user_command("Macro", function(args)
  vim.cmd("normal! q" .. args.args)
end, { nargs = 1, desc = "Create macro" })

-- italic comments https://stackoverflow.com/questions/3494435/vimrc-make-comments-italic
vim.cmd("highlight! Comment cterm=italic, gui=italic")
vim.cmd("highlight! Special cterm=italic, gui=italic")

vim.o.cmdheight = 0
vim.o.showcmdloc = "statusline"

-- highlight yanked text for 200ms using the "Visual" highlight group
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("hi_yanked_text", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
  desc = "highlight yanked text",
})

-- turn off relativenumber in insert mode and others {{{
local norelative_events = { "InsertEnter", "WinLeave", "FocusLost" }
local relative_events = { "InsertLeave", "WinEnter", "FocusGained", "BufNewFile", "BufReadPost" }
vim.api.nvim_create_augroup("relnumber_toggle", { clear = true })
vim.api.nvim_create_autocmd(relative_events, {
  group = "relnumber_toggle",
  callback = function()
    if vim.o.number then
      vim.o.relativenumber = true
    end
  end,
  desc = "turn on relative number",
})
vim.api.nvim_create_autocmd(norelative_events, {
  group = "relnumber_toggle",
  callback = function()
    if vim.o.number then
      vim.o.relativenumber = false
    end
  end,
  desc = "turn off relative number",
})
-- }}}

-- make all keymaps silent by default
local keymap_set = vim.keymap.set
---@diagnostic disable-next-line: duplicate-set-field
vim.keymap.set = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  return keymap_set(mode, lhs, rhs, opts)
end

vim.filetype.add({ pattern = { ["compose%.yml"] = "yaml.docker-compose" } })
vim.filetype.add({ pattern = { ["docker-compose%.yml"] = "yaml.docker-compose" } })
vim.filetype.add({ pattern = { ["Dockerfile-.*"] = "dockerfile" } })
vim.filetype.add({ pattern = { ["Dockerfile%..*"] = "dockerfile" } })
vim.filetype.add({ pattern = { [".env"] = "sh" } })
vim.filetype.add({ pattern = { [".envrc"] = "sh" } })
vim.filetype.add({ pattern = { [".env.example"] = "sh" } })

vim.g.lazyvim_picker = "fzf"
-- vim.g.lazyvim_php_lsp = "intelephense"
