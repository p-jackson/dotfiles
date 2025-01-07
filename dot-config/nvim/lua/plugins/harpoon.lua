return {
	"theprimeagen/harpoon",
	dependencies = {
		"nvim-lua/plenary.nvim"
	},
	config = function()
		local mark = require("harpoon.mark")
		local ui = require("harpoon.ui")

		require("harpoon").setup({
			menu = {
				width = 80
			}
		})

		vim.keymap.set("n", "<leader>a", mark.add_file)
		vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

		-- Alacritty maps Cmd+H to •`_´•h etc.
		vim.keymap.set("n", "•`_´•h", function()
			ui.nav_file(1); vim.cmd("normal! zz");
		end)
		vim.keymap.set("n", "•`_´•u", function()
			ui.nav_file(2); vim.cmd("normal! zz");
		end)
		vim.keymap.set("n", "•`_´•i", function()
			ui.nav_file(3); vim.cmd("normal! zz");
		end)
		vim.keymap.set("n", "•`_´•o", function()
			ui.nav_file(4); vim.cmd("normal! zz");
		end)
	end,
}
