 local component = {}
component.dependencies = {"theme"}
component.namespace = "anchor"
component.title = "Anchor"
component.debug = false

component.drawings = {}

component.drawings.tl = {}
component.drawings.tl.modifyX = 1
component.drawings.tl.modifyY = 1
component.drawings.tl.init = nil
component.drawings.tl.preDraws = {}
component.drawings.tl.draws = {}

component.drawings.tr = {}
component.drawings.tr.modifyX = -1
component.drawings.tr.modifyY = 1
component.drawings.tr.init = nil
component.drawings.tr.preDraws = {}
component.drawings.tr.draws = {}

component.drawings.bl = {}
component.drawings.bl.modifyX = 1
component.drawings.bl.modifyY = -1
component.drawings.bl.defaultAnchor = {}
component.drawings.bl.defaultAnchor.x = 590
component.drawings.bl.defaultAnchor.y = 140
component.drawings.bl.init = nil
component.drawings.bl.preDraws = {}
component.drawings.bl.draws = {}

component.drawings.br = {}
component.drawings.br.modifyX = -1
component.drawings.br.modifyY = -1
component.drawings.br.defaultAnchor = {}
component.drawings.br.defaultAnchor.x = 530
component.drawings.br.defaultAnchor.y = 140
component.drawings.br.init = nil
component.drawings.br.preDraws = {}
component.drawings.br.draws = {}

function component:IsValid()
    return true
end

function component:HUDPaint()
	for _, tbl in pairs(component.drawings) do
		self:DoDraw(tbl)
	end
end

function component:DoDraw(tbl)
	modifyX = tbl.modifyX
	modifyY = tbl.modifyY
	anchorX = ScrW() / 2 - ScrW() / 2 * modifyX
	anchorY = ScrH() / 2 - ScrH() / 2 * modifyY
	self:DrawDebug(anchorX, anchorY)

	if tbl.init then
		draw.NoTexture()
		anchorXReturn, anchorYReturn = tbl.init[2](tbl.init[1], anchorX, anchorY)
		anchorX = anchorX + anchorXReturn * modifyX
		anchorY = anchorY + anchorYReturn * modifyY
		self:DrawDebug(anchorX, anchorY)
	elseif tbl.defaultAnchor then
		anchorX = anchorX + tbl.defaultAnchor.x * modifyX
		anchorY = anchorY + tbl.defaultAnchor.y * modifyY
		self:DrawDebug(anchorX, anchorY)
	end

	for _, drawing in pairs(tbl.preDraws) do
		draw.NoTexture()
		drawing[2](drawing[1], anchorX, anchorY)
	end

	for _, drawing in pairs(tbl.draws) do
		draw.NoTexture()
		anchorXReturn, anchorYReturn = drawing[2](drawing[1], anchorX, anchorY)
		anchorX = anchorX + anchorXReturn * modifyX
		anchorY = anchorY + anchorYReturn * modifyY
		self:DrawDebug(anchorX, anchorY)
	end
end

function component:DrawDebug(anchorX, anchorY)
	if not self.debug then
		return
	end
	local lineSize = 100
	surface.SetDrawColor(255, 0, 0)
	surface.DrawLine(anchorX - lineSize / 2, anchorY, anchorX + lineSize / 2, anchorY)
	surface.DrawLine(anchorX, anchorY - lineSize / 2, anchorX, anchorY + lineSize / 2)
end

function component:GetTable(top, left)
	if top then
		if left then
			return self.drawings.tl
		else
			return self.drawings.tr
		end
	else
		if left then
			return self.drawings.bl
		else
			return self.drawings.br
		end
	end
end

function component:RegisterAnchor(drawing, func, top, left)
	self:GetTable(top, left).init = {drawing, func}
end

function component:RegisterPostAnchor(drawing, func, top, left)
	table.insert(self:GetTable(top, left).preDraws, {drawing, func})
end

function component:RegisterDrawing(drawing, func, top, left)
	table.insert(self:GetTable(top, left).draws, {drawing, func})
end

galactic:Register(component)