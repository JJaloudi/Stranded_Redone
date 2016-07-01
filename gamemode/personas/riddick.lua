PERSONA = {}

PERSONA.ID = 3
PERSONA.Name = "Riddick"

PERSONA.Type = "Shop"
PERSONA.Model = "models/humans/group01/male_01.mdl"
PERSONA.SpawnLocations = { 
	["gm_valley"] = {
		Vec = Vector(-1424.9583740234, -13018.915039063, 5.03125),
		Ang = Angle(0,-90,0)
	}
}
	
PERSONA.StartingWorth = 1000
PERSONA.PopulateInventory = function()
	local itTbl = {}
		
	for k,v in pairs(ITEMS) do
		local tbl = {}
		local it = GetItem(v.ID)
			
		if it.Category == "Resource" then 
			local stack = 5000
								
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

PERSONA.Dialogue = {
	[1] = {
		Dialogue = "Hey man, what can I do for you?",
		Responses = {
			{ "You got anything for sale?", Type = {"Shop"} },
			{ "Who are you?", Type = {"Response", 2}},
			{ "Nope, gotta go.", Type = {"EndDialogue"} }
		}
	},
	
 	[2] = {
		Dialogue = "The name is Riddick. I handle sales of the resources you can gather in the valley.",
		Responses = {
			{ "Oh, I see. Where are you from?", Type = {"Response", 3} },
			{ "Resources?", Type = {"Response", 3} },
			{ "Nice to meet you Riddick, but...", Type = {"Redirect", 1, "What's wrong?"} }
		}
	},
	[3] = {
		Dialogue = "New? Resources run everything here in the Valley. It's essentially a gold rush. With all the money to be made here it has attracted unwanted folks too.",
		Responses = {
			{[[Who are these "folks" you speak of?]], Type = {"Response", 4} },
			{"What kind of resources are we talking about?", Type = {"Response", 7} },
			{ "I see.", Type = {"Redirect", 1, "Yep, anything I can do for you?"} }
		}
	},
	[4] = {
		Dialogue = "You've got a lot of questions... I like to think the area has made people mad. The population is generally made up of people like me, nomads and faction members.",
		Responses = {
			{"Factions? This sounds more like a war zone than anything...", Type = {"Response", 5} },
			{ "I see.", Type = {"Redirect", 1, "Yep, anything I can do for you?"} }
		}
	},
	[5] = {
		Dialogue = "People gather together and try to capture some key territories in the area. Factions. Greed runs these parts. Don't like it? Go on home.",
		Responses = {
			{"I'm not complaining, money is money, whether or not it has blood on it.", Type = {"Redirect", 1, "Ain't that the truth brotha! Anything I can do for you?"}},
			{"How can I join one of these factions?", Type = {"Response", 6} },
			{ "I see.", Type = {"Redirect", 1, "Yep, anything I can do for you?"} }
		}
	},
	[6] = {
		Dialogue = "You can find the leader and try to speak to him yourself, or someone with the ability to add you to the group. Or, if you're special(VIP) you can make your own.",
		Responses = {
			{"Oh, I see.", Type = {"Redirect", 1, "Yup, anything else?"}}
		}
	},
	[7] = {
		Dialogue = "Crude oil, iron, copper, any type of ore, really. You can get them through mining, using mining machines to dig up the earth or finding one of those big oil rigs around here.",
		Responses = {
			{"Mining machines?", Type = {"Redirect", 8, "Yeah, they take a bit of materials and a tech savy brain to create but they're definitely worth it." } },
			{"Oil rigs?", Type = {"Redirect", 8, "Yep, they're in key areas. They were left here a while ago. It's dangerous to try to use them though, they're usually hot spots and found in territories."} },
			{"Mining? Like by hand?", Type = {"Redirect", 8, "Yes sir, good old hard work. If you have a good pick I'm sure you can get the job done easily. Dietrich should be able to hook you up with some good tools."} },
			{ "I see.", Type = {"Redirect", 1, "Yep, anything I can do for you?"} }
		}
	},
	[8] = {
		Dialogue = "",
		Responses = {
			{"Many ways of making money out here, I see.", Type = {"Redirect", 1, "Yep, this is the new land of opportunity."} },
			{"What was that other stuff again?", Type = {"Redirect", 7, "Gathering you mean?"} }
		}
	}
}

RegisterPersona(PERSONA)