return {
	"oxfist/night-owl.nvim",
	lazy = false,
	priority = 1000,
	opts = {
		transparent_background = true,
	},
	config = function(_, opts)
		require("night-owl").setup(opts)
		vim.cmd.colorscheme("night-owl")
	end,
}

