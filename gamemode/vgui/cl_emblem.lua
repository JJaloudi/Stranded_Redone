LayerObjects = {
	[1] = {
		Name = "Running Man",
		Mat = Material("skills/agility.png"),
		Category = "Icons"
	},
	[2] = {
		Name = "AK47",
		Mat = Material("skills/arms.png"),
		Category = "Icons"
	},
	[3] = {
		Name = "The Watch",
		Mat = Material("skills/stealth.png"),
		Category = "Objects"
	},
	[4] = {
		Name = "Denied",
		Mat = Material("PDA/close.png"),
		Category = "Objects"
	},
	[5] = {
		Name = "Faction Members",
		Mat = Material("PDA/factions.png"),
		Category = "Icons"
	},
	[6] = {
		Name = "Dinner Time",
		Mat = Material("SKILLS/survival.png"),
		Category = "Icons"
	},
	[7] = {
		Name = "Driver",
		Mat = Material("SKILLS/vehicles.png"),
		Category = "Icons"
	},
	[8] = {
		Name = "Help",
		Mat = Material("SKILLS/endurance.png"),
		Category = "Icons"
	},
	[9] = {
		Name = "Handyman",
		Mat = Material("SKILLS/crafting.png"),
		Category = "Objects"
	},
	[10] = {
		Name = "Trash Talk",
		Mat = Material("HUD/gmTrash.png"),
		Category = "Objects"
	},
	[11] = {
		Name = "Wrench",
		Mat = Material("HUD/craft.png"),
		Category = "Objects"
	},
	[12] = {
		Name = "Sherlock",
		Mat = Material("HUD/exam.png"),
		Category = "Icons"
	},
	[13] = {
		Name = "Map",
		Mat = Material("PDA/map.png"),
		Category = "Icons"
	},
	[14] = {
		Name = "Gears",
		Mat = Material("PDA/settings.png"),
		Category = "Objects"
	},
	[15] = {
		Name = "Level Up",
		Mat = Material("PDA/skills.png"),
		Category = "Icons"
	},
	[16] = {
		Name = "Backpack",
		Mat = Material("PDA/inventory.png"),
		Category = "Objects"
	},
	[17] = {
		Name = "List",
		Mat = Material("PDA/quests.png"),
		Category = "Letters"
	},
	[18] = {
		Name = "1 Font: PLACEHOLDER",
		Mat = Material("dng.png"),
		Category = "Numbers"
	}
}

local Emblem = {}

function Emblem:Init()
	self.Layers = {}
	for i = 1, MAX_LAYERS do
		self.Layers[i] = {}
	end
	
	self:SetSize(200, 200)
	self.DefaultSize = 200
	self.Scale = 1
end

function Emblem:GetLayers()
	return self.Layers
end

function Emblem:IsLayerActive(layer)
	return self.Layers[layer].ID || self.Layers[layer].Text
end

function Emblem:SetData(data)
	if type(data) == "string" then
		self.Layers = util.JSONToTable(data)
	else
		self.Layers = data
	end
end

function Emblem:SetRelativePos(xScreen, yScreen)
	self.Pos = {x = xScreen, y = yScreen}
	
	PrintTable(self.Pos)
end

function Emblem:GetRelativePos()
	return self.Pos or self:GetPos()
end

function Emblem:GetEncodedData()
	return util.TableToJSON(self.Layers)
end

function Emblem:GetEncodedLayer(layer)
	return util.TableToJSON(self.Layers[layer])
end

function Emblem:SetLayerColor(layer, col)
	self.Layers[layer].Color = col
end

function Emblem:SetLayerValue(layer, val)
	if type(val) == "string" then
		self.Layers[layer].ID = nil
		self.Layers[layer].Text = val
	else
		self.Layers[layer].ID = tonumber(val)
		self.Layers[layer].Text = nil
	end
end

function Emblem:SetLayerRot(layer, rot)
	self.Layers[layer].Rot = rot
end

function Emblem:SetLayerSize(layer, pix)
	self.Layers[layer].Size = pix
end

function Emblem:SetLayerPos(layer, xp, yp)
	self.Layers[layer].Pos = {x = xp,y = yp}
end

function Emblem:OnCursorEntered()
	self.CursorActive = true
end

function Emblem:OnCursorExited()
	self.CursorActive = false
end

function Emblem:OnMousePressed()
	if self.ActiveLayer then
		self.CanDrag = true
	end
end

function Emblem:OnMouseReleased()
	if self.CanDrag then
		self.CanDrag = false
	end
end

function Emblem:SetActiveLayer(layerID)
	self.ActiveLayer = layerID
end

function Emblem:GetActiveLayer()
	return self.ActiveLayer or false
end

local xpos, ypos = false, false
function Emblem:Think()
	if self.Scale != self:GetWide()/self.DefaultSize then
		self.Scale = self:GetWide()/self.DefaultSize
	end

	if self.CanDrag && input.IsMouseDown(MOUSE_LEFT) && self.CursorActive then
		self.Dragging = true
		local x,y = self:GetRelativePos().x, self:GetRelativePos().y
		local xBounds, yBounds = x + self:GetWide(), y + self:GetTall()
		local xMouse, yMouse = gui.MousePos()
		
		xpos = xMouse - x
		ypos = yMouse - y
		
		self.Layers[self.ActiveLayer].Pos = {x = xpos, y = ypos}
		
		PrintTable(self.Layers[self.ActiveLayer].Pos)
	else
		self.Dragging = false
	end
end

function Emblem:Paint() // where we render the emblems data
	local s = self

	local offsetX, offsetY = s:GetWide()/2, s:GetTall()/2
	for i = 1, #self.Layers do
		local v = self.Layers[i]
		if v.Pos then
			local layerX, layerY = v.Pos.x, v.Pos.y
			
			if v.ID then
				if self.ActiveLayer == i && !self.Dragging then
					surface.SetDrawColor(Color(v.Color.r, v.Color.g, v.Color.b, 205 + math.sin(CurTime()*math.abs(3))*155))
				else
					surface.SetDrawColor(v.Color)
				end
				surface.SetMaterial(LayerObjects[v.ID].Mat)
				surface.DrawTexturedRectRotated(layerX, layerY, v.Size * self.Scale, v.Size * self.Scale, v.Rot)
			end
		end
	end
end

function Emblem:PaintOver()
	surface.SetDrawColor(color_white)
	surface.DrawOutlinedRect(0,0, self:GetWide(), self:GetTall())
end

vgui.Register("Emblem", Emblem, "DPanel")