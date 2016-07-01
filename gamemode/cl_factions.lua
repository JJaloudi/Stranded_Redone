//ISSUES:
//It doesn't seem to register when a player is removed in the onlineCount variable for some damn reason.
//Some players can't be kicked, could've been an issue in the moment.

Faction = {}
Faction.Name = false
Faction.ID = false
Faction.Money = 0
Faction.Players = {}

local function ReloadFaction()
	if MenuRef then
		if MenuRef:Valid() then
			if MenuRef.ActiveDetailPanel == "Faction" then
				MenuRef.ReloadFactionPanel()
			end
		end
	end
end

net.Receive("SendFactionInfo",function()
	Faction.Name = net.ReadString()
	Faction.ID = net.ReadUInt(16)
end)

net.Receive("RemovedFromFaction",function()
	Faction = {}
	Faction.Name = false
	Faction.ID = false
	Faction.Money = 0
	Faction.Players = {}
	
	//ReloadFaction()
end)

net.Receive("SendFactionHierarchy",function()
	Faction.Ranks = net.ReadTable()
	
	//ReloadFaction()
end)

net.Receive("SendFactionPlayers",function()
	Faction.Players = net.ReadTable()
	PrintTable(Faction.Players)
	
	for k,v in pairs(Faction.Players) do
		if v.SteamID == LocalPlayer():SteamID() && v.CharID == CharID then
			Faction.Player = k
		end
	end
	
	//ReloadFaction()
end)

net.Receive("UpdateRemoveFactionPlayer",function()
	local id = net.ReadUInt(8)
	
	Faction.Players[id] = nil
	print("Removed player")
	
	//ReloadFaction()
end)

net.Receive("UpdateAddFactionPlayer",function()
	local tbl = net.ReadTable()
	tbl.Online = true
	Faction.Players[#Faction.Players + 1] = tbl
	
	//ReloadFaction()
end)

net.Receive("UpdateFactionPlayerRank",function()
	local id = net.ReadUInt(8)
	local rank = net.ReadUInt(8)
	
	Faction.Players[id].Rank = rank
	
	//ReloadFaction()
end)

net.Receive("FactionPlayerOnline",function()
	local id = net.ReadUInt(8)
	if Faction.Players[id] then
		Faction.Players[id].Online = true
	else
		print("ID: "..id.." doesn't exist?")
	end
end)

net.Receive("FactionPlayerOffline",function()
	Faction.Players[net.ReadUInt(8)].Online = false
	
	//ReloadFaction()
end)

net.Receive("UpdateFactionRankName",function()
	Faction.Ranks[net.ReadUInt(8)].Name = net.ReadString()
	
	//ReloadFaction()
end)

net.Receive("UpdateFactionRankTax",function()
	Faction.Ranks[net.ReadUInt(8)].Tax = net.ReadUInt(8) 
	
	//ReloadFaction()
end)

net.Receive("UpdateFactionRankFlags",function()
	Faction.Ranks[net.ReadUInt(8)].Flags = net.ReadTable()
	
	//ReloadFaction()
end)

local onlineCount = 0
function GetOnlineCount()	
	local nCount = 0
	for k,v in pairs(Faction.Players) do
		if v.Online then
			nCount = nCount + 1
		end
	end
	onlineCount = nCount
end

function GetPlayerFromFaction()
	return Faction.Players[Faction.Player]
end