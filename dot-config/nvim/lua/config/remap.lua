-- Show Oil for file management
vim.keymap.set("n", "<leader>ls", ":Oil<cr>")

-- Toggle undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- Keep cursor in the middle of the screen when scrolling and searching
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Create and focus new split
vim.keymap.set("n", "<leader>\\", ":vsplit<cr><C-w>w");
vim.keymap.set("n", "<leader>-", ":split<cr><C-w>w");

-- Close current window/split
vim.keymap.set("n", "<leader>dd", "<C-w>q");

-- Search notes from any project
vim.keymap.set("n", "<leader>zp",
	":Telescope find_files search_dirs={\"~/Library/Mobile\\ Documents/iCloud~md~obsidian/Documents/notes\"}<cr>")
vim.keymap.set("n", "<leader>zg",
	":Telescope live_grep search_dirs={\"~/Library/Mobile\\ Documents/iCloud~md~obsidian/Documents/notes\"}<cr>")

-- Run pdflatex on current file
vim.keymap.set("n", "<leader>pdf",
	":silent !pdflatex '%:p'<cr>")

-- Autofix using ESLint
vim.keymap.set("n", "<leader>ff", ":EslintFixAll<cr>")

-- Upload current wpcom file to sandbox
vim.keymap.set("n", "tu", function()
	vim.cmd("TransferUpload " .. vim.fn.expand("%:p"))
end)
-- Download current wpcom file from sandbox
vim.keymap.set("n", "td", function()
	vim.cmd("TransferDownload " .. vim.fn.expand("%:p"))
end)
vim.keymap.set("n", "tf", ":TransferDirDiff %:h<cr>")
-- Diff current wpcom directory with remote
vim.keymap.set("n", "tf", function()
	local path = vim.fn.expand("%:p")
	if vim.loop.fs_stat(path) ~= "directory" then
		path = vim.fn.expand("%:h")
	end
	vim.cmd("TransferDirDiff " .. path)
end)

-- Quickfix list navigation
-- Alacritty maps Cmd+J to •`_´•j etc.
vim.keymap.set("n", "•`_´•d", vim.diagnostic.setqflist)
vim.keymap.set("n", "•`_´•j", "<cmd>cnext<CR>")
vim.keymap.set("n", "•`_´•k", "<cmd>cprev<CR>")
