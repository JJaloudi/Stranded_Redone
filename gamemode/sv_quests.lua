QUESTS = {}

QUEST_TYPES = {
	["Delivery"] = {
		"PickupNPC",
		"FindItem"
	}
}

QUEST_BOARDS = {
	["gm_construct"] = {
	}
}

function GenerateQuest(type, ent)
	local Quest = {}
	
	Quest.Type = {type, table.Random(QUEST_TYPES[type])}
	Quest.NPC = ent
	
	if type == "Delivery" then
		if Quest.Type[2] == "PickupNPC" then
		end
	end
end