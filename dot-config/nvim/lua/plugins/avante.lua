return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	lazy = false,
	version = "*",
	opts = {
		provider = "claude",
		providers = {
			claude = {
				endpoint = "https://api.anthropic.com",
				model = "claude-sonnet-4-20250514",
				extra_request_body = {
					temperature = 0,
					max_tokens = 4096,
				},
			},
		},
		behaviour = {
			enable_cursor_planning_mode = true,
			enable_claude_text_editor_tool_mode = true,
		},
		windows = {
			ask = {
				start_insert = false,
			},
		},
	},
	build = "make",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		--- The below dependencies are optional,
		"echasnovski/mini.pick", -- for file_selector provider mini.pick
		{
			-- Make sure to set this up properly if you have lazy=true
			'MeanderingProgrammer/render-markdown.nvim',
			enabled = false,
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
}
