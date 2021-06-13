if SERVER then
	AddCSLuaFile("includes/modules/core.lua")
end
require("core")


local function IncludeDirectory(dir)
	// Shared
	local components, _ = file.Find(dir .. "/sh_*.lua", "LUA")
	for _, component in pairs(components) do
		if SERVER then
			AddCSLuaFile(dir .. "/" .. component)
		end
		include(dir .. "/" .. component)
	end

	// Server
	if SERVER then
		local components, _ = file.Find(dir .. "/sv_*.lua", "LUA")
		for _, component in pairs(components) do
			include(dir .. "/" .. component)
		end
	end

	// Client
	local components, _ = file.Find(dir .. "/cl_*.lua", "LUA")
	for _, component in pairs(components) do
		if SERVER then
			AddCSLuaFile(dir .. "/" .. component)
		else
			include(dir .. "/" .. component)
		end
	end

	// Directories
	local _, directories = file.Find(dir .. "/*", "LUA")
	for _, directory in pairs(directories) do
		IncludeDirectory(dir .. "/" .. directory)
	end
end

IncludeDirectory("components")
galactic:Initialize()