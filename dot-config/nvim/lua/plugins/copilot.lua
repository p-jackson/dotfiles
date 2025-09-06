return {
	"github/copilot.vim",
	config = function()
		vim.keymap.set('i', '<C-Y>', 'copilot#Accept("\\<CR>")', {
			expr = true,
			replace_keycodes = false,
		})
		vim.g.copilot_no_tab_map = true
		vim.g.copilot_workspace_folders = {
			'~/dev/jetpack/',
			'~/dev/studio/',
			'~/dev/gutenberg/',
			'~/dev/wp-calypso/',
			'~/dev/wpcomsandbox/',
		}
	end
}
