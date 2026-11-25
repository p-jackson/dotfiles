vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.lazy")

vim.cmd("packadd nvim.undotree")

-- vim.pack.add({
-- 	{ src = "https://github.com/tpope/vim-fugitive" },
-- 	{ src = "https://github.com/tpope/vim-surround" },
-- 	{ src = "https://github.com/folke/todo-comments.nvim" },
-- })

-- require('todo-comments').setup({ signs = false })

require("config.opts")
require("config.remap")
require("config.highlight-on-yank")
require("config.calypso-format")
require("config.sync-color-scheme")
