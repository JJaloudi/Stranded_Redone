util.AddNetworkString("StartQuest")
util.AddNetworkString("UpdateObjective")

MAX_ACTIVE_QUESTS = 3 // How many active quests can a player have at once?

//Convenience functions
function GetQuest(id)
	for k,v in pairs(QUESTS) do
		if v.ID == id then
			return v
		end
	end
end

//Hooks
hook.Add("Think", "HandleQuests",function()
	for k,v in pairs(player.GetAll()) do
		if v.Quests then
			if #v.Quests > 0 then
				for id, val in pairs(v.Quests) do
					local quest = GetQuest(id).Objectives
					
					for objID, data in pairs(quest) do
						if !val[objID] then
							if data[1] == "Waypoint" then
								if v:GetPos():Distance(data[3]) <= 100 then
									if data.Required then
										if v:CanCompleteObjective(id, objID) then
											v:SetObjectiveValue(id, objID, 1)
										else
											print("nah dude")
										end
									else
										print("we good")
										if v:GetPos():Distance(data[3]) <= 100 then
											v:SetObjectiveValue(id, objID, 1)
										end
									end
								
								end
							end
						end
					end
				end
			end
		end
	end
end)
//Metatables
local P = FindMetaTable("Player")

function P:GetQuests()
	return self.Quests or {}
end

function P:QuestActive(id)
	return self.Quests[id] or false
end

function P:CanCompleteObjective(qID, objID)
	if GetQuest(qID).Objectives[objID].Required then
		local cObj = true
		for k,v in pairs(GetQuest(qID).Objectives[objID].Required) do
			if self.Quests[qID][v] != GetQuest(qID).Objectives[v].Complete then
				cObj = false
						
				break
			end
		end
	
		return cObj
	else
		return true
	end
end
function P:StartQuest(id)
	self.Quests[id] = {}
	for k,v in pairs(GetQuest(id).Objectives) do
		self.Quests[id][k] = false
	end
	
	net.Start("StartQuest")
		net.WriteUInt(id,16)
	net.Send(self)
end

function P:SetObjectiveValue(qID, objID, val)
	self.Quests[qID][objID] = val

	local count = 0
	for k,v in pairs(self.Quests[qID]) do
		if v == GetQuest(qID).Objectives[objID].Complete then
			count = count + 1
		end
	end
	
	print("COUNT = "..count)
	
	if count >= table.Count(GetQuest(qID).Objectives) then
		self:CompleteQuest(qID)
	else
		net.Start("UpdateObjective")
			net.WriteUInt(qID, 16)
			net.WriteUInt(objID, 16)
			net.WriteUInt(val, 16)
		net.Send(self)
	end
end

function P:ObjectiveComplete(id, obj)
	if !self:QuestActive(id) then return false end
	
	return self.Quests[id][obj] or false
end

function P:GetCompletedQuests()
	db:Query("SELECT completedquests FROM player WHERE steamid='"..self:SteamID().."' AND charid ='"..self.CharID.."'",function(r)
		PrintTable(r)
	end)
end

function P:QuestCompleted(id)
	return false
end

function P:CompleteQuest(qID)
	GetQuest(qID).OnCompleted(self)

	self.Quests[qID] = nil
end