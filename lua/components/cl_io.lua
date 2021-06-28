local component = {}
component.dependencies = {"theme"}
component.namespace = "io"
component.title = "IO"

function component:Constructor()

	/////////////////////////////////////////////////

	local PANEL = {}
	function PANEL:Init()
		self:SetFont("GalacticDefault")
		self:SetColor(galactic.theme.colors.text)
		self:SetBackgroundColor(galactic.theme.colors.blue)
		self:SetHeight(galactic.theme.rem * 2)
	end
	function PANEL:SetBackgroundColor(col)
		self.bgColor = col
	end
	function PANEL:GetBackgroundColor(col)
		return self.bgColor
	end
	function PANEL:Paint(w, h)
		local bgcolor = self:GetBackgroundColor()
		local fgcolor = self:GetColor()
		local alpha = 255

		if self:IsEnabled() then
			if self:IsHovered() and not self:IsDown() then
				bgcolor = galactic.theme:Blend(bgcolor, galactic.theme.colors.text, .1)
			end
		else
			alpha = 55
		end

		draw.RoundedBox(galactic.theme.round, 0, 0, w, h, ColorAlpha(bgcolor, alpha))
		self:SetColor(ColorAlpha(fgcolor, alpha))
	end
	vgui.Register("GaButton", PANEL, "DButton")

	/////////////////////////////////////////////////

	local PANEL = {}
	function PANEL:Init()
		self.AddSheetSuper = self.AddSheet
		self.AddSheet = function(name, pnl, icon, noStretchX, noStretchY, tooltip)
			local tbl = self.AddSheetSuper(name, pnl, icon, noStretchX, noStretchY, tooltip)
			local tab = tbl["Tab"]
			tab:SetTextColor(galactic.theme.colors.block)
			tab.Paint = function(this, x, y)
				local txtCol = galactic.theme.colors.textFaint
				local bgCol = galactic.theme.colors.block
				if tab:IsActive() then
					txtCol = galactic.theme.colors.text
				else
					bgCol = galactic.theme:Blend(galactic.theme.colors.blockFaint, galactic.theme.colors.textFaint, .2)
				end
				draw.RoundedBoxEx(galactic.theme.round, 0, 0, x, y, bgCol, true, true, false, false)
				tab:SetTextColor(txtCol)
			end
			return tbl
		end

	end
	function PANEL:Paint(x, y)
		local topPush = 20
		draw.RoundedBox(galactic.theme.round, 0, topPush, x, y - topPush, galactic.theme.colors.block)
	end
	/*self.TabContainer.AddSheetSuper = self.TabContainer.AddSheet
	self.TabContainer.AddSheet = function(name, pnl, icon, noStretchX, noStretchY, tooltip)
		local tbl = self.TabContainer.AddSheetSuper(name, pnl, icon, noStretchX, noStretchY, tooltip)
		local tab = tbl["Tab"]
		tab:SetTextColor(galactic.theme.colors.block)
		tab.Paint = function(this, x, y)
			local txtCol = galactic.theme.colors.textFaint
			local bgCol = galactic.theme.colors.block
			if tab:IsActive() then
				txtCol = galactic.theme.colors.text
			else
				bgCol = galactic.theme:Blend(galactic.theme.colors.blockFaint, galactic.theme.colors.textFaint, .2)
			end
			draw.RoundedBoxEx(galactic.theme.round, 0, 0, x, y, bgCol, true, true, false, false)
			tab:SetTextColor(txtCol)
		end
		return tbl
	end*/
	vgui.Register("GaPropertySheet", PANEL, "DPropertySheet")

	/////////////////////////////////////////////////

	local PANEL = {}
	function PANEL:Init()
		self:SetAllowNonAsciiCharacters(true)
		self:SetFont("GalacticDefault")
		self:SetHeight(galactic.theme.rem * 3)
	end
	function PANEL:Paint(w, h)
		draw.RoundedBox(galactic.theme.round, 0, 0, w, h, galactic.theme.colors.block)
		self:DrawTextEntryText(galactic.theme.colors.text, galactic.theme.colors.textFaint, galactic.theme.colors.text)
		if self:GetValue() == "" then
			draw.SimpleText(self:GetPlaceholderText(), self:GetFont(), 3, self:GetTall() / 2, galactic.theme.colors.textFaint, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
		end
	end
	vgui.Register("GaTextEntry", PANEL, "DTextEntry")

	/*self.container.field.entry:SetPlaceholderText("")*/

	/////////////////////////////////////////////////

	local PANEL = {}
	function PANEL:Init()
		self:SetMultiSelect(false)
		self:SetDataHeight(galactic.theme.rem * 1.5)
		self:AddColumn("")
		self:SetHideHeaders(true)
	end
	function PANEL:AddLine(title, imagePath)

		// Default
		self:SetDirty(true)
		self:InvalidateLayout()

		local line = vgui.Create("DListView_Line", self.pnlCanvas)
		local ID = table.insert(self.Lines, line)

		line:SetListView(self)
		line:SetID(ID)

		-- Make appear at the bottom of the sorted list
		local SortID = table.insert( self.Sorted, line )

		if SortID % 2 == 1 then
			line:SetAltLine(true)
		end

		// Custom

		local dataHeight = self:GetDataHeight()
		local imageSize = dataHeight / 1.5
		local imagePadding = (dataHeight - imageSize) / 2

		if imagePath then

			if IsEntity(imagePath) and imagePath:IsPlayer() then
				line.icon = line:Add("AvatarImage")
				line.icon:SetPlayer(imagePath, imageSize)
			else
				line.icon = line:Add("DImage")
				line.icon:SetImage(imagePath)
			end
			line.icon:SetSize(imageSize, imageSize)
			line.icon:SetPos(imagePadding, imagePadding)
			//line.icon:Dock(LEFT)
			//line.icon:DockMargin(imagePadding, imagePadding, 0, imagePadding)
		end

		line.label = line:Add("DLabel")
		line.label:SetText(title)
		line.label:SetTextColor(Color(0, 0, 0))
		line.label:Dock(FILL)
		line.label:DockMargin(dataHeight, 0, imagePadding, 0)

		return line
	end
	vgui.Register("GalacticItemListView", PANEL, "DListView")

	/////////////////////////////////////////////////

	/*if LocalPlayer():IsValid() then
		self:Boolean("Boolean", "Description", function(result)
			print(result)
		end)
		self:String("String", "Description", function(result)
			print(result)
		end, "Okay", "Placeholder", "Inserted value")
	end*/
end

function component:String(title, message, func, ok, placeholder, value)

	local popup = self:CreateFrame(title, function(pnl)
		func(pnl.content.entry:GetValue())
	end, ok)

	if message then
		local msg = self:AddMessageToContent(popup, message)
		msg:DockMargin(0, 0, 0, galactic.theme.rem)
	end

	popup.content.entry = popup.content:Add("GaTextEntry")
	popup.content.entry:Dock(TOP)
	popup.content.entry:SetValue(value or "")
	popup.content.entry:SetFontInternal("GalacticDefault")
	popup.content.entry:SelectAllOnFocus()
	popup.content.entry:RequestFocus()
	popup.content.entry:SetPlaceholderText(placeholder or "")
	popup.content.entry.OnEnter = function()
		popup:Remove()
		func(popup.content.entry:GetValue())
	end

	self:ResizePanel(popup.content)
	self:ResizePanel(popup)
end

function component:Boolean(title, message, func, ok, cancel)

	local popup = self:CreateFrame(title, function(pnl)
		func(true)
	end, ok)

	if message then
		self:AddMessageToContent(popup, message)
	end

	popup.promt.cancel = popup.promt:Add("GaButton")
	popup.promt.cancel:SetBackgroundColor(galactic.theme.colors.red)
	popup.promt.cancel:Dock(RIGHT)
	popup.promt.cancel:SetText(cancel or "No")
	surface.SetFont(popup.promt.cancel:GetFont())
	popup.promt.cancel:SetWide(surface.GetTextSize(popup.promt.cancel:GetText()) + galactic.theme.rem * 2)
	popup.promt.cancel:DockMargin(galactic.theme.rem, 0, 0, 0)
	popup.promt.cancel.DoClick = function()
		if popup.promt.cancel:GetValue():Trim() != "" then
			popup:Remove()
			func(false)
		end
	end

	self:ResizePanel(popup.content)
	self:ResizePanel(popup)
end

function component:ResizePanel(pnl)
	pnl:InvalidateLayout(true)
	pnl:Center()
	local children = pnl:GetChildren()
	local child = children[table.Count(children)]
	local _, childPosY = child:GetPos()
	local childHeight = child:GetTall()

	pnl:SetHeight(childPosY + childHeight)
	pnl:Center()
end

function component:AddMessageToContent(popup, context)
	message = popup.content:Add("RichText")
	message:Dock(TOP)
	message:SetFontInternal("GalacticDefault")
	message:InsertColorChange(galactic.theme.colors.text.r, galactic.theme.colors.text.g, galactic.theme.colors.text.b, galactic.theme.colors.text.a)
	message:AppendText(context)
	message:SetVerticalScrollbarEnabled(false)
	message.Paint = function(pnl, w, h)
		pnl:DrawTextEntryText(galactic.theme.colors.text, galactic.theme.colors.textFaint, galactic.theme.colors.text);
		pnl:SetFontInternal("GalacticDefault")
	end
	message:SetHeight(galactic.theme.rem * 1.5 * 3)
	return message
end

function component:CreatePopup(title)
	local frame = vgui.Create("Panel")
	frame:SetHeight(ScrH())
	frame:SetWidth(ScrW())
	frame.Paint = function(pnl, w, h)
		galactic.theme:DrawBlurRect(0, 0, ScrW(), ScrH(), 5)
		surface.SetDrawColor(galactic.theme.colors.blockFaint.r, galactic.theme.colors.blockFaint.g, galactic.theme.colors.blockFaint.b, 50)
		surface.DrawRect(0, 0, w, h)
	end

	popup = frame:Add("EditablePanel")
	popup:SetWide(galactic.theme.rem * 24)
	popup:SetTall(galactic.theme.rem * 12*1.5)
	popup:Center()
	popup:MakePopup()
	popup:DockPadding(0, 0, 0, 0)
	popup.OnRemove = function(this)
		this:GetParent():Remove()
	end
	popup.Paint = function(this, w, h)
		draw.RoundedBox(galactic.theme.round, 0, 0, w, h, galactic.theme.colors.blockFaint)
	end

	popup.title = popup:Add("DLabel")
	popup.title:Dock(TOP)
	popup.title:SetText(title)
	popup.title:DockMargin(galactic.theme.rem, galactic.theme.rem, galactic.theme.rem, 0)
	popup.title:SetColor(galactic.theme.colors.text)
	popup.title:SetFont("GalacticH3")

	return popup
end

function component:CreateFrame(title, func, ok)
	local popup = self:CreatePopup(title)

	popup.content = popup:Add("Panel")
	popup.content:Dock(TOP)
	popup.content:DockMargin(galactic.theme.rem, galactic.theme.rem, galactic.theme.rem, galactic.theme.rem)

	popup.promt = popup:Add("Panel")
	popup.promt:Dock(TOP)
	popup.promt:SetHeight(galactic.theme.rem * 4)
	popup.promt:DockPadding(galactic.theme.rem, galactic.theme.rem, galactic.theme.rem, galactic.theme.rem)
	popup.promt.Paint = function(pnl, w, h)
		draw.RoundedBoxEx(galactic.theme.round, 0, 0, w, h, galactic.theme.colors.block, false, false, true, true)
	end

	popup.promt.close = popup.promt:Add("GaButton")
	popup.promt.close:Dock(LEFT)
	popup.promt.close:SetFont("GalacticDefault")
	popup.promt.close:SetColor(galactic.theme.colors.text)
	popup.promt.close:SetText("Cancel")
	surface.SetFont(popup.promt.close:GetFont())
	popup.promt.close:SetWide(surface.GetTextSize(popup.promt.close:GetText()) + galactic.theme.rem)
	popup.promt.close.Paint = function(pnl, w, h)
		local alpha = 50

		if pnl:IsHovered() and not pnl:IsDown() then
			alpha = 255
		end

		local col = ColorAlpha(galactic.theme.colors.text, alpha)
		pnl:SetColor(col)
	end
	popup.promt.close.DoClick = function()
		if popup.promt.close:GetValue():Trim() != "" then
			popup:Remove()
		end
	end

	popup.promt.ok = popup.promt:Add("GaButton")
	popup.promt.ok:Dock(RIGHT)
	popup.promt.ok:SetText(ok or "Yes")
	surface.SetFont(popup.promt.ok:GetFont())
	popup.promt.ok:SetWide(surface.GetTextSize(popup.promt.ok:GetText()) + galactic.theme.rem * 2)
	popup.promt.ok:DockMargin(galactic.theme.rem, 0, 0, 0)
	popup.promt.ok.DoClick = function()
		if popup.promt.ok:GetValue():Trim() != "" then
			popup:Remove()
			func(popup)
		end
	end

	return popup
end

galactic:Register(component)
