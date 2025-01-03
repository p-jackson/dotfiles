return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
		"nvim-tree/nvim-web-devicons",
		"nvim-telescope/telescope-ui-select.nvim",
	},
	config = function()
		require("telescope").setup {
			defaults = require('telescope.themes').get_ivy(),
			vimgrep_arguments = {
				'fd', '--type', 'f', '--hidden', '--follow', '--exclude', '.git', '--exclude', 'node_modules'
			},
			file_ignore_patterns = {
				"node_modules",
				"bower_components",
				".git",
				".svn",
				".hg",
				"CVS",
				".DS_Store",
				"Thumbs.db",
				".ruby-lsp",
				".code-search",
			},
			extensions = {
				fzf = {},
				['ui-select'] = {
					require('telescope.themes').get_dropdown(),
				},
			},
		}

		require("telescope").load_extension("fzf")
		require("telescope").load_extension("ui-select")

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "•`_´•p", function() builtin.find_files{ path_display = { "smart" } } end, {}) -- Alacritty maps Cmd+P to •`_´•p
		vim.keymap.set("n", "<leader>fr", builtin.resume, {}) -- Continue last telescope search
		vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
		vim.keymap.set("n", "<leader>fc", builtin.grep_string, {}) -- Search all files for text under cursor
		vim.keymap.set("n", "<leader>rg", builtin.live_grep, {}) -- Fuzzy find in file contents
		vim.keymap.set("n", "gr", function() builtin.lsp_references{ path_display = { "smart" } } end, {})
		vim.keymap.set("n", "gd", function() builtin.lsp_definitions{ path_display = { "smart" } } end, {})
	end,
}
