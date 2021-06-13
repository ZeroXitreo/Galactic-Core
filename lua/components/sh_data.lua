local component = {}
component.namespace = "data"
component.title = "Data"

component.path = "galactic/"
component.tableExtension = ".json"
component.textExtension = ".txt"

function component:HandleFilePath(filePath, extension) // "folder/file"
	filePath = self.path .. filePath

	local path = string.GetPathFromFilename(filePath) // "folder/"
	local fileName = string.GetFileFromFilename(filePath) // "file.json"
	local name = string.StripExtension(fileName) // "file"

	fileName = name .. extension

	return path, fileName
end

function component:SetTable(filePath, tbl)
	local path, fileName = component:HandleFilePath(filePath, self.tableExtension)

	file.CreateDir(path)

	file.Write(path .. fileName, util.TableToJSON(tbl, true))
end

function component:GetTable(filePath)
	local path, fileName = component:HandleFilePath(filePath, self.tableExtension)

	if self:TableExists(filePath) then
		return util.JSONToTable(file.Read(path .. fileName, "DATA"))
	end
end

function component:TableExists(filePath)
	local path, fileName = component:HandleFilePath(filePath, self.tableExtension)

	return file.Exists(path .. fileName, "DATA")
end

function component:TableDelete(filePath)
	local path, fileName = component:HandleFilePath(filePath, self.tableExtension)

	file.Delete(path .. fileName, "DATA")

	file.Delete(path, "DATA")
end

function component:AppendText(filePath, text)
	local path, fileName = component:HandleFilePath(filePath, self.textExtension)

	file.CreateDir(path)

	if file.Exists(path .. fileName, "DATA") then
		file.Append(path .. fileName, text)
	else
		file.Write(path .. fileName, text)
	end
end

function component:FindTables(filePath)
	local path, fileName = component:HandleFilePath(filePath, self.textExtension)

	local files, _ = file.Find(path .. "*", "DATA")

	local tbls = {}
	for _, fileName in ipairs(files) do
		fileName = string.StripExtension(fileName)
		if isnumber(tonumber(fileName)) then
			fileName = tonumber(fileName)
		end
		tbls[fileName] = self:GetTable(filePath .. fileName)
	end

	return tbls
end

galactic:Register(component)
