local vault_path = vim.fn.expand "~" .. "/Library/Mobile Documents/iCloud~md~obsidian/Documents/notes"

return {
	"epwalsh/obsidian.nvim",
	version = "*",
	lazy = true,
	-- Only load plugin in vault, not for all .md files
	event = {
		-- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
    "BufReadPre " .. vault_path .. "/**.md",
    "BufNewFile " .. vault_path .. "/**.md",
	},
	dependencies = {
		"nvim-lua/plenary.nvim"
	},
	opts = {
		workspaces = {
			{
				name = "notes",
				path = vault_path,
			},
		},
		notes_subdir = "0-inbox",
		new_notes_location = "notes_subdir",
		disable_frontmatter = true, -- The plugin forces all md files ot have frontmatter
		templates = {
			folder = "templates",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",
		},
		follow_url_func = function(url)
			vim.fn.jobstart({"open", url}) -- Mac OS
			-- vim.fn.jobstart({"xdg-open", url})  -- linux
			-- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
		end,
		mappings = {
			["<leader>ch"] = {
				action = function()
					return require("obsidian").util.toggle_checkbox()
				end,
				opts = { buffer = true },
			},
			["<cr>"] = {
				action = function()
					return require("obsidian").util.smart_action()
				end,
				opts = { buffer = true, expr = true },
			},
			["<leader>zn"] = {
				action = function()
					return vim.api.nvim_command("ObsidianTemplate note")
				end
			},
			["<leader>zok"] = {
				action = function()
					return vim.api.nvim_command(":silent !review-notes.rs --ok '%:p'\n\n:bd")
				end
			},
			["<leader>zdd"] = {
				action = function()
					return vim.api.nvim_command(":silent !trash '%:p'\n\n:bd")
				end
			}
		}
	}
}

