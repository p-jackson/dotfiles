local builtin = require("telescope.builtin")
vim.keymap.set("n", "•`_´•p", builtin.find_files, {}) -- Alacritty maps Cmd+P to •`_´•p
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fc", builtin.grep_string, {}) -- Search all files for text under cursor
vim.keymap.set("n", "<leader>rg", builtin.live_grep, {}) -- Fuzzy find in file contents
vim.keymap.set("n", "gr", builtin.lsp_references, {})
