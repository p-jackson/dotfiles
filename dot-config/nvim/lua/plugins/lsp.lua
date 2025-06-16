return {
	{ "mason-org/mason.nvim" },
	{
		"mason-org/mason-lspconfig.nvim",
		--		opts = {
		--			ensure_installed = { 'ts_ls', 'rust_analyzer', 'sumneko_lua' },
		--			handlers = {
		--				function(server_name)
		--					require("lspconfig")[server_name].setup({})
		--				end,
		--			}
		--		}
	},
	{ "VonHeikemen/lsp-zero.nvim", branch = "v3.x" },
	{ "neovim/nvim-lspconfig" },
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "hrsh7th/nvim-cmp" },
	{ "L3MON4D3/LuaSnip" },
}
