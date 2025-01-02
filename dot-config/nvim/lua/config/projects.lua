local M = {}

M.is_buffer_in_project = function(bufnr, remote_url)
	local buf_path = vim.api.nvim_buf_get_name(bufnr)
	if not buf_path or buf_path == "" then
		return false
	end

	local git_cmd = "git -C " .. vim.fn.fnamemodify(buf_path, ":h") .. " remote -v";
	local git_output = vim.fn.systemlist(git_cmd);

	for _, line in ipairs(git_output) do
		if line:find(remote_url, 1, true) then
			return true
		end
	end

	return false
end

M.is_buffer_in_calypso = function(bufnr)
	return M.is_buffer_in_project(bufnr, "github.com:Automattic/wp-calypso")
end

return M
