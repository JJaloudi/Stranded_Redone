include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	local rot = Vector(-90, 90, 0)
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(), 	rot.x)
	ang:RotateAroundAxis(ang:Up(), 		rot.y)
	ang:RotateAroundAxis(ang:Forward(), rot.z)
	local pos = self.Entity:GetPos() + (self.Entity:GetUp() * 70.1)
	
	cam.Start3D2D(pos, ang, 0.3 )
		if GetItem(self:GetNWInt("Item")) then
			draw.DrawText("Stay close by to craft!", "Notification", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
			surface.SetDrawColor( color_white )
			surface.DrawOutlinedRect( -75,24.5, 150,20)
			draw.RoundedBoxEx(1,-73,25.5,146 * self:GetNWInt("Progress") / self:GetNWInt("mProgress"), 16,GAME_OUTLINE)
			draw.DrawText(GetItem(self:GetNWInt("Item")).Name, "Notification", 0, 22, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
		end
		
		
    cam.End3D2D()
end

--[[ 	self:DrawModel()
	local rot = Vector(-90, 90, -90)
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(), 	rot.x)
	ang:RotateAroundAxis(ang:Up(), 		rot.y)
	ang:RotateAroundAxis(ang:Forward(), rot.z)
	local pos = self:GetPos() + (self:GetUp() * 17) + (self:GetForward() * -20)
	cam.Start3D2D( pos, ang, 0.3 )
		draw.DrawText("Crafting:", "Notification", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
		surface.SetDrawColor( color_white )
		surface.DrawOutlinedRect( -75,24.5, 150,20)
		draw.RoundedBoxEx(1,-73,25.5, 146, 16,GAME_OUTLINE)
		draw.DrawText(GetItem(1).Name, "Notification", 0, 22, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
		
		
    cam.End3D2D() ]]