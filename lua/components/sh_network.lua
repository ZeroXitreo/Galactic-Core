local component = {}
component.namespace = "network"
component.title = "Network"
component.netPlayerLoaded = "PlayerLoaded"

function component:Constructor()

	function net.WriteCompressedTable(tbl)
		local binary = util.Compress(util.TableToJSON(tbl))
		net.WriteUInt(#binary, 16)
		net.WriteData(binary, #binary)
	end

	function net.ReadCompressedTable()
		return util.JSONToTable(util.Decompress(net.ReadData(net.ReadUInt(16))))
	end

	if SERVER then
		util.AddNetworkString(self.netPlayerLoaded)
		net.Receive(self.netPlayerLoaded, function(len, ply)
			hook.Run(component.netPlayerLoaded, ply)
		end)
	end

end

if CLIENT then
	function component:InitPostEntity()
		net.Start(self.netPlayerLoaded)
		net.SendToServer()
	end
end

galactic:Register(component)