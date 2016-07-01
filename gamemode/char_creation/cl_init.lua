include('shared.lua')
--[[ local stringFinders = {"Hand", "Finger", "Head", "Neck"}
local body

if body then body:Remove() end 

concommand.Add("removemerge",function()
	if body then body:Remove() end 
end)

concommand.Add("Bonemerge",function()
	for i = 1, LocalPlayer():GetBoneCount() do 
		local boneString = LocalPlayer():GetBoneName(i)
		if string.find(string.lower(boneString), "head") then
			LocalPlayer():ManipulateBoneScale(i, Vector(0,0,0))
		end
	end
	
	body = ClientsideModel(Models["Female"][2].Model, RENDERGROUP_OPAQUE)
	body:SetPos(LocalPlayer():GetPos() + Vector(0,0,-90))
	body:SetParent(LocalPlayer(), LocalPlayer():LookupAttachment("eyes"))
	
	for i = 1, LocalPlayer():GetBoneCount() do 
		local boneString = LocalPlayer():GetBoneName(i)
		if !string.find(string.lower(boneString), "head") then
			body:ManipulateBoneScale(i, Vector(0,0,0))
		end
	end 
end) ]]