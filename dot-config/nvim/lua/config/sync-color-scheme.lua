local function sync_theme()
	local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
	local result = handle:read("*a")
	handle:close()

	local is_dark = result:match("Dark") ~= nil
	local desired = is_dark and "dark" or "light"

	if vim.o.background ~= desired then
		vim.o.background = desired
	end
end

sync_theme()

-- Poll every 3 seconds while Neovim is running
local timer = vim.uv.new_timer()
timer:start(3000, 3000, vim.schedule_wrap(sync_theme))

-- Also re-check on focus, which catches most cases instantly
vim.api.nvim_create_autocmd("FocusGained", { callback = sync_theme })
