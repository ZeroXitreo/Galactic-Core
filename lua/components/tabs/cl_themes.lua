local PANEL = {}

function PANEL:Init()
	self:SetMultiSelect(false)
	self:SetHideHeaders(true)
	self:AddColumn("")
	self:SetDataHeight(24)
	self:SetHeaderHeight(0)
	self:DisableScrollbar(true)
end

function PANEL:AddLine(title)

	// Default
	self:SetDirty(true)
	self:InvalidateLayout()

	local line = vgui.Create( "DListView_Line", self.pnlCanvas )
	local ID = table.insert( self.Lines, line )

	line:SetListView( self )
	line:SetID( ID )

	-- Make appear at the bottom of the sorted list
	local SortID = table.insert( self.Sorted, line )

	if ( SortID % 2 == 1 ) then
		line:SetAltLine( true )
	end

	// Custom

	local imageSize = 16
	local dataHeight = self:GetDataHeight()
	local imagePadding = (dataHeight - imageSize)

	/*line.icon = line:Add("DImage")
	line.icon:SetImage(imagePath)
	line.icon:SetSize(imageSize, imageSize)
	line.icon:SetPos(imagePadding, imagePadding)*/

	line.label = line:Add("DLabel")
	line.label:SetText(title)
	line.label:SetTextColor(Color(0, 0, 0))
	line.label:Dock(FILL)
	line.label:DockMargin(imagePadding, 0, imagePadding, 0)

	return line
end

vgui.Register("DListViewSingle", PANEL, "DListView")

















local component = {}
component.dependencies = {"menu", "data", "settings", "theme", "io"}
component.title = "Themes"

component.description = "Allows to customize the theme of the built-in theme"
component.icon = "paintcan"
component.width = 512

local path = "themes/"
local colourPalleteHeight = 140
local isValueChangedFired = true
component.palette = {"block", "text"}

