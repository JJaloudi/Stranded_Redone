//Outgoing
util.AddNetworkString("StartDialogue")
util.AddNetworkString("UpdateDialogue")
util.AddNetworkString("EndDialogue")

//Incoming
util.AddNetworkString("HandleResponse")

PERSONAS = {}

function RegisterPersona(pTbl)
	table.insert(PERSONAS, pTbl)

	print("Registered persona of "..pTbl.Name.."[ID: "..pTbl.ID.."]")
end

//Initializing Persona Ents
timer.Simple(5, function()
	for k,v in pairs(ents.FindByClass("ent_persona")) do v:Remove() end

	for k,v in pairs(PERSONAS) do
		if v.SpawnLocations then
			local loc = v.SpawnLocations[string.lower(game.GetMap())]
			if loc then
				local ent = ents.Create("ent_persona")
				ent:SetPos(loc.Vec)
				ent:SetAngles(loc.Ang)
				ent:Spawn()
				
				ent:SetPersona(v.ID)
				ent:SetModel(v.Model)
			end
		end
	end
end)

//Convenience functions
function GetPersonaKey(id)
	for k,v in pairs(PERSONAS) do
		if v.ID == id then
			return k
		end
	end
end

function GetPersonaNPC(id)
	for k,v in pairs(ents.FindByClass("ent_persona")) do
		if v.PersonaID == id then
			return v
		end
	end
end

local function ParseArgs(args, pl, ent)
	local argType = args[1]
	if argType == "DialogueObjective" then
		local questID = args[2]
		local objID = args[3]
		
		if pl:QuestActive(questID) then
			return !pl:ObjectiveComplete(questID, objID)
		else
			return false
		end
	elseif argType == "NewQuest" then
		local questID = args[2]
		
		if !pl:QuestCompleted(questID) && !pl:QuestActive(questID) then
			return true
		end
	elseif argType == "AllObjectivesCompleted" then
		local qID = args[2]
		if pl:QuestActive(qID) then
			local quest = GetQuest(qID)
			
			local count = 0
			for k,v in pairs(pl.Quests[qID]) do
				if v == quest.Objectives[k].Complete then
					count = count + 1
				end
			end
			
			print(count)
			
			print(table.Count(pl.Quests[qID]) - 1)
			
			return count >= table.Count(pl.Quests[qID]) - 1
		else
			print("na da qeest aint acteev")
		
			return false
		end
	elseif argType == "HasItem" then
		local Item = args[2]
		
		if pl:HasItem(Item) then
			return true
		else
			return false
		end
	end
end

//Starting the dialogue, gathering it's data to be sent to the player.
function StartDialogue(pl, npc)
	local id = npc.PersonaID
	local pTbl = PERSONAS[GetPersonaKey(id)]
	
	local dialogueID = 1
	local dTbl = pTbl.Dialogue[dialogueID]
	local greetString = dTbl.Dialogue 
	local camData = dTbl.CamLocation || false
	
	local responseTbl = {}
	for k,v in pairs(dTbl.Responses) do
		local tbl = {Response = v[1], ID = k}
		if v.Args then
			if ParseArgs(v.Args, pl, npc) then
				table.insert(responseTbl, tbl) // Sorting through what should be sent and what shouldn't
			end
		else
			table.insert(responseTbl, tbl)
		end
	end
	
	pl:Freeze()
	
	net.Start("StartDialogue")
		net.WriteEntity(npc)
		net.WriteString(pTbl.Name)
		net.WriteUInt(id, 16)
		net.WriteUInt(dialogueID, 16)
		net.WriteString(greetString)
		net.WriteTable(responseTbl)
		if camData then
			net.WriteTable(camData)
		else
			net.WriteTable({})
		end
	net.Send(pl)
end

//Processing a response.
net.Receive("HandleResponse",function()
	local pl = net.ReadEntity() //Player involved in dialogue... Self explanatory?
	local ent = net.ReadEntity()
	local npcID = net.ReadUInt(16) // ID of the NPC player is conversating with
	local dialogueID = net.ReadUInt(16) // ID of the dialogue the player is involved in
	local responseID = net.ReadUInt(16) // ID of the response the player chose
	
	local personaTbl = PERSONAS[GetPersonaKey(npcID)]
	local dRef = personaTbl.Dialogue[dialogueID].Responses[responseID]

	if dRef.Type[1] == "EndDialogue" then
		net.Start("EndDialogue")
		net.Send(pl)

		pl:Freeze(false)
	elseif dRef.Type[1] == "Shop" then
		net.Start("EndDialogue")
		net.Send(pl)
	
		net.Start("SendShop")
			net.WriteEntity(ent)
			net.WriteUInt(ent.Worth, 16)
			net.WriteTable(ent.Inventory)
		net.Send(pl)
			
		table.insert(ent.Viewers, pl)
	elseif dRef.Type[1] == "Response" then
		local newID = dRef.Type[2]
		local dTbl = personaTbl.Dialogue[newID]
		local newDialogue = dTbl.Dialogue
		
		local responseTbl = {}
		for k,v in pairs(dTbl.Responses) do
			local tbl = {Response = v[1], ID = k}
			if v.Args then
				if v.Args(pl, npc) then
					table.insert(responseTbl, tbl) // Sorting through what should be sent and what shouldn't
				end
			else
				table.insert(responseTbl, tbl)
			end
		end
	
		net.Start("UpdateDialogue")
			net.WriteUInt(newID, 16)
			net.WriteString(newDialogue)
			net.WriteTable(responseTbl)
			net.WriteTable(dTbl.CamLocation || {})
		net.Send(pl)
	elseif dRef.Type[1] == "Redirect" then	
		local newID = dRef.Type[2]
		local dTbl = personaTbl.Dialogue[newID]
		local newDialogue = dRef.Type[3]
		
		local responseTbl = {}
		for k,v in pairs(dTbl.Responses) do
			local tbl = {Response = v[1], ID = k}
			if v.Args then
				if ParseArgs(v.Args, pl, ent) then
					table.insert(responseTbl, tbl) // Sorting through what should be sent and what shouldn't
				end
			else
				table.insert(responseTbl, tbl)
			end
		end
	
		net.Start("UpdateDialogue")
			net.WriteUInt(newID, 16)
			net.WriteString(newDialogue)
			net.WriteTable(responseTbl)
			net.WriteTable(dTbl.CamLocation || {})
		net.Send(pl)
	elseif dRef.Type[1] == "StartQuest" then
		local qID = dRef.Type[2]
		
		if !pl:QuestCompleted(qID) then
			pl:StartQuest(qID)
			
			net.Start("EndDialogue")
			net.Send(pl)
		end
	elseif dRef.Type[1] == "CompleteObjective" then
		local qID = dRef.Type[2]
		local objID = dRef.Type[3]
		
		pl:SetObjectiveValue(qID, objID, 1)
		
		net.Start("EndDialogue")
		net.Send(pl)
	end
end)