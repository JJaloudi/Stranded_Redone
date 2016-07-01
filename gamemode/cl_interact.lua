local ent = false
local interactions = {}
local b = false
local vec = false

net.Receive("SelfInteract",function()
	OpenInteract(false, net.ReadTable())
end)

net.Receive("PlayerInteractTrace",function()
	if !ent || ent != net.ReadEntity() then
		local ent = net.ReadEntity()
		local interactions = net.ReadTable()
		local vec = net.ReadVector()
		count = table.Count(interactions)
		
		OpenInteract(ent, interactions, vec)
	end
end)

local count = 0
net.Receive("PlayerInteract",function()
	print("YEO!")
	if !ent || ent != net.ReadEntity() then
		local ent = net.ReadEntity()
		local interactions = net.ReadTable()
		count = table.Count(interactions)
		
		print(count)
		
		OpenInteract(ent, interactions)
	end
end)
				
function OpenInteract(ent, interactions, vec)
	if canInteract then
		local b = vgui.Create("DFrame")
		b:SetSize(150, (25 + table.Count(interactions)) * 30)
		b:ShowCloseButton(false)
		b:SetTitle("")
		b:Center()
		gui.EnableScreenClicker(true)
		
		b.Paint = function()
		end
		
		b.Think = function()
			if ent then
				if ent:IsValid() && LocalPlayer():Alive() then
					if LocalPlayer():GetPos():Distance(ent:GetPos()) <= 100 then
						local x,y = 0,0
						if vec then
							x,y = vec:ToScreen().x, vec:ToScreen().y
						else
							x,y = ent:GetPos():ToScreen().x, ent:GetPos():ToScreen().y
						end
						b:SetPos(x - b:GetWide()/2,y)
					else
						ent = false
						vec = false
						interactions = nil
						interactions = {}
						gui.EnableScreenClicker(false)
						b:Close()
					end
				else
					ent = false
					interactions = nil
					interactions = {}
					gui.EnableScreenClicker(false)
					b:Close()
				end
			end
		end
		local amt = 1
		for k,v in pairs(interactions) do
			amt = amt + 1
			local int = vgui.Create("cButton",b)
			int:SetSize(130, 30)
			int:SetPos(10, amt * 32.5)
			int:SText(v)
			
			int.DoClick = function()
				net.Start("ReceiveInteract")
					net.WriteEntity(ent)
					net.WriteEntity(LocalPlayer())
					net.WriteUInt(k,16)
				net.SendToServer()
				gui.EnableScreenClicker(false)
				b:Close()
			end
		end
	end
end