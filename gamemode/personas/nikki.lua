PERSONA = {}

PERSONA.ID = 1
PERSONA.Name = "Nikki"

PERSONA.Type = "Shop"
PERSONA.Model = "models/humans/group01/female_01.mdl"
PERSONA.SpawnLocations = { 
	["rp_rashkinsk"] = {
		Vec = Vector(-12832.690430, -8687.989258, 155.866455), 
		Ang = Angle( 0, -90, 0) 
	},
	["gm_construct"] = {
		Vec = Vector(1775.839966, -1601.072998, -79.968750),
		Ang = Angle(0, 180, 0)
	},
	["rp_cscdesert_v2-1"] = {
		Vec = Vector(1529.564697, -8513.271484, 64.031250),
		Ang = Angle(0,0,0)
	},
	["gm_valley"] = {
		Vec = Vector(-124.180923, -13015.787109, 176.031250),
		Ang = Angle(0,40,0)
	}
}
	
PERSONA.StartingWorth = 1000
PERSONA.PopulateInventory = function()
	local itTbl = {}
		
	for k,v in pairs(ITEMS) do
		local tbl = {}
		local it = GetItem(v.ID)
			
		if it.Category == "Buff" then 
		tbl = {it.ID, CreateRandomBuff(it.ID)}
		elseif it.Category == "Weapon" || it.Category == "Tool" then
			tbl = {it.ID, CreateWeaponAttributes(), Name = GenerateWeaponName(it.ID)} 
		else
			local stack = 10
								
			tbl = {it.ID, GetItemSpawnData(it.ID)}
			if v.DefaultStack then
				stack = v.DefaultStack
			end			
				
			if it.Stack then 
				tbl.Stack = stack
			end	
		end
			
		table.insert(itTbl, tbl)
	end
		
	return itTbl
end

PERSONA.Quests = {1}

PERSONA.Dialogue = {
	[1] = {
		Dialogue = "Hey there, welcome to my shop. I've got pretty much any material you could need for crafting here. Feel free to take a look.",
		Responses = {
			{ "Let me see your wares, peasant.", Type = {"Shop"} },
			{ "Could you help me get accustomed to this place?", Type = {"Response", 5}, Args = {"NewQuest", 1} },
			{ "Who are you exactly?", Type = {"Response", 2} },
			{ "Hey, I found all those places.", Type = {"Response", 6}, Args = {"AllObjectivesCompleted", 1} },
			{ "Oh, yeah, sorry... I have somewhere to be, or something. Bye.", Type = {"EndDialogue"} }
		}
	},
	
 	[2] = {
		Dialogue = "I'm Nikki. I run this junk shop, I take most crafting materials and redistribute them to the other guys and gals. Trying to make enough to leave this place.",
		Responses = {
			{ "Oh, I see. Where are you from?", Type = {"Response", 3} },
			{ "How's business?", Type = {"Response", 1} },
			{ "Well, nice to meet you! I've got to go though, sorry.", Type = {"EndDialogue"} }
		}
	},
	[3] = {
		Dialogue = "I'm from the North Block, it was actually a nice area. Then everyone decided that this place was the best to start their newest venture to make money.",
		Responses = {
			{ "Wow, this place has really gone down the shitter because of them, huh?", Type = {"Redirect", 1, "Yeah, well, I'd rather not talk about it. Can I do anything for you?"} }
		}
	},
	[4] = {
		Dialogue = "Yeah, well, I'd rather not talk about it. Can I do anything for you?",
		Responses = {
			{ "Let me see your wares, peasant.", Type = {"Shop"} },
			{ "Who are you exactly?", Type = {"Response", 2} },
			{ "Oh, yeah, sorry... I have somewhere to be, or something. Bye.", Type = {"EndDialogue"} }
		}
	},
	[5] = {
		Dialogue = "Oh, you're new here? Yeah, I could help you. Go to these places, you'll need to know where they are. When you're done come back.",
		Responses = {
			{ "Okay, I'll see you when I'm done.", Type = {"StartQuest", 1} },
			{ "Uh, no thanks, I'll do it some other time.", Type = {"Redirect", 1, "I was going to toss you a couple of bones but okay. Can I get you anything though?"} }
		}
	},
	[6] = {
		Dialogue = "Oh good, well, I'm glad I could be of use! Here's the stuff I promised. Enjoy your time here, if that's even possible...",
		Responses = {
			{ "Thanks for that, I appreciate the help.", Type = {"CompleteObjective", 1, 3} }
		}
	}
}

RegisterPersona(PERSONA)