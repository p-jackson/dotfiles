local projects = require("config.projects")
local lsp_zero = require("lsp-zero")

lsp_zero.on_attach(function(client, bufnr)
	lsp_zero.default_keymaps({ buffer = bufnr })

	if (projects.is_buffer_in_calypso(bufnr)) then
		-- Calypso is formatted with ESLint --fix-all, not an LSP
		-- See calypso-format.lua
		return;
	end

	lsp_zero.buffer_autoformat();
end)

require("mason").setup({})
require("mason-lspconfig").setup({
	ensure_installed = { "ts_ls", "rust_analyzer", "eslint", "lua_ls" },
	handlers = {
		-- this first function is the "default handler"
		-- it applies to every language server without a "custom handler"
		function(server_name)
			require("lspconfig")[server_name].setup({})
		end,

		-- this is the "custom handler" for `example_server`
		--[[
		example_server = function()
			require('lspconfig').example_server.setup({
				---
				-- in here you can add your own
				-- custom configuration
				---
			})
		end,
		]]
	},
})
