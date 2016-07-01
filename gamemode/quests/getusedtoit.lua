QUEST = {}

QUEST.ID = 1
QUEST.Name = "Get Used To It!"
QUEST.Description = "I just met a young lady named Nikki, she runks the junk shop.  She gave me a list of places I should go check out.\nI need to go to the hospital and meet Doctor Maddox. He'll be able to give me all the medical supplies I can pay for.\nShe also told me to go see the Northern Border so I know\nwhere to go when \nI'm ready to head\ninto the Badlands."	

QUEST.Objectives = {
	{"Waypoint", "Discover The Hospital", Vector(-14769.298828, -7995.855957, 128.031250),
		OnEnter = function(pl)
			pl:Notify("This is the hospital. You can come here to replenish health and buy medical supplies.")
		end, Complete = 1
	},
	{"Dialogue", "Introduce yourself to Dr. Maddox", 1, Complete = 1, Required = {1}},
	
	{"Waypoint", "Find The Northern Border", Vector(-14138.333984, -4779.901855, 128.031250),
		OnEnter = function(pl)
			pl:Notify("Beyond this point is where all the looting and combat happens. You're never safe as long as you're beyond the Hub's borders.")
		end, Complete = 1, Required = {1}
	},
	
	{"Dialogue", "Talk to Nikki", 1, Complete = 1, Required = {1, 2, 3}}
}

if SERVER then	
	QUEST.OnCompleted = function(pl)
		pl:Notify("You're now done with the tutorial! Enjoy.")
		
		pl:AddMoney(500)
		pl:AddExp(250)
	end
end

RegisterQuest(QUEST)