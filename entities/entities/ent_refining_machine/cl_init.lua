include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	
	local pos = self.Entity:GetPos() + (self.Entity:GetForward() * 25.9) + (self.Entity:GetUp() * 12.5) + (self.Entity:GetRight() * 5)
	local rot = Vector(0, 90, 90)
	local ang = self.Entity:GetAngles()
	ang:RotateAroundAxis(ang:Right(), 	rot.x)
	ang:RotateAroundAxis(ang:Up(), 		rot.y)
	ang:RotateAroundAxis(ang:Forward(), rot.z)
	
	local key = self:GetNWInt("Enabled", -1)
	local HP = self:GetNWInt("HP", 10)
	local comp = self:GetNWInt("StrikeCompletion", 0)
	cam.Start3D2D(pos, ang, 0.2) 
		draw.RoundedBoxEx(1,0,0,52.5,98,Color(55,55,55,255))
		draw.RoundedBoxEx(1,0, 0, 52.5, 103 * comp / 100, Color(255 - 255 * comp / 100, 255 * comp / 100, 0, 255))
	
		if key != -1 then
			draw.RoundedBoxEx(1,2.5,2.5,15,15, Color(55,155,55,255))
		else
			draw.RoundedBoxEx(1,2.5,2.5,15,15, Color(155,55,55,255-math.sin(CurTime()*math.abs(10))*2550))
		end
		
		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(3,3,15,15)//Power outline
		surface.DrawOutlinedRect(0,0, 53, 98)
		
	cam.End3D2D()
	
	rot = Vector(-90, 90, 0)
end