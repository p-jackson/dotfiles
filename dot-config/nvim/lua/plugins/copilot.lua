return {
	"github/copilot.vim",
	enabled = false,
	config = function()
		vim.keymap.set("i", "<C-y>", function()
			if vim.fn.pumvisible() == 1 then
				return vim.keycode("<C-y>")
			end

			return vim.fn["copilot#Accept"]("<CR>")
		end, {
			expr = true,
			replace_keycodes = false,
		})
		vim.g.copilot_no_tab_map = true
		vim.g.copilot_workspace_folders = {
			"~/dev/jetpack/",
			"~/dev/studio/",
			"~/dev/gutenberg/",
			"~/dev/wp-calypso/",
			"~/dev/wpcomsandbox/",
		}
	end,
}
