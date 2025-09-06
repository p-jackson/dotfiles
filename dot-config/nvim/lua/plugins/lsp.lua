return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"mason-org/mason-lspconfig.nvim",
			{ "j-hui/fidget.nvim",    opts = {} },
			"saghen/blink.cmp"
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("ConfigLspAttaching", { clear = true }),
				callback = function(event)
					vim.keymap.set("n", "<F2>", vim.lsp.buf.rename)
					vim.keymap.set({ "n", "x" }, "<F4>", vim.lsp.buf.code_action)
					vim.keymap.set("n", "K", function() vim.lsp.buf.hover({ border = "rounded" }) end)
					vim.keymap.set("n", "gr",
						function() require("telescope.builtin").lsp_references { path_display = { "smart" } } end, {})
					vim.keymap.set("n", "gi",
						function() require("telescope.builtin").lsp_implementations { path_display = { "smart" } } end, {})
					vim.keymap.set("n", "gd",
						function() require("telescope.builtin").lsp_definitions { path_display = { "smart" } } end, {})
					vim.keymap.set("n", "gt",
						function() require("telescope.builtin").lsp_type_definitions { path_display = { "smart" } } end, {})
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, {})
					vim.keymap.set("n", "<leader>fs", require("telescope.builtin").lsp_document_symbols, {})
					vim.keymap.set("n", "<leader>fS", require("telescope.builtin").lsp_dynamic_workspace_symbols, {})
					vim.keymap.set("n", "gl", function()
						vim.diagnostic.open_float({ border = "rounded" })
					end)

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
						local highlight_augroup = vim.api.nvim_create_augroup('ConfigLspCursorHolding', { clear = false })
						vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd('LspDetach', {
							group = vim.api.nvim_create_augroup('ConfigLspDetaching', { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds { group = 'ConfigLspCursorHolding', buffer = event2.buf }
							end,
						})
					end

					if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
						vim.keymap.set('n', '<leader>th', function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
						end, {})
					end
				end,
			})

			vim.diagnostic.config {
				virtual_text = true,
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = false,
			}

			local capabilities = pcall(require, 'blink.cmp') and require('blink.cmp').get_lsp_capabilities() or {}

			local server_configs = {
				ts_ls = {
					init_options = {
						hostInfo = 'neovim',
						maxTsServerMemory = 4096,
						tsserver = {
							useSyntaxServer = 'auto' }
					},
				},
				lua_ls = {
					settings = {
						Lua = {
							workspace = {
								library = {
									[vim.fn.stdpath "config"] = true,
									[vim.fn.stdpath "data" .. "/lazy/lazy.nvim"] = true,
								},
								checkThirdParty = false,
							},
							completion = {
								callSnippet = 'Replace',
							},
							diagnostics = {
								globals = { 'vim' },
							},
						},
					}
				},
				tinymist = {
					settings = {
						formatterMode = "typstyle",
					},
				},
			}

			require("mason-lspconfig").setup {
				ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
				automatic_installation = false,
				handlers = {
					function(server_name)
						local server = server_configs[server_name] or {}
						-- This handles overriding only values explicitly passed
						-- by the server configuration above. Useful when disabling
						-- certain features of an LSP (for example, turning off formatting for ts_ls)
						server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
						require('lspconfig')[server_name].setup(server)
					end,
				},
			}
		end
	},
}
