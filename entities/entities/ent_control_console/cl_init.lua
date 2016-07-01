include("shared.lua")

surface.CreateFont( "3D2DSmall", 
                    {
                    font    = "Roboto-Light",
                    size    = 12,
                    weight  = 1000,
                    antialias = true,
                    shadow = false
})

function ENT:Draw()
	self:DrawModel()
	
	local pos = self.Entity:GetPos() + (self.Entity:GetForward() * 13) + (self.Entity:GetUp() * 28) + (self.Entity:GetRight() * 7.5)
	local rot = Vector(-90, 90, 0)
	local ang = self.Entity:GetAngles()
	ang:RotateAroundAxis(ang:Right(), 	rot.x)
	ang:RotateAroundAxis(ang:Up(), 		rot.y)
	ang:RotateAroundAxis(ang:Forward(), rot.z)
	
	local key = self:GetNWInt("Territory", -1)
	local controller = self:GetNWString("Controller")
	local HP = self:GetNWInt("HP", 10)
	cam.Start3D2D(pos, ang, 0.2) 
	
		
		draw.RoundedBoxEx(1,0,0, 117, 38, color_black)
		draw.RoundedBoxEx(1,22.5,65, 71.5, 20, color_black)
		if key != -1 then
			draw.SimpleText("Enabled", "Default", 59, 75, Color(55,155,55,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(key, "3D2DSmall", 60, 6, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			draw.SimpleText(controller, "3D2DSmall", 60, 17.5, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			
			draw.RoundedBoxEx(1, 5, 25, 107 * HP / 100, 10, Color(55,155,55,255))
			surface.SetDrawColor(color_white)
			surface.DrawOutlinedRect(5, 25, 107,11)
		else
			draw.SimpleText("Disabled", "Default", 59, 75, Color(155,55,55,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("Not Connected", "3D2DSmall", 60, 17.5, Color(155,55,55,255), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
		
		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(0,0,117,39)
		surface.DrawOutlinedRect(22.5,65, 73, 21)
		
	cam.End3D2D()
end