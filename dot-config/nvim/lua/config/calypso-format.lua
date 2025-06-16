-- Calypso is formatted with ESLint --fix-all, not an LSP

local projects = require "config.projects"

vim.api.nvim_create_autocmd('BufWritePre', {
	group = vim.api.nvim_create_augroup('CalypsoFormatting', {}),
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		if projects.is_buffer_in_calypso(bufnr) then
			vim.cmd('LspEslintFixAll')
		end
	end
})
