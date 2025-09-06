local vault_path = vim.fn.expand "~" .. "/Library/Mobile Documents/iCloud~md~obsidian/Documents/notes"

return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	lazy = true,
	-- Only load plugin in vault, not for all .md files
	event = {
		"BufReadPre " .. vault_path .. "/**.md",
		"BufNewFile " .. vault_path .. "/**.md",
	},
	dependencies = {
		"saghen/blink.cmp",
		"nvim-telescope/telescope.nvim",
		"nvim-treesitter/nvim-treesitter",
		"MeanderingProgrammer/render-markdown.nvim",
	},
	---@module 'obsidian'
	---@type obsidian.config
	opts = {
		legacy_commands = false,
		ui = { enable = false }, -- render-markdown.nvim is handling markdown UI
		workspaces = {
			{
				name = "notes",
				path = vault_path,
			},
		},
		notes_subdir = "0-inbox",
		new_notes_location = "notes_subdir",
		disable_frontmatter = true, -- The plugin forces all md files to have frontmatter
		templates = {
			folder = "templates",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",
		},
		follow_url_func = function(url)
			vim.fn.jobstart({ "open", url }) -- Mac OS
			-- vim.fn.jobstart({"xdg-open", url})  -- linux
			-- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
		end,
		completion = {
			nvim_cmp = false,
			blink = true,
			min_chars = 2,
			create_new = true,
		},
		picker = {
			name = "telescope.nvim",
		},
		footer = {
			enabled = true,
		},
		---@param spec { id: string, dir: obsidian.Path, title: string|? }
		---@return string|obsidian.Path The full path to the new note.
		note_path_func = function(spec)
			local clean_cmd = string.format(
				"echo %q | tr '[:upper:]' '[:lower:]' | tr -dC '[:alnum:][:cntrl:]- ' | tr -s ' ' '-'", tostring(spec.title))
			local handle = io.popen(clean_cmd)
			if not handle then
				vim.notify("Failed to clean note title: " .. tostring(spec.title), vim.log.levels.ERROR)
				local path = spec.dir / spec.id
				return path:with_suffix ".md"
			end
			local cleaned_title = handle:read("*a"):gsub("%s+$", "")
			handle:close()

			local path = spec.dir / cleaned_title
			return path:with_suffix ".md"
		end,
		callbacks = {
			enter_note = function(_, note)
				vim.keymap.set("n", "<leader>zn", function()
					return vim.api.nvim_command("Obsidian template note")
				end, {
					buffer = note.bufnr,
				})
				vim.keymap.set("n", "<leader>zok", function()
					return vim.api.nvim_command(":silent !review-notes.rs --ok '%:p'\n\n:bd")
				end, {
					buffer = note.bufnr,
				})
				vim.keymap.set("n", "<leader>zdd", function()
					return vim.api.nvim_command(":silent !trash '%:p'\n\n:bd")
				end, {
					buffer = note.bufnr,
				})
			end,
		}
	},
}
