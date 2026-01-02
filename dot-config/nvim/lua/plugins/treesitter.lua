return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	opts = {
		-- A list of parser names, or "all" (the listed parsers should always be installed)
		ensure_installed = {
			"bash", "c", "cpp", "css", "csv", "diff", "dockerfile", "editorconfig", "git_config", "git_rebase", "gitattributes",
			"gitcommit", "gitignore", "html", "ini", "javascript", "json", "lua", "luadoc", "make", "markdown",
			"markdown_inline",
			"php", "phpdoc", "rust", "scss", "sql", "tmux", "toml", "tsx", "typescript", "typst", "vim", "vimdoc",
			"yaml" },

		-- Install parsers synchronously (only applied to `ensure_installed`)
		sync_install = false,

		-- Automatically install missing parsers when entering buffer
		-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
		auto_install = true,

		-- List of parsers to ignore installing (or "all")
		ignore_install = {},

		highlight = {
			enable = true,

			-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
			-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
			-- Using this option may slow down your editor, and you may see some duplicate highlights.
			-- Instead of true it can also be a list of languages
			additional_vim_regex_highlighting = false,
		},
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
		vim.treesitter.language.register('tsx', 'typescriptreact')
	end
}

