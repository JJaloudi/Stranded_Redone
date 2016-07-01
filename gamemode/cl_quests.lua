Quests = {}
ActiveQuest = false
ActiveObjective = false

function GetQuest(qID)
	for k,v in pairs(QUESTS) do
		if v.ID == qID then
			return v
		end
	end
end

net.Receive("StartQuest",function()
	local qID = net.ReadUInt(16)
	Quests[qID] = {}
	
	for k,v in pairs(GetQuest(qID).Objectives) do
		if !v.Required then
			Quests[qID][k] = false
		end
	end
	
	print("YA")
	
	ActiveQuest = qID
	ActiveObjective = 1
end)

net.Receive("UpdateObjective", function()
	local qID = net.ReadUInt(16)
	local objID = net.ReadUInt(16)
	local nVal = net.ReadUInt(16)
	
	Quests[qID][objID] = nVal
	
	local gotObj = false
	for k,v in pairs(GetQuest(qID).Objectives) do
		if !Quests[qID][k] then
			if v.Required then
				local cObj = true
				for key, val in pairs(v.Required) do
					if Quests[qID][val] != GetQuest(qID).Objectives[val].Complete then
						cObj = false
						
						break
					end
				end
				
				if cObj then
					Quests[qID][k] = false
					
					gotObj = true
					ActiveObjective = k
				end
			end
		end
	end
	
	print("new val "..nVal)
	
	if !gotObj then
		if nVal == GetQuest(qID).Objectives[objID].Complete then
			for k,v in pairs(Quests[qID]) do
				if v != GetQuest(qID).Objectives[k].Complete then
					ActiveObjective = k
					
					print("New obj = "..k)
				end
			end
		end
	end
end)

hook.Add("HUDPaint", "DrawLocations", function() 
	if !ActiveQuest || !ActiveObjective then return end
	if GetQuest(ActiveQuest).Objectives[ActiveObjective][1] == "Waypoint" then
		local ref = GetQuest(ActiveQuest).Objectives[ActiveObjective]
				
		local x,y = ref[3]:ToScreen().x, ref[3]:ToScreen().y
		draw.SimpleText(ref[2], "Default", x, y, Color(255,255,255,155))
	end
end)