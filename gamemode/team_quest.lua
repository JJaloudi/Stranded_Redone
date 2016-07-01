TIME_QUEST = 20
ACTIVE_QUEST = false
--[[ 
function GetQuest()
	if ACTIVE_QUEST then
		return QUESTS[ACTIVE_QUEST]
	end
end
  
function EndQuest(teamwon, pl)

	ACTIVE_QUEST = false
	if teamwon then
		if pl then
			GetQuest.Reward(teamwon, pl)
		else
			GetQuest.Reward(teamwon)
		end
	end
	
	timer.Create("TickDown", 1, 0, function()
		if !ACTIVE_QUEST then
			if TIME_QUEST - 1 <= 0 then
				ACTIVE_QUEST = table.Random(QUESTS)
				GetQuest.Initialize()
				timer.Destroy("TickDown")
				//Network here
			else
				TIME_QUEST = TIME_QUEST - 1
				//Network here
			end
		end
	end)
	
end

timer.Create("TickDown", 1, 0, function()
	if !ACTIVE_QUEST then
		if TIME_QUEST - 1 <= 0 then
			ACTIVE_QUEST = table.Random(QUESTS)
			ACTIVE_QUEST.Initialize()
			timer.Destroy("TickDown")
			//Network here
		else
			TIME_QUEST = TIME_QUEST - 1
			//Network here
		end
	end
end) ]]