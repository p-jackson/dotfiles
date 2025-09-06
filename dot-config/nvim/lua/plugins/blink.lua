return {
	'saghen/blink.cmp',
	event = 'VimEnter',
	version = '1.*',
	dependencies = {
		{
			'L3MON4D3/LuaSnip',
			version = '2.*',
			build = (function()
				if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
					return
				end
				return 'make install_jsregexp'
			end)(),
			opts = {},
		},
		'folke/lazydev.nvim',
	},
	opts = {
		keymap = {
			preset = 'default',
			['<C-y>'] = {
				function(cmp)
					-- Only accept if there's a selected completion item
					if cmp.is_visible() and cmp.get_selected_item() then
						return cmp.accept()
					else
						-- Return false to let the key fall through to other mappings
						return false
					end
				end,
				'fallback'
			},
		},

		appearance = {
			nerd_font_variant = 'mono',
		},

		completion = {
			-- By default, you may press `<c-space>` to show the documentation.
			-- Optionally, set `auto_show = true` to show the documentation after a delay.
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 0,
				window = { border = 'rounded' }
			},
			menu = { border = 'rounded' },
		},

		sources = {
			default = { 'lsp', 'path', 'snippets', 'lazydev' },
			providers = {
				lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
			},
		},

		snippets = { preset = 'luasnip' },

		-- Blink.cmp includes an optional, recommended rust fuzzy matcher,
		-- which automatically downloads a prebuilt binary when enabled.
		--
		-- By default, we use the Lua implementation instead, but you may enable
		-- the rust implementation via `'prefer_rust_with_warning'`
		--
		-- See :h blink-cmp-config-fuzzy for more information
		fuzzy = { implementation = 'prefer_rust_with_warning' },

		-- Shows a signature help window while you type arguments for a function
		signature = { enabled = true },
	},
}
