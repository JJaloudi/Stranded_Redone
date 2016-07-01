local Apparel = {}

net.Receive("EquipApparel",function()
	local pl = net.ReadEntity()
	local aType = net.ReadUInt(16)
	
	local item = GetItem(aType)
	if !Apparel[pl] then
		Apparel[pl] = {}
	end
	
	Apparel[pl][item.ApparelData.Type] = {ID = aType}
end)

net.Receive("RemoveApparel", function()
	local pl = net.ReadEntity()
	local aLoc = net.ReadString()
	
	if !Apparel[pl] then
		Apparel[pl] = {}
	end
	
	Apparel[pl][aLoc] = nil
end)

//Render side of things
local function refreshApparel(pl)
	for k, v in pairs(Apparel[pl]) do
		if v.RenderModel then
			if !IsValid(pl) then
				SafeRemoveEntity(v.RenderModel)
				Apparel[pl] = nil
			end
		else
			if v.ID then
				v.RenderModel = ClientsideModel(GetItem(v.ID).Model, RENDERGROUP_OPAQUE)
				v.RenderModel:SetNoDraw(true)
			--	v.RenderModel:SetParent(pl, APPAREL_TYPES[GetItem(v.ID).ApparelData.Type])
			end
		end
	end
end

hook.Add("PostDrawOpaqueRenderables", "RenderApparel", function()

	for id, pl in pairs(player.GetAll()) do
		--if pl != LocalPlayer() then
				if Apparel[pl] then
					refreshApparel(pl)
					for apparelType, appTbl in pairs(Apparel[pl]) do
						local id = appTbl.ID 
						local item = GetItem(id)
						local appData = item.ApparelData
						
						local renderMdl = appTbl.RenderModel
						
						local parent = pl
					
						if not pl:Alive() && IsValid(renderMdl) then
							parent = pl:GetRagdollEntity()
						end
							
						if IsValid(parent) then
							renderMdl:SetNoDraw(true)
							local pos, ang = parent:GetBonePosition(parent:LookupBone(APPAREL_TYPES[appData.Type]))

							local newPos = pos + (renderMdl:GetForward() * appData.vecOffset.y) + (renderMdl:GetUp() * appData.vecOffset.z) + (renderMdl:GetRight() * appData.vecOffset.x)
							
							local rot = appData.angOffset
							ang:RotateAroundAxis(ang:Right(), 	rot.x)
							ang:RotateAroundAxis(ang:Up(), 		rot.y)
							ang:RotateAroundAxis(ang:Forward(), rot.z)

							renderMdl:SetPos(newPos)
							renderMdl:SetAngles(ang)
							
							if appData.CustomColor then
								renderMdl:SetColor(appData.CustomColor)
							end
							
							if appData.Scale then
								renderMdl:SetModelScale(appData.Scale, 0)
							end
							
							renderMdl:DrawModel()
						end
					end
				end
		--end
	end
end) 