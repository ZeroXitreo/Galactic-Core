local component = {}
component.dependencies = {"data"}
component.namespace = "settings"
component.title = "Settings"

component.properties = {}

function component:Constructor()
	self:LoadSettings()
end

function component:LoadSettings()
	if galactic.data:TableExists(self.namespace) then
		table.Merge(self.properties, galactic.data:GetTable(self.namespace))
	end
end

function component:SaveSettings()
	if table.IsEmpty(self.properties) then
		galactic.data:TableDelete(self.namespace)
	else
		galactic.data:SetTable(self.namespace, self.properties)
	end
end

galactic:Register(component)