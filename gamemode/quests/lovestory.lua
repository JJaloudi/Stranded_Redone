QUEST = {}

QUEST.ID = 2
QUEST.Name = "Love Story"
QUEST.Description = "Riddick has a crush on Nikki. He wants me to talk to her for him, guess he doesn't have the balls to do it himself. Pfffft.\n\nGetting a free gun out of it, so why not?"

QUEST.Objectives = {
	{"Dialogue", "Tell Nikki what Riddick said", 1, Complete = 1}
}

if SERVER then	
	QUEST.OnCompleted = function(pl)
	end
end

RegisterQuest(QUEST)