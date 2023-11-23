local function listFiles(root, ext)
	local input = io.popen("find " .. root .. ' -type f |grep "\\.' .. ext .. '"')

	for file in input:lines() do
		local index = string.find(file, "[^\\/]*$")
		local className = string.sub(file, index):gsub("." .. ext, "")
		print("=> " .. className)
	end

	input:close()
end

local Unused = {}
Unused.javaClass = function()
	listFiles("../pocs/java-17-diamond", "java")
end

vim.api.nvim_create_user_command("UnusedJava", Unused.javaClass, {})

return Unused
