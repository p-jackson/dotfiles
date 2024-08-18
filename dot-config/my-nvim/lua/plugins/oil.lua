return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		columns = { "icon" },
		keymaps = {
			["<C-h>"] = false,
			["<C-l>"] = false,
		},
		view_options = {
			show_hidden = true,
		},
	}
}
