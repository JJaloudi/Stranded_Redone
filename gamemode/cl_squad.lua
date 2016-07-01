local Squad = {}
local inSquad = false

net.Receive("QuitSquad",function()
	inSquad = false
	Squad = false
	Squad = {}
end)

net.Receive("RemoveSquad",function()
	Squad.Players[net.ReadUInt(8)] = nil
end)

net.Receive("UpdateSquad",function()

	Squad.Players[1] = net.ReadEntity()
	print("yeah")
end)

net.Receive("SetSquadPlayer", function()
	Squad.Players = {}
	Squad.Leader = net.ReadEntity()
	Squad.Players = net.ReadTable()
	
	inSquad = true
end)

hook.Add("HUDPaint","Draw Squad", function()
	if inSquad then
		if Squad.Leader then
			if #Squad.Players >= 1 then
				for k,v in pairs(Squad.Players) do
					if LocalPlayer() != v then
						if v:GetPos():Distance(LocalPlayer():GetPos()) <= 2750 then
							local pos = v:GetBonePosition(v:LookupBone("ValveBiped.Bip01_Head1"))
							local x,y,vis = pos:ToScreen().x, pos:ToScreen().y - 20
							draw.SimpleText("[SQUAD] "..v:Name(), "Default",x,y, Color(0,205,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
						end
					end
				end
			end
			if LocalPlayer() != Squad.Leader then
				local pos = Squad.Leader:GetBonePosition( Squad.Leader:LookupBone("ValveBiped.Bip01_Head1"))
				local x,y,vis = pos:ToScreen().x, pos:ToScreen().y - 20
				draw.SimpleText("[LEADER] "..Squad.Leader:Name(), "Default",x,y, GAME_GREEN,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			end
		end
	end
end)