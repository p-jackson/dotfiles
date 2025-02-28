return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		version = "3.3.3",
		dependencies = {
			{
				"github/copilot.vim",
				config = function()
					vim.keymap.set('i', '<C-Y>', 'copilot#Accept("\\<CR>")', {
						expr = true,
						replace_keycodes = false,
					})
					vim.g.copilot_no_tab_map = true
					vim.g.copilot_filetypes = {
						['copilot-chat'] = false,
						['copilot-diff'] = false,
						['copilot-overlay'] = false,
					}
					vim.g.copilot_workspace_folders = {
						'~/dev/jetpack/',
						'~/dev/studio/',
						'~/dev/wp-calypso/',
						'~/dev/wpcomsandbox/',
					}
				end
			},
			{ "nvim-lua/plenary.nvim", branch = "master" },
		},
		config = function()
			local chat = require("CopilotChat")
			chat.setup({
				window = {
					title = 'Chatty McChatface',
					width = 0.33,
				},

				question_header = '# Me ',
				answer_header = '# Chatty McChatface ',

				mappings = {
					complete = {
						insert = '<C-Y>',
					},
					reset = {
						insert = '<C-R>',
						normal = '<C-R>',
					},
					accept_diff = {
						insert = '<C-A>',
						normal = '<C-A>',
					},
				},

				prompts = {
					Commit =
					'> #git:staged\n\nWrite commit message for the change with using a style recommended in the famous "better commit messages" post from Thoughtbot. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Remember to answer the questions: why is this change necessary, how does it address the issue, what side effects does this change have. Do not use them as headings though, just write prose. Wrap the whole message in code block with language gitcommit.',
				}
			})

			-- Copilot chat
			vim.keymap.set({ "n", "v" }, "<leader>cc", function() require("CopilotChat").open() end)

			-- Perplexity chat
			vim.keymap.set({ "n", "v" }, "<leader>pp", function()
				local input = vim.fn.input("Perplexity: ")
				if input ~= "" then
					require("CopilotChat").ask(input, { agent = "perplexityai", selection = false })
				end
			end)

			-- Inline copilot chat (whole buffer)
			vim.keymap.set({ "n" }, "<leader>ci", function()
				local input = vim.fn.input("Copilot: ")
				if input ~= "" then
					require("CopilotChat").ask(input, {
						agent = "copilot",
						selection = require("CopilotChat.select").buffer,
					})
				end
			end)

			-- Inline copilot chat (selection)
			vim.keymap.set({ "v" }, "<leader>ci", function()
				local input = vim.fn.input("Copilot: ")
				if input ~= "" then
					require("CopilotChat").ask(input, {
						agent = "copilot",
						selection = require("CopilotChat.select").visual,
					})
				end
			end)

			-- Commit message help
			vim.keymap.set("n", "<leader>cm", ":CopilotChatCommit<cr>")
		end,
	},
}
