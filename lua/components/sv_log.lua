local component = {}
component.dependencies = {"data"}
component.namespace = "log"
component.title = "Log system"
component.path = "logs/"
component.prefix = "LOGS > "

function component:Log(str)
	str = string.format("[%s] %s", os.date("%T"), str)
	galactic.data:AppendText(self.path .. os.date("%F"), str .. "\n")
	hook.Run("OnLogging", component.prefix .. str)
end

function component:OnLogging(str)
	print(str)
end

function component:PlayerLogStr(ply)
	if ply:IsValid() then
		if ply:IsPlayer() then
			return "[" .. ply:SteamID() .. "|" .. ply:Nick() .. "]"
		else
			return "[" .. ply:GetClass() .. "]"
		end
	else
		return "[Console]"
	end
end

galactic:Register(component)
