return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function()
				return vim.fn.executable 'make' == 1
			end,
		},
		"nvim-tree/nvim-web-devicons",
		"nvim-telescope/telescope-ui-select.nvim",
	},
	config = function()
		require("telescope").setup {
			defaults = require('telescope.themes').get_ivy(),
			vimgrep_arguments = {
				'fd', '--type', 'f', '--hidden', '--follow', '--exclude', '.git', '--exclude', 'node_modules'
			},
			file_ignore_patterns = {
				"node_modules",
				"bower_components",
				".git",
				".svn",
				".hg",
				"CVS",
				".DS_Store",
				"Thumbs.db",
				".ruby-lsp",
				".code-search",
			},
			extensions = {
				fzf = {},
				['ui-select'] = {
					require('telescope.themes').get_dropdown(),
				},
			},
		}

		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "ui-select")

		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")
		local make_entry = require("telescope.make_entry")
		local conf = require("telescope.config").values

		local live_grep_with_filters = pickers.new({
			prompt_title = "Live Grep (with filters)",
			debounce = 100,
			finder = finders.new_async_job({
				command_generator = function(prompt)
					if not prompt or prompt == "" then
						return nil
					end

					local pieces = vim.split(prompt, "  ")
					local args = { "rg" }

					if pieces[1] then
						table.insert(args, "-e") -- --regexp=
						table.insert(args, pieces[1])
					end
					if pieces[2] then
						table.insert(args, "-g") -- --glob=
						table.insert(args, pieces[2])
					end

					return vim.list_extend(args, {
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case"
					})
				end,
				cwd = vim.uv.cwd(),
				entry_maker = make_entry.gen_from_vimgrep(),
			}),
			previewer = conf.grep_previewer({}),
			sorter = require("telescope.sorters").empty(),
		})

		local builtin = require("telescope.builtin")

		-- Basic file finder, Ghostty maps Cmd+P to •`_´•p
		vim.keymap.set("n", "•`_´•p", function() builtin.find_files { path_display = { "smart" } } end, {})

		-- Continue last telescope search ( "find recent" )
		vim.keymap.set("n", "<leader>fr", builtin.resume, {})

		-- Find buffer ( "find buffers" )
		vim.keymap.set("n", "<leader>fb", builtin.buffers, {})

		-- Search all files for text under cursor
		vim.keymap.set("n", "<leader>fc", builtin.grep_string, {})

		-- vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, {}) -- Search symbols in current file

		-- Fuzzy find in file contents ( "ripgrep" )
		vim.keymap.set("n", "<leader>rg", builtin.live_grep, {})
		-- vim.keymap.set("n", "<leader>rg", function() live_grep_with_filters:find() end, {}) -- Fuzzy find in file contents

		-- Fuzzy find in file contents in folder ( "ripfolder" )
		vim.keymap.set("n", "<leader>rf",
			function()
				local current_dir = vim.bo.filetype == 'oil' and require('oil').get_current_dir() or vim.fn.expand('%:p:h')
				builtin.live_grep {
					prompt_title = "Live Grep in Folder",
					search_dirs = { current_dir },
					path_display = function(_, path)
						local without_trailing_slash = current_dir:gsub("/*$", "")
						return path:sub(#without_trailing_slash + 2)
					end
				}
			end, {})

		-- vim.keymap.set("n", "gr", function() builtin.lsp_references { path_display = { "smart" } } end, {})
		-- vim.keymap.set("n", "gd", function() builtin.lsp_definitions { path_display = { "smart" } } end, {})
	end,
}
