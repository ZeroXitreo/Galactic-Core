local component = {}
component.dependencies = {"theme"}
component.namespace = "menu"
component.title = "Menu"

component.fps = 0
component.open = false
component.smooth = 0
component.width = 0
component.spacing = 6

function component:Constructor()
	if LocalPlayer():IsValid() then
		self:InitPostEntity()
	end
end

function component:InitPostEntity()
	if galactic.menuPanel then galactic.menuPanel:Remove() end

	self.container = vgui.Create("EditablePanel")
	galactic.menuPanel = self.container
	self.container:SetSize( 640, 480 ) // Max size possible for support
	// listview:SetSize( 624, 444 ) // Tab's max values, don't exceed!
	self.container:SetSize( 260, 480 )
	self.container:SetPos( -self.container:GetWide(), ScrH() / 2 - self.container:GetTall() / 2 )
	
	self.TabContainer = self.container:Add("DPropertySheet")
	self.TabContainer:SetPos(0, 0)
	self.TabContainer:SetSize(self.container:GetSize())
	self.TabContainer.OnActiveTabChanged = function(oldPnl, newPnl)
	end
	
	self.container:MakePopup()
	self.container:SetKeyboardInputEnabled( false )
	self.container:SetMouseInputEnabled( false )

	self:Hide()

	for _, comp in ipairs(galactic.components) do
		self:ComponentInitialized(comp)
	end
end

function component:ComponentInitialized(comp)
	if comp.InitializeTab then
		if self.container then
			local pnl = self.TabContainer:Add("Panel")
			comp.Panel = pnl
			comp.Panel.Tab = comp
			pnl.component = comp
			
			comp:InitializeTab(comp.Panel)
			
			self.TabContainer:AddSheet(comp.title or "Untitled", pnl, "icon16/" .. comp.icon .. ".png", false, false, comp.description)
		end
	end
end

function component:Show()
	self.open = true
	if not self.container then component:Constructor() end
	
	self.container:SetKeyboardInputEnabled(false)
	self.container:SetMouseInputEnabled(true)
	
	local dentSpace = ScrW() - self.container:GetWide()
	local dentPush = dentSpace * 0.05

	//input.SetCursorPos( self.width/2 + dentPush, ScrH() / 2 )	
end

function component:Hide()
	if not vgui.GetKeyboardFocus() then
		self.open = false
		if not self.container then return end

		self.container:SetKeyboardInputEnabled( false )
		self.container:SetMouseInputEnabled( false )
	end
end

function component:Toggle()
	if not self.open then
		component:Show()
	else
		component:Hide()
	end
end

function component:StartKeyFocus()
	self.container:SetKeyboardInputEnabled(true)
end

function component:EndKeyFocus()
	self.container:SetKeyboardInputEnabled(false)
end

function component:Think()
	self.fps = 1 / RealFrameTime()
	if (self.container) then

		// Menu width/Wide
		local activeComponent = self.TabContainer:GetActiveTab():GetPanel().component
		if ( activeComponent ) then
			self.width = galactic.theme:PredictNextMove(self.width, activeComponent.width + 16)

			self.container:SetWide( math.Round(self.width) )
			self.TabContainer:SetWide( math.Round(self.width) )
		end

		// Menu position
		self.smooth = galactic.theme:PredictNextMove(self.smooth, self.open and 1 or 0)
		self.container:SetPos(ScrW()/2 - self.container:GetWide()/2, ScrH() - math.Round(self.smooth*(self.container:GetTall()+ScrH())/2))

		local dentSpace = ScrW() - self.container:GetWide()
		local dentPush = dentSpace*0.05

		self.container:SetPos( math.Round(self.smooth*( self.container:GetWide() + dentPush*2 )) - (self.container:GetWide() + dentPush), ScrH()/2 - self.container:GetTall()/2 )




		local x, y, width, height = self.container:GetBounds()
		self.container:SetVisible(x + width > 0)
	end
end

concommand.Add("+ga_menu", function()
	component:Show()
end)
concommand.Add( "-ga_menu", function()
	component:Hide()
end)
concommand.Add( "ga_menu", function()
	component:Toggle()
end)

list.Set("DesktopWindows", "MenuAccess", 
{
	title		= "Galactic menu",
	icon		= "gmod/save.png",
	init		= function(icon, window)
		RunConsoleCommand("ga_menu");
	end
})

galactic:Register(component)
