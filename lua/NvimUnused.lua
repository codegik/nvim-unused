local function readFile(file)
	local f = assert(io.open(file, "rb"))
	local content = f:read("*all")
	f:close()
	return content
end

local function listFiles(root, ext)
	local input = io.popen("find " .. root .. ' -type f |grep "\\.' .. ext .. '"')
	local files = {}

	for file in input:lines() do
		local index = file:find("[^\\/]*$")
		local class = file:sub(index):gsub("." .. ext, "")
		files[class] = file
	end

	input:close()

	return files
end

local skipByContent = { "void main" }

local function skipFileByContent(class, fileContent)
	for i, skip in ipairs(skipByContent) do
		if fileContent:find("\\" .. skip) then
			return true
		end
	end

	return false
end

local Unused = {}
Unused.javaClass = function()
	local files = listFiles("../pocs/java-17-diamond", "java")

	for class, file in pairs(files) do
		local founded = false
		local skiped = false

		print("==> testing " .. class)

		for classB, fileB in pairs(files) do
			if class == classB then
				skiped = true
			elseif not skiped then
				print(
					"==> "
						.. class
						.. " -- "
						.. classB
						.. " founded "
						.. tostring(founded)
						.. " skiped "
						.. tostring(skiped)
				)
				local fileContent = readFile(fileB)

				if skipFileByContent(classB, fileContent) then
					skiped = true
				elseif fileContent:find(class) then
					founded = true
				end
			end
		end

		if not skiped and not founded then
			print("=> Not used " .. file)
		end
	end
end

vim.api.nvim_create_user_command("UnusedJava", Unused.javaClass, {})

return Unused
