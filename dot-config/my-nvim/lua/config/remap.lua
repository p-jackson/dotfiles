-- Show folder explorer (Netrw)
vim.keymap.set("n", "<leader>ls", vim.cmd.Ex)

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

