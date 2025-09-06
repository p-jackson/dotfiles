return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<F3>",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = "",
		},
	},
	opts = {
		notify_on_error = false,
		format_on_save = function(bufnr)
			if require("config.projects").is_buffer_in_calypso(bufnr) then
				-- Calypso is formatted with ESLint --fix-all, not an LSP
				-- See calypso-format.lua
				return nil
			end

			return {
				timeout_ms = 500,
				lsp_format = "fallback",
			}
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "prettierd", "prettier", stop_after_first = true },
			typst = { "typstyle" },
		},
		formatters = {
			typstyle = {
				prepend_args = { "--wrap-text" },
			},
		},
	},
}
