MAX_FACTION_RANKS = 5
Factions = {}

util.AddNetworkString("FactionPlayerOffline")
hook.Add("PlayerDisconnected", "RemoveFaction",function(pl)
	if pl.FacID then
		local fac_id = pl.FacID
		if Factions[fac_id] then
			local onlineCount = 0
			
			local id = 0
			for k,v in pairs(Factions[fac_id].Players) do
			
				if v.CharID == pl.CharID then
					v.Online = false
					id  = k
				end
				
				if v.Online then
					onlineCount = onlineCount + 1
				end
			end
			
			
			if onlineCount == 0 then
				print("Removed faction "..Factions[fac_id].Name..", all players are offline.")
			
				Factions[fac_id] = nil
			else
				for k,v in pairs(GetOnlineFactionPlayers(fac_id)) do
					net.Start("FactionPlayerOffline")
						net.WriteUInt(id, 8)
					net.Send(v)
				end
			end
		end
	end
end)

util.AddNetworkString("CreateFaction")
net.Receive("CreateFaction",function()
	local pl = net.ReadEntity()
	local name = net.ReadString()
	local motd = net.ReadString()
	local slots = net.ReadUInt(8)
	local tag = net.ReadString()
	local encodedEmblem = net.ReadString()
	
	print(encodedEmblem)
	
	CreateFaction(name, pl)
end)
 
function CreateFaction(fac_name, owner)
	local ownerID = owner.CharID
	local fac_id = 1
	
	if !owner.FacID then
		db:Query("select * from factions",function(r)
			if r[1].data then
				fac_id = table.Count(r[1].data) + 1
			end
			
			if string.find(fac_name, "%x") then //do character check and shit here
				
				owner:Notify("Processing creation...")
				
				local plTbl = {
					[1] = {
						SteamID = owner:SteamID(), 
						Rank = 4,
						CharID = ownerID,
						Name = owner.CharName
					}
				}
				
				local hTbl = { 
					Ranks = {
						[1] = {Name = "Recruit", Tax = 40},
						[2] = {Name = "Member", Flags = {FLAG_BANK, FLAG_INV}, Tax = 30},
						[3] = {Name = "Co-Leader", Flags = {FLAG_BANK, FLAG_INV, FLAG_TERRITORY}, Tax = 20},
						[4] = {Name = "Owner", Flags = {1,2,3,4}, Tax = 10}	
					}
				}
				
				db:Query("Insert into factions (fac_id, fac_name, fac_players, fac_data) values ("..tonumber(fac_id)..", '"..fac_name.."', '"..util.TableToJSON(plTbl).."', '"..util.TableToJSON(hTbl).."')",function(res)
					
					owner:Notify("Faction creation complete!")
					
					Factions[fac_id] = { 
						
						Name = fac_name, 
					
						Players = {
						
							[1] = {
								SteamID = owner:SteamID(),
								CharID = owner.CharID,
								Rank = 4,
								Name = owner.CharName
							}
							
						},
								
						Bank = 500
						
					}
					
					owner:SaveFaction(fac_id)
				end)
			else
				owner:Notify("You can't have special characters in your factions name!")
			end
		end)
	else
		owner:Notify("You can't create a faction if you're already in one!")
	end
end


function LoadFactionData(id)
	db:Query("Select * from factions where fac_id="..id, function(res)
		if res[1].data then
			local tbl = res[1].data[1]
			
			Factions[id] = {
				Name = tbl.fac_name, 
				Players = util.JSONToTable(tbl.fac_players),
				Bank = tbl.fac_bank,
				//Inventory = util.JSONToTable(tbl.fac_inventory),
				Data = util.JSONToTable(tbl.fac_data)
			}
			
			for k,v in pairs(Factions[id].Players) do
				if CharacterIsOnline(v.CharID, v.SteamID) then
					v.Online = true
				end
			end
			
			print("Faction '"..Factions[id].Name.."' loaded onto server.")
		end
	end)
end

function GetOnlineFactionPlayers(facid)
	local oTbl = {}
	local ref = Factions[facid]
	
	for k,v in pairs(player.GetAll()) do
		if v.FacID == facid then
			table.insert(oTbl, v)
		end
	end
	
	return oTbl
end


util.AddNetworkString("RemoveFactionPlayer")
util.AddNetworkString("UpdateRemoveFactionPlayer")
util.AddNetworkString("RemovedFromFaction")
function RemoveFactionPlayer(id, slot)
	local ref = Factions[id]

	if ref then
		if ref.Players[slot] then		
			local pl = player.GetBySteamID(ref.Players[slot].SteamID)
			
			for k,v in pairs(GetOnlineFactionPlayers(id)) do
				net.Start("UpdateRemoveFactionPlayer")
					net.WriteUInt(slot, 8)
				net.Send(v)
			end
			
			if pl then
				if pl.CharID == CharID && pl.SteamID == steamid then
				
						tblID = k
						
					local pl = player.GetBySteamID(ref.Players[slot].SteamID)
					if pl then
						if pl.CharID == ref.Players[slot].CharID then
							pl:SaveFaction(0)
							pl.FacID = false
								
							net.Start("RemovedFromFaction")
							net.Send(pl)
						end
					else
						print("no")
					end
					
				end
			end
			
			
			ref.Players[slot] = nil
			
			db:Query("update factions set fac_players='"..util.TableToJSON(Factions[id].Players).."' where fac_id="..id)
		end
	end
end
net.Receive("RemoveFactionPlayer",function() RemoveFactionPlayer(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8)) end)


