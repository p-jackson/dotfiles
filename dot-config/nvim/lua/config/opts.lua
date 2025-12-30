vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.updatetime = 500
vim.wo.wrap = false
vim.o.cursorline = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.wo.signcolumn = "yes"
vim.o.statusline = "%<%f %h%w%m%r%=%y %l:%c %P"

-- Relative line numbering in Netrw
vim.g.netrw_bufsettings = "noma nomod nonu nobl nowrap ro rnu"

-- Disable vim's backup system and use undotree instead
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- Sync clipboard between OS and Neovim.
-- Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
	vim.o.clipboard = 'unnamedplus'
end)

-- Used by obsidian to format md nicely, but if it starts to hide things
-- in other languages then we should move this to a ftplugin
vim.opt.conceallevel = 2

vim.filetype.add({
	extension = {
		mdc = 'markdown',
	},
})
