local Creator = {}

function Creator:Init()
	self:SetSize(450, 455)
end

function Creator:OnFinished(emblem)

end

function Creator:IsCanvasClean()
	local bool = true
	
	for k,v in pairs(self.EmblemDisplay.Layers) do
		if v.ID then
			bool = false
			
			print("Dirty")
			
			return
		end
	end
	
	return bool
end

function Creator:LoadData(tbl)
	self.EmblemDisplay = vgui.Create("Emblem", self)
	self.EmblemDisplay:SetPos(self:GetWide() - self.EmblemDisplay:GetWide() - 5, 5)
	local x, y = self:GetPos()
	local nX, nY = self.EmblemDisplay:GetPos()
	self.EmblemDisplay:SetRelativePos(x + nX, y + nY)
	
	//self.CancelButton = vgui.Create("cButton", self)
	
	self.ConfirmButton = vgui.Create("cButton", self)
	self.ConfirmButton:SetSize(self:GetWide()-5, 30)
	self.ConfirmButton:SetPos(2.5, self:GetTall() - self.ConfirmButton:GetTall() - 2.5)
	self.ConfirmButton.DoClick = function() self:OnFinished(self.EmblemDisplay) end
	self.ConfirmButton:SText("Finish & Save")

	if tbl != false then
		self.EmblemDisplay:SetData(tbl)
	end
	
	self.ColorPicker = vgui.Create("DColorMixer", self)
	local x,y = self.EmblemDisplay:GetPos()
	self.ColorPicker:SetPos(x, self.EmblemDisplay:GetTall() + 55)
	self.ColorPicker:SetSize(self.EmblemDisplay:GetWide(), self.EmblemDisplay:GetTall() - 35)
	self.ColorPicker:SetAlphaBar(false)
	self.ColorPicker:SetWangs(false)
	self.ColorPicker.ValueChanged = function()
		local act = self.EmblemDisplay:GetActiveLayer()
		if act then
			self.EmblemDisplay:SetLayerColor(act, self.ColorPicker:GetColor())
		end
	end
	
	self.LayerList = vgui.Create("DPanelList", self)
	self.LayerList:SetSize(self:GetWide() - self.EmblemDisplay:GetWide() - 15	, self.EmblemDisplay:GetTall())
	self.LayerList:SetPos(5, 5)
	self.LayerList:EnableVerticalScrollbar(true)
	self.LayerList:SetSpacing(-1)
	
	self.RotateCounter = vgui.Create("DButton", self)
	self.RotateCounter:SetPos(x, y + self.EmblemDisplay:GetTall() + 1.5)
	self.RotateCounter:SetSize(48, 48)
	self.RotateCounter:SetText("")
	self.RotateCounter.OnMousePressed = function(s)
		s.IsPressed = CurTime() - 0.1
	end
	
	self.RotateCounter.OnMouseReleased = function(s)
		s.IsPressed = false
	end
	
	self.RotateCounter.Think = function(s)
		if !s.IsPressed then return end
		if s.IsPressed <= CurTime() then
		local act = self.EmblemDisplay:GetActiveLayer()
			if act then
				local curRot = self.EmblemDisplay.Layers[act].Rot
				if curRot - 1 >= -180 then
					self.EmblemDisplay.Layers[act].Rot = self.EmblemDisplay.Layers[act].Rot - 1
				end
			end
			s.IsPressed = CurTime() + 0.01
		end
	end
	
	local countermat = Material("EDITOR/counterclock.png")
	self.RotateCounter.Paint = function(s)
		draw.RoundedBoxEx(1,0,0, s:GetWide(), s:GetTall(), Color(155, 155, 155, 255))
	
		surface.SetDrawColor(color_white)
		surface.SetMaterial(countermat)
		surface.DrawTexturedRect(10, 10, s:GetWide() - 20, s:GetTall() - 20 )
	
		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(0,0,s:GetWide(), s:GetTall())
	end

	self.RotateClock = vgui.Create("DButton", self)
	self.RotateClock:SetPos(x + self.RotateCounter:GetWide() + 2, y + self.EmblemDisplay:GetTall() + 1.5)
	self.RotateClock:SetSize(self.RotateCounter:GetSize())
	self.RotateClock:SetText("")
	self.RotateClock.OnMousePressed = function(s)
		s.IsPressed = CurTime() - 0.1
	end
	
	self.RotateClock.OnMouseReleased = function(s)
		s.IsPressed = false
	end
	
	local clockmat = Material("EDITOR/clockwise.png")
	self.RotateClock.Paint = function(s)
		draw.RoundedBoxEx(1,0,0, s:GetWide(), s:GetTall(), Color(155, 155, 155, 255))
	
		surface.SetDrawColor(color_white)
		surface.SetMaterial(clockmat)
		surface.DrawTexturedRect(10, 10, s:GetWide() - 20, s:GetTall() - 20)
	
		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(0,0,s:GetWide(), s:GetTall())
	end
	
	self.RotateClock.Think = function(s)
		if !s.IsPressed then return end
		if s.IsPressed <= CurTime() then
			local act = self.EmblemDisplay:GetActiveLayer()
			if act then
				local curRot = self.EmblemDisplay.Layers[act].Rot
				if curRot + 1 <= 180 then
					self.EmblemDisplay.Layers[act].Rot = self.EmblemDisplay.Layers[act].Rot + 1
				end
			end
			s.IsPressed = CurTime() + 0.01
		end
	end
	
	self.IncreaseSize = vgui.Create("DButton", self)
	self.IncreaseSize:SetPos(x + (6 + self.RotateCounter:GetWide() * 2), y + self.EmblemDisplay:GetTall() + 1.5)
	self.IncreaseSize:SetSize(self.RotateCounter:GetSize())
	self.IncreaseSize:SetText("")
	self.IncreaseSize.OnMousePressed = function(s)
		s.IsPressed = CurTime() - 0.1
	end
	
	self.IncreaseSize.OnMouseReleased = function(s)
		s.IsPressed = false
	end
	
	self.IncreaseSize.Think = function(s)
		if !s.IsPressed then return end
		if s.IsPressed <= CurTime() then
			local act = self.EmblemDisplay:GetActiveLayer()
			if act then
				local curSize = self.EmblemDisplay.Layers[act].Size
				if curSize + 1 <= 100 then
					self.EmblemDisplay.Layers[act].Size = self.EmblemDisplay.Layers[act].Size + 1
				end
			end
			s.IsPressed = CurTime() + 0.01
		end
	end
	
	local incmat = Material("SKILLS/endurance.png")
	self.IncreaseSize.Paint = function(s)
		draw.RoundedBoxEx(1,0,0, s:GetWide(), s:GetTall(), Color(155, 155, 155, 255))
	
		surface.SetDrawColor(color_white)
		surface.SetMaterial(incmat)
		surface.DrawTexturedRect(0,0, s:GetWide(), s:GetTall())
	
		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(0,0,s:GetWide(), s:GetTall())
	end
	
	self.DecreaseSize = vgui.Create("DButton", self)
	self.DecreaseSize:SetPos(x + (8 + self.RotateCounter:GetWide() * 3), y + self.EmblemDisplay:GetTall() + 1.5)
	self.DecreaseSize:SetSize(self.RotateCounter:GetSize())
	self.DecreaseSize:SetText("")
	
	self.DecreaseSize.OnMousePressed = function(s)
		s.IsPressed = CurTime() - 0.1
	end
	
	self.DecreaseSize.OnMouseReleased = function(s)
		s.IsPressed = false
	end
	
	local decmat = Material("EDITOR/minus.png")
	self.DecreaseSize.Paint = function(s)
		draw.RoundedBoxEx(1,0,0, s:GetWide(), s:GetTall(), Color(155, 155, 155, 255))
	
		surface.SetDrawColor(color_white)
		surface.SetMaterial(decmat)
		surface.DrawTexturedRect(12.5,5, s:GetWide() - 25, s:GetTall() - 10)
	
		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(0,0,s:GetWide(), s:GetTall())
	end
	
	self.DecreaseSize.Think = function(s)
		if !s.IsPressed then return end
		if s.IsPressed <= CurTime() then
			local act = self.EmblemDisplay:GetActiveLayer()
			if act then
				local curSize = self.EmblemDisplay.Layers[act].Size
				if curSize - 1 >= 25 then
					self.EmblemDisplay.Layers[act].Size = self.EmblemDisplay.Layers[act].Size - 1
				end
			end
			s.IsPressed = CurTime() + 0.01
		end
	end
	
	print('uh?')
	
	for k,v in pairs(self.EmblemDisplay.Layers) do
		local layer = vgui.Create("DButton")
		layer:SetSize(self.LayerList:GetWide(), self.LayerList:GetTall()/5)
		layer.Selected = false
		layer:SetText("")
		
		layer.DoClick = function(s)
			for k,v in pairs(s:GetParent():GetChildren()) do
				v.Selected = false
			end
		
			s.Selected = !s.Selected
			self.EmblemDisplay:SetActiveLayer(k)
		end
		
		layer.Paint = function(s)
			
			if s.Selected then
				draw.RoundedBoxEx(1, 0, 0, s:GetWide(), s:GetTall(), Color(95, 95, 95, 255))
			else
				draw.RoundedBoxEx(1,0,0, s:GetWide(), s:GetTall(), Color(155, 155, 155, 255))
			end
		
			draw.SimpleText("Layer #"..k, "Default", 5, 2, color_white)
			if v.ID then
				draw.SimpleText(LayerObjects[v.ID].Name, "Default", 5, s:GetTall() - 15, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			elseif v.Text then
				draw.SimpleText([["]]..v.Text..[["]], "Default", 5, s:GetTall() - 15, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			else
				draw.SimpleText("Empty Layer", "Default", 5, s:GetTall() - 15, Color(155,55,55,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			end
			
			surface.SetDrawColor(color_white)
			surface.DrawOutlinedRect(0,0,s:GetWide(), s:GetTall())
		end
		
		self.LayerList:AddItem(layer)
	end	
	
	self.IconCategories = vgui.Create("DPanelList", self)
	local ic = self.IconCategories
	
	self.IconList = vgui.Create("DPanelList", self)
	x,y = self.ColorPicker:GetPos()
	self.IconList:SetPos(5, y)
	self.IconList:SetSize(self.LayerList:GetWide(), self:GetTall() - y - 30)
	self.IconList:EnableVerticalScrollbar(true)
	self.IconList:EnableHorizontal(true)
	self.IconList:SetSpacing(1); self.IconList:SetPadding(1)
	
	nX, nY = self.IconList:GetPos()
	ic:SetSize(self.IconList:GetWide() + 1, 40)
	ic:SetSpacing(-1)
	ic:SetPos(nX, nY - ic:GetTall() - 5)
	ic:EnableHorizontal(true)
	
	local function PopulateList(cat)
		self.IconList:Clear()
		
		for k,v in pairs(LayerObjects) do
			if v.Category == cat then
				local icon = vgui.Create("DButton")
				icon:SetSize(self.IconList:GetWide()/3 - 5, self.IconList:GetWide()/3)
				icon:SetText("")
				icon.DoClick = function()
					local act = self.EmblemDisplay:GetActiveLayer()
					if act then
						self.EmblemDisplay:SetLayerValue(act, k)
						self.EmblemDisplay:SetLayerColor(act, self.ColorPicker:GetColor())
						self.EmblemDisplay:SetLayerSize(act, 50)
						self.EmblemDisplay:SetLayerRot(act, 0)
						self.EmblemDisplay:SetLayerPos(act, 50, 50)
					end
				end
				
				icon.Paint = function(s)
					draw.RoundedBoxEx(1,0,0, s:GetWide(), s:GetTall(), Color(155, 155, 155, 255))
					
					surface.SetDrawColor(self.ColorPicker:GetColor())
					surface.SetMaterial(v.Mat)
					surface.DrawTexturedRect(0,0, s:GetWide(), s:GetTall())
					
					surface.SetDrawColor(color_white)
					surface.DrawOutlinedRect(0,0, s:GetWide(), s:GetTall())
				end
				
				self.IconList:AddItem(icon)
			end
		end
	end
	
	local cat = {}
	for k,v in pairs(LayerObjects) do
		if !table.HasValue(cat, v.Category) then
			table.insert(cat, v.Category)
		end
	end
	
	for k,v in pairs(cat) do
		local catButtons = vgui.Create("DButton")
		catButtons:SetSize(ic:GetWide()/#cat + .5, ic:GetTall())
		catButtons:SetText("")
		if k == 1 then catButtons.Active = true end
		
		catButtons.DoClick = function(s)
			for key, child in pairs(s:GetParent():GetChildren()) do
				if child.Active then
					child.Active = false
				end
			end
			
			s.Active = true
			PopulateList(v)
		end
		
		catButtons.Paint = function(s)
			if s.Active then		
				draw.RoundedBoxEx(1, 0, 0, s:GetWide(), s:GetTall(), Color(95, 95, 95, 255))
			else
				draw.RoundedBoxEx(1,0,0, s:GetWide(), s:GetTall(), Color(155, 155, 155, 255))
			end
			
			draw.SimpleText(v, "Default", s:GetWide()/2, s:GetTall()/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			surface.SetDrawColor(color_white)
			surface.DrawOutlinedRect(0,0,s:GetWide(), s:GetTall())
		end
		
		ic:AddItem(catButtons)
	end
	
	PopulateList(cat[1])
end

vgui.Register("EmblemCreator", Creator, "cFrame")