concommand.Add("Testmenu", function()
	local d = vgui.Create("cFrame")
	d:SetSize(800,600)
	d:SetText("Test Panel")
	d:MakePopup()
	d:Center()
	
	local but = vgui.Create("cButton",d)
	but:SetPos(150,150)
	but:SText("TEST WOO")
	but:SetSize(100,35)
end)

concommand.Add("openteammenu",function()
	local base = vgui.Create("cFrame")
	base:SetSize(800,600)
	base:SetText("Select Your Faction")
	base:MakePopup(true)
	base:Center()
	base:SetDraggable(false)
	base:ShowCloseButton(true)
	
	for k,v in pairs(team.GetAllTeams()) do
		if TEAM_DATA[k] then
			local Pan = vgui.Create("DFrame")
			Pan.Paint = function() end
			Pan:SetSize(400,180)
			Pan:SetTitle("")
			
			local Join = vgui.Create("cButton",Pan)
			Join:SetPos(0, 140)
			Join:SetSize(400, 40)
			Join:SText("Join "..team.GetName(k))
		else
			print("NAW")
		end
	end
	
end)