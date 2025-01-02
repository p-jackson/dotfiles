return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"williamboman/mason.nvim"
		},
		config = function()
			local dap = require "dap";
			local ui = require "dapui";

			ui.setup();

			local codelldb = vim.fn.exepath "codelldb";
			if codelldb == "" then
				codelldb = vim.fn.stdpath "data" .. "/mason/bin/codelldb";
			end

			if codelldb ~= "" then
				dap.adapters.codelldb = {
					type = "executable",
					command = codelldb,
				};
				dap.configurations.rust = {
					{
						name = "Launch file",
						type = "codelldb",
						request = "launch",
						program = function()
							return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file");
						end,
						cwd = "${workspaceFolder}",
						stopOnEntry = false,
					},
				};
			end

			vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint);
			vim.keymap.set("n", "<leader>gb", dap.run_to_cursor);
			vim.keymap.set("n", "<leader>?", function() ui.eval(nil, { enter = true }) end);

			vim.keymap.set("n", "<F8>", dap.continue);
			vim.keymap.set("n", "<F10>", dap.step_over);
			vim.keymap.set("n", "<F11>", dap.step_into);
			vim.keymap.set("n", " •`_´•f11", dap.step_out); -- Custom ghostty remap for S-F11
			vim.keymap.set("n", "<F12>", dap.restart);

			dap.listeners.before.attach.dapui_config = function()
				ui.open();
			end
			dap.listeners.before.launch.dapui_config = function()
				ui.open();
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				ui.close();
			end
			dap.listeners.before.event_exited.dapui_config = function()
				ui.close();
			end
		end,
	},
}
