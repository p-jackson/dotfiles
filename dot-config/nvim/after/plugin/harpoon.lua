local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>a", mark.add_file)
vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

-- Alacritty maps Cmd+J to •`_´•j etc.
vim.keymap.set("n", "•`_´•j", function() ui.nav_file(1); vim.cmd("normal! zz"); end)
vim.keymap.set("n", "•`_´•k", function() ui.nav_file(2); vim.cmd("normal! zz"); end)
vim.keymap.set("n", "•`_´•l", function() ui.nav_file(3); vim.cmd("normal! zz"); end)
vim.keymap.set("n", "•`_´•;", function() ui.nav_file(4); vim.cmd("normal! zz"); end)

