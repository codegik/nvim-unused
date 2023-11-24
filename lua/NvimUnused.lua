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

local function skipFileByContent(file, fileContent)
	for i, skip in ipairs(skipByContent) do
		if fileContent:find(skip) then
			return true
		end
		if file:find("src/test") then
			return true
		end
	end

	return false
end

local Unused = {}
Unused.javaClass = function()
	local files = listFiles("../pocs/java-21-observability", "java")

	for class, file in pairs(files) do
		local used = false
		local skipped = false
		local classContent = readFile(file)

		if skipFileByContent(file, classContent) then
			skipped = true
		else
			for classB, fileB in pairs(files) do
				if class ~= classB and not skipped then
					local classBContent = readFile(fileB)

					if classBContent:find(class) then
						used = true
					end
				end
			end
		end

		if not skipped and not used then
			print("=> Not used " .. file)
		end
	end
end

vim.api.nvim_create_user_command("UnusedJava", Unused.javaClass, {})

return Unused