function component:InitializeTab(parent)
	component.currentPaletteColor = nil

	for k, v in pairs(galactic.theme.settings.colors) do
		if not table.HasValue(self.palette, k) then
			table.insert(self.palette, k)
		end
	end

	self.container = vgui.Create("DPanel", parent)
	self.container:Dock(FILL)
	self.container.Paint = nil

	self.container.menu = vgui.Create("DPanel", self.container)
	self.container.menu:Dock(LEFT)
	self.container.menu:DockMargin(0, 0, 6, 0)
	self.container.menu:SetWide(200)
	self.container.menu.Paint = nil

	self.container.menu.themes = vgui.Create("DListViewSingle", self.container.menu)
	self.container.menu.themes:Dock(FILL)

	self:InitAllThemes()

	self.container.menu.themes.OnRowSelected = function(lst, index, pnl) self:OnThemeSelected(index, pnl) end

	self.container.menu.deleteTheme = self:CreateMenuButton("Delete")
	self.container.menu.deleteTheme.DoClick = function() self:OnDeleteTheme() end

	self.container.menu.saveAs = self:CreateMenuButton("Save as..")
	self.container.menu.saveAs.DoClick = function() self:OnSaveAs() end

	self.container.menu.save = self:CreateMenuButton("Save")
	self.container.menu.save.DoClick = function() self:OnSave() end

	self.container.menu.reset = self:CreateMenuButton("Reset")
	self.container.menu.reset.DoClick = function() self:OnReset() end

	self.container.menu.setTheme = self:CreateMenuButton("Set theme")
	self.container.menu.setTheme.DoClick = function() self:OnThemeSetDefault() end

	self.container.editorPanel = self.container:Add("DPanel")
	self.container.editorPanel:Dock(FILL)
	self.container.editorPanel:DockMargin(0, 0, 8, 0)

	self.container.palette = self.container.editorPanel:Add("DPanel")
	self.container.palette:Dock(TOP)
	self.container.palette:DockMargin(0, 0, 0, 6)
	self.container.palette.Paint = function(pnl, w, h)
		pnl:SetHeight(pnl:GetWide() / #self.palette)
	end

	for k, v in pairs(self.palette) do
		self.container.palette[k] = self.container.palette:Add("DPanel")
		self.container.palette[k]:Dock(LEFT)
		self.container.palette[k]:DockPadding(2, 2, 2, 2)
		self.container.palette[k].Paint = function(pnl, w, h)
			pnl:SetWidth(self.container.palette:GetWide() / #self.palette)
			if self.currentPaletteColor == v then
				surface.SetDrawColor(galactic.theme.colors[v .. "Faint"])
				surface.DrawRect(0, 0, w, h)
			end
		end

		self.container.palette[k].color = self.container.palette[k]:Add("DButton")
		self.container.palette[k].color:Dock(FILL)
		self.container.palette[k].color:SetText("")
		self.container.palette[k].color.DoClick = function(pnl)
			self.currentPaletteColor = v
			self.container.colouring:SetEnabled(true)
			self.container.colouring:SetColor(galactic.theme.colors[self.currentPaletteColor])
		end
		self.container.palette[k].color.Paint = function(pnl, w, h)
	    	surface.SetDrawColor(galactic.theme.colors[v])
			surface.DrawRect(0, 0, w, h / 4 * 3)
	    	surface.SetDrawColor(galactic.theme.colors[v .. "Faint"])
			surface.DrawRect(0, h / 4 * 3, w, h / 4)
		end
	end

	self.container.colouring = self.container.editorPanel:Add("DColorMixer")
	self.container.colouring:Dock(TOP)
	self.container.colouring:DockMargin(0, 0, 0, 6)
	self.container.colouring:SetPalette(true)
	self.container.colouring:SetTall(200)
	self.container.colouring:SetAlphaBar(false)
	self.container.colouring:SetEnabled(false)
	self.container.colouring.ValueChanged = function(pnl, value)
		if isValueChangedFired then
			self:ButtonUpdate()
			galactic.theme.settings.colors[self.currentPaletteColor] = value
			galactic.theme:RenderTheme()
		end
	end

	self.container.editor = self.container.editorPanel:Add("DPanel")
	self.container.editor:Dock(FILL)
	self.container.editor.Paint = nil

	self.container.editor.categoryList = vgui.Create("DCategoryList", self.container.editor)
	self.container.editor.categoryList:Dock(FILL)

	self.container.editor.inputs = {}

	self.container.editor.inputs.round = self:CreateNumberSlider("Border radius", "Border radius", 0, 8)
	self.container.editor.inputs.round.OnValueChanged = function(pnl, value) self:EditorValueChanged(pnl, math.Round(value)) end

	self:SetSelected()

	self:ButtonInit()

end

function component:InitAllThemes()

	self.container.menu.themes.default = self:AddTheme("Default")

	local themes = galactic.data:FindTables(path)
	for name, theme in pairs(themes) do
		self:AddTheme(name, theme)
	end
	
end

function component:CreateMenuButton(txt)
	local button = vgui.Create("DButton", self.container.menu)
	button:Dock(BOTTOM)
	button:SetTall(24)
	button:DockMargin(0, 6, 0, 0)
	button:SetText(txt)
	return button
end

function component:AddTheme(name, theme)

	local line = self.container.menu.themes:AddLine(name)

	if theme then
		line.theme = theme
		line.name = name
	end

	theme = theme or galactic.theme:GetDefault()

	self:UpdateThemePalette(line, theme)

	return line
end

function component:UpdateThemePalette(line, theme)
	if not line.paletteColors then
		line.paletteColors = {}
		for k,v in pairs(self.palette) do
			line.paletteColors[k] = line:Add("DPanel")
			line.paletteColors[k]:Dock(RIGHT)
			line.paletteColors[k]:DockMargin(0, 6, 6, 6)
			line.paletteColors[k]:SetWide(4)
			line.paletteColors[k]:SetMouseInputEnabled(false)
		end
	end
	for k,v in pairs(self.palette) do
		line.paletteColors[k]:SetBackgroundColor(theme.colors[v])
	end
end

function component:OnThemeSelected(index, pnl)

	local theme = pnl.theme or galactic.theme:GetDefault()

	table.Merge(galactic.theme.settings, table.Copy(theme))

	self:ButtonInit()

	self:CurrentThemeChanged()
end

function component:SetSelected()
	local line = self:GetSelectedThemeLine()
	self.container.menu.themes:SelectItem(line)
end

function component:OnDeleteTheme()
	index, linePanel = self.container.menu.themes:GetSelectedLine()

	galactic.data:TableDelete(path .. linePanel.name)

	self.container.menu.themes:RemoveLine(index)

	if not component:GetSelectedThemeLine() then
		galactic.settings.properties.theme = nil
		galactic.settings:SaveSettings()
	end

	self:SetSelected()

	self:ButtonInit()
end

function component:GetSelectedThemeLine()
	if not galactic.settings.properties.theme then
		return self.container.menu.themes.default
	end

	local lines = self.container.menu.themes:GetLines()
	local name = string.StripExtension(string.GetFileFromFilename(galactic.settings.properties.theme))
	for _, line in ipairs(lines) do
		if line.name == name then
			return line
		end
	end
end

function component:ButtonInit()
	local _, selectedLine = self.container.menu.themes:GetSelectedLine()
	if selectedLine then
		local theme = selectedLine.theme

		self.container.menu.setTheme:SetEnabled(self:GetSelectedThemeLine() != selectedLine);

		if theme then
			self.container.menu.deleteTheme:SetEnabled(true);
		else
			self.container.menu.deleteTheme:SetEnabled(false);
		end
		self.container.menu.save:SetEnabled(false);
		self.container.menu.reset:SetEnabled(false);
	else
		
	end
end

function component:ButtonUpdate()
	local _, selectedLine = self.container.menu.themes:GetSelectedLine()
	local theme = selectedLine.theme

	self.container.menu.reset:SetEnabled(true);
	if theme then
		self.container.menu.save:SetEnabled(true);
	end
end

function component:OnSaveAs()
	galactic.io:String("Save as...", "Only use normal characters, uppercase will be ignored", function(result)
		if result:Trim() == "" then
			self:OnSaveAs()
		else
			self:OnCompleteSaveAs(result)
		end
	end, _, "Filename", _)
end

function component:OnCompleteSaveAs(str)
	str = string.lower(str)
	galactic.data:SetTable(path .. str, galactic.theme.settings)
	local line = self:AddTheme(str, galactic.data:GetTable(path .. str))
	self.container.menu.themes:ClearSelection()
	self.container.menu.themes:SelectItem(line)
end

function component:OnSave()
	local lineIndex, linePanel = self.container.menu.themes:GetSelectedLine()
	galactic.data:SetTable(path .. linePanel.name, galactic.theme.settings)
	linePanel.theme = table.Copy(galactic.theme)

	self:UpdateThemePalette(linePanel, linePanel.theme)
	self:ButtonInit()
end

function component:OnReset()
	local _, line = self.container.menu.themes:GetSelectedLine()
	PrintTable(table.Copy(line.theme or galactic.theme:GetDefault()))
	table.Merge(galactic.theme.settings, table.Copy(line.theme or galactic.theme:GetDefault()))

	self:CurrentThemeChanged()

	self:ButtonInit()
end

function component:OnThemeSetDefault()
	local _, line = self.container.menu.themes:GetSelectedLine()

	if line.theme and line.name then
		galactic.settings.properties.theme = path .. line.name
	else
		galactic.settings.properties.theme = nil
	end
	galactic.settings:SaveSettings()
	self:ButtonInit()
end

function component:EditorValueChanged(pnl, value)
	if isValueChangedFired then
		self:ButtonUpdate()
		galactic.theme.colors[table.KeyFromValue(self.container.editor.inputs, pnl)] = value
	end
end

function component:CurrentThemeChanged()
	isValueChangedFired = false
	galactic.theme:RenderTheme()
	for key, value in pairs(self.container.editor.inputs) do
		if value.SetColor then
			value:SetColor(galactic.theme[key])
		else
			value:SetValue(galactic.theme[key])
		end
	end
	if IsValid(self.container.colouring) and self.currentPaletteColor then
		self.container.colouring:SetColor(galactic.theme.colors[self.currentPaletteColor])
	end
	isValueChangedFired = true
end

function component:CreateCategoryPanel(name)
	local panel = vgui.Create("DPanel", self.container.editor.categoryList);
	panel.Paint = nil;
	panel:Dock(FILL);
	panel:DockPadding(10, 10, 10, 10);

	return panel;
end

function component:CreateColorInput(name)
	local panel = self:CreateCategoryPanel(name);

	local colorMixer = vgui.Create("DColorMixer", panel);
	colorMixer:Dock(TOP)
	colorMixer:SetPalette(true)
	colorMixer:SetTall(colourPalleteHeight)
	colorMixer:SetAlphaBar(false)

	local category = self.container.editor.categoryList:Add(name);
	category:SetContents(panel);

	return colorMixer;
end

function component:CreateNumberSlider(name, description, min, max)
	local panel = self:CreateCategoryPanel(name);

	local numSlider = vgui.Create("DNumSlider", panel);
	numSlider:Dock(TOP);
	numSlider:SetText(description);
	numSlider:SetTall(20);
	numSlider:SetMin(min);
	numSlider:SetMax(max);
	numSlider:SetDecimals(0);
	numSlider:SetDark(true);

	local category = self.container.editor.categoryList:Add(name);
	category:SetContents(panel);

	return numSlider;
end

galactic:Register(component)