util.AddNetworkString("AddFactionPlayer")
util.AddNetworkString("UpdateAddFactionPlayer")
function AddFactionPlayer(id, pl, rank)
	local ref = Factions[id]

	if ref then
		if ref.Players then
		
			local pTbl = {
				SteamID = pl:SteamID(),
				CharID = pl.CharID, 
				Rank = rank,
				Name = pl.CharName
			}
			table.insert(Factions[id].Players, pTbl)
			
			for k,v in pairs(GetOnlineFactionPlayers(id)) do
				net.Start("UpdateAddFactionPlayer")
					net.WriteTable(pTbl)
				net.Send(v)
			end
			
			pl:SaveFaction(id)
			
			db:Query("update factions set fac_players='"..util.TableToJSON(Factions[id].Players).."' where fac_id="..id)
		end
	end	
end

--[[ 	db:Query("select fac_data from factions where fac_id="..id,function(res)
		if res[1].data then
			local tbl = util.JSONToTable(res[1].data[1].fac_data)
			
			return tbl.Ranks
		end
	end) ]]


util.AddNetworkString("CreateFactionRank")
function CreateFactionRank(id, name, flags, tax)
	local ref = Factions[id]
	
	if ref then
		if table.Count(ref.Data.Ranks) + 1 <= MAX_FACTION_RANKS then
			local dRef = Factions[id].Data.Ranks
			
			local id = 1
			for i = 1, #MAX_FACTION_RANKS do
				if !dRef[i] then
					id = i
					
					break
				end
			end
			
			dRef[id] = {Name = name, Flags = flags, Tax = tonumber(tax)}
			
			for k,v in pairs(GetOnlineFactionPlayers(id)) do
				net.Start("SendFactionHierarchy")
					net.WriteTable(dRef)
				net.Send(v)
			end
			
			db:Query("update factions set fac_data='"..util.TableToJSON(Factions[id].Data).."' where fac_id="..id)	
		else
			print("na b")
			return false
		end
	end
	
end


util.AddNetworkString("ChangeFactionRankName")
util.AddNetworkString("UpdateFactionRankName")
function ChangeFactionRankName(id, rankid, nName)
	local ref = Factions[id]
	
	if ref then
		if ref.Data.Ranks[rankid] then
			ref.Data.Ranks[rankid].Name = nName
			
			db:Query("update factions set fac_data='"..util.TableToJSON(Factions[id].Data).."' where fac_id="..id)
		end
	end
end


util.AddNetworkString("SetFactionPlayerRank")
util.AddNetworkString("UpdateFactionPlayerRank")
function SetFactionPlayerRank(id, pID, rank)
	local ref = Factions[id]

	if ref then
		if ref.Players then
			if ref.Players[pID] then
				local pl = player.GetBySteamID(ref.Players[pID].SteamID)
				
				ref.Players[pID].Rank = rank
			
				for k,v in pairs(GetOnlineFactionPlayers(id)) do
					net.Start("UpdateFactionPlayerRank")
						net.WriteUInt(pID, 8)
						net.WriteUInt(rank, 8)
					net.Send(v)
				end
			
				db:Query("update factions set fac_players='"..util.TableToJSON(Factions[id].Players).."' where fac_id="..id)
			end
		end
	end	
end
net.Receive("SetFactionPlayerRank",function() SetFactionPlayerRank(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8)) end)

util.AddNetworkString("DeleteFactionRank")
function DeleteFactionRank(id, rankid)
	local ref = Factions[id] 
	
	if ref then
		if ref.Data.Ranks[rankid] then
			ref.Data.Ranks[rankid] = nil
			
			for k,v in pairs(GetOnlineFactionPlayers(id)) do
				net.Start("SendFactionHierarchy")
					net.WriteTable(ref.Data.Ranks)
				net.Send(v)
			end
			
			db:Query("update factions set fac_data='"..util.TableToJSON(Factions[id].Data).."' where fac_id="..id)
		end
	end
end


util.AddNetworkString("SetFactionRankTax")
util.AddNetworkString("UpdateFactionRankTax")
function SetFactionRankTax(id, rankid, tax)
	local ref = Factions[id]
	
	if ref then
		if ref.Data.Ranks[rankid] then
			ref.Data.Ranks[rankid].Tax = tax
			
			for k,v in pairs(GetOnlineFactionPlayers(id)) do
				net.Start("UpdateFactionRankTax")
					net.WriteUInt(rankid,8)
					net.WriteUInt(tax,8)
				net.Send(v)
			end
			
			db:Query("update factions set fac_data='"..util.TableToJSON(Factions[id].Data).."' where fac_id="..id)
		end
	end
end


util.AddNetworkString("SetFactionRankFlags")
util.AddNetworkString("UpdateFactionRankFlags")
function SetFactionRankFlags(id, rankid, fTbl)
	local ref = Factions[id]
	
	if ref then
		if ref.Data.Ranks[rankid] then
			ref.Data.Ranks[rankid].Flags = fTbl
			
			for k,v in pairs(GetOnlineFactionPlayers(id)) do
				net.Start("UpdateFactionRankFlags")
					net.WriteUInt(rankid,8)
					net.WriteTable(fTbl)
				net.Send(v)
			end
			
			db:Query("update factions set fac_data='"..util.TableToJSON(Factions[id].Data).."' where fac_id="..id)
		end
	end
end


util.AddNetworkString("SetFactionBank")
function SetFactionBank(id, bank)
	local ref = Factions[id]

	if ref then
		ref.Bank = bank
		
		db:Query("update factions set fac_bank="..bank.." where fac_id="..id)
	end
end

function GetFactionBank(id)
	local ref = Factions[id]

	if ref then
		return ref.Bank
	end
end

function AddFactionBank(facid, bank)
	SetFactionBank(facid, GetFactionBank(facid) + bank)
end