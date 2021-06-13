local component = {}
component.dependencies = {"settings", "data"}
component.namespace = "theme"
component.title = "Theme"
component.blur = Material("pp/blurscreen")
component.settings = {}

function component:Constructor()
	self:Load()
end

function component:Load()
	self:LoadDefault()

	if CLIENT then
		if galactic.settings.properties.theme and galactic.data:TableExists(galactic.settings.properties.theme) then
			table.Merge(self, galactic.data:GetTable(galactic.settings.properties.theme))
		end

		self:LoadFonts()
	end
end

function component:LoadDefault()
	table.Merge(self.settings, self:GetDefault())
	
	if CLIENT then
		self:RenderTheme()
	end
end

function component:GetDefault()
	local theme = {}

	if CLIENT then
		theme.rem = 16
		theme.round = 4

		theme.colors = {}

		theme.colors.text = Color(255, 255, 255)
		theme.colors.block = Color(43, 45, 66)

		theme.colors.blue = Color(29, 190, 239)
		theme.colors.green = Color(6, 214, 160)
		theme.colors.yellow = Color(255, 209, 102)
		theme.colors.red = Color(239, 71, 111)
	else
		theme.rem = "rem"
		theme.round = "round"

		theme.colors = {}

		theme.colors.text = true
		theme.colors.block = true

		theme.colors.blue = true
		theme.colors.green = true
		theme.colors.yellow = true
		theme.colors.red = true
	end

	return theme
end

if CLIENT then

	function component:RenderTheme()
		table.Merge(self, table.Copy(self.settings))

		self.colors.textFaint = self:Blend(self.colors.text, self.colors.block, .25)
		self.colors.blockFaint = self:Blend(self.colors.block, Color(0, 0, 0), .05)
		self.colors.blueFaint = self:Blend(self.colors.blue, self.colors.block, .75)
		self.colors.greenFaint = self:Blend(self.colors.green, self.colors.block, .75)
		self.colors.yellowFaint = self:Blend(self.colors.yellow, self.colors.block, .75)
		self.colors.redFaint = self:Blend(self.colors.red, self.colors.block, .75)
	end

	function component:LoadFonts()
		surface.CreateFont("GalacticSubBold", {
			font = "Open Sans",
			size = .75 * self.rem,
			weight = 700,
			antialias = true,
		})
		surface.CreateFont("GalacticP", {
			font = "Open Sans",
			size = 1 * self.rem,
			weight = 400,
			antialias = true,
		})
		surface.CreateFont("GalacticPBold", {
			font = "Open Sans",
			size = 1 * self.rem,
			weight = 700,
			antialias = true,
		})
		surface.CreateFont("GalacticDefault", {
			font = "Open Sans",
			size = 1.25 * self.rem,
			weight = 700,
			antialias = true,
		})
		surface.CreateFont("GalacticH3", {
			font = "Open Sans",
			size = 1.5 * self.rem,
			weight = 400,
			antialias = true,
		})
		surface.CreateFont("GalacticH1", {
			font = "Open Sans",
			size = 3 * self.rem,
			weight = 700,
			antialias = true,
		})
	end

	function component:PredictNextMove(current, to, scale)
		local fps = 1 / RealFrameTime()
		scale = scale or 10

		local step = current + (to - current) / fps * scale

		return step
	end

	function component:Blend(colorOne, colorTwo, blendProcent)
		local reverseBlendProcent = 1 - blendProcent
		local r = colorOne.r * reverseBlendProcent + colorTwo.r * blendProcent
		local g = colorOne.g * reverseBlendProcent + colorTwo.g * blendProcent
		local b = colorOne.b * reverseBlendProcent + colorTwo.b * blendProcent
		local a = colorOne.a * reverseBlendProcent + colorTwo.a * blendProcent

		return Color(r, g, b, a)
	end

	function component:DrawBlurRect(x, y, w, h, effect, shade)

		surface.SetDrawColor(255,255,255)
		surface.SetMaterial(self.blur)

		for i = 1, effect or 5 do
			self.blur:SetFloat("$blur", i)
			self.blur:Recompute()

			render.UpdateScreenEffectTexture()

			surface.DrawTexturedRect(x, y, w, h)
		end
	end

	function component:DrawArch(centerX, centerY, inner, outer, degreeStart, degreeLength, resolution)
		local procentageEnd = degreeLength / math.pi / 2
		local dots = math.ceil(resolution * procentageEnd)
		local degreeSlice = degreeLength / dots
		local pi = math.pi
		degreeStart = degreeStart - pi/2

		for j = 0, dots - 1 do
			local polySlice = {}
			for k = 0, 1 do
				local calc = degreeStart + degreeSlice * (j + k)
				table.insert(polySlice, {
					x = centerX + math.cos(calc) * outer,
					y = centerY + math.sin(calc) * outer
				})
			end
			for k = -1, 0 do
				local calc = degreeStart - degreeSlice * (dots - j + k) + degreeLength
				table.insert(polySlice, {
					x = centerX + math.cos(calc) * inner,
					y = centerY + math.sin(calc) * inner
				})
			end

			surface.DrawPoly(polySlice)
		end
	end
end

galactic:Register(component)
