local Unused = {}

Unused.javaClass = function()
	print("searching for unused java classes...")
end

vim.api.nvim_create_user_command("Unused", Unused.javaClass, {})

return Unused
