include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	
	local pos = self.Entity:GetPos() + (self.Entity:GetForward() * 2) + (self.Entity:GetUp() * 22) + (self.Entity:GetRight() * 48)
	local rot = Vector(-180, 160, -90)
	local ang = self.Entity:GetAngles()
	ang:RotateAroundAxis(ang:Right(), 	rot.x)
	ang:RotateAroundAxis(ang:Up(), 		rot.y)
	ang:RotateAroundAxis(ang:Forward(), rot.z)
	
	local key = self:GetNWInt("Enabled", -1)
	local HP = self:GetNWInt("HP", 10)
	local comp = self:GetNWInt("StrikeCompletion", 0)
	cam.Start3D2D(pos, ang, 0.2) 
		draw.RoundedBoxEx(1,0,0,125,21.5,Color(55,55,55,255))
		
	
		if key != -1 then
			draw.RoundedBoxEx(1,0, 0, 128 * comp / 100, 21.5, Color(255 - 255 * comp / 100, 255 * comp / 100, 0, 255))
			draw.RoundedBoxEx(1,2.5,2.5,15,15, Color(55,155,55,255))
		else
			draw.RoundedBoxEx(1,0,0,125,21.5,Color(55,55,55,255))
			draw.RoundedBoxEx(1,2.5,2.5,15,15, Color(155,55,55,255-math.sin(CurTime()*math.abs(10))*2550))
			
		end
		draw.SimpleText("Power Status", "3D2DSmall", 20, 2.5, color_white)
		
		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(3,3,15,15)//Power outline
		surface.DrawOutlinedRect(0,0, 125, 22)
		
	cam.End3D2D()
	
	rot = Vector(-90, 90, 0)
end