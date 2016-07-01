util.AddNetworkString("EquipApparel")
util.AddNetworkString("RemoveApparel")

hook.Add("PlayerInitialSpawn", "InitializeApparel", function(pl)
	pl.Apparel = {}
end)
  
local P = FindMetaTable("Player") 

function P:EquipApparel(id)
	if GetItem(id) then
		local it = GetItem(id)
		if it.Category == "Apparel" then
			self.Apparel[it.ApparelData.Type] = id
			
			net.Start("EquipApparel")
				net.WriteEntity(self)
				net.WriteUInt(id, 16)
			net.Broadcast()
		end
	end
end

function P:RemoveApparel(loc)
	if APPAREL_TYPES[loc] then
		if self.Apparel[loc] then
			self.Apparel[loc] = nil
		
			net.Start("RemoveApparel")
				net.WriteEntity(self)
				net.WriteString(loc)
			net.Broadcast()
		end
	end
end
