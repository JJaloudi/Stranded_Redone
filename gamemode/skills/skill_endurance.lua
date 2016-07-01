SKILL = {}

SKILL.Name = "Endurance"

SKILL.Desc = "Your ability to endure large amounts of pain. Each point adds 3 HP."

SKILL.ID = 1

SKILL.Value = 3
SKILL.Max = 15

SKILL.Icon = "endurance.png"
SKILL.Color = Color(255,55,55,255)

SKILL.Perks = {

	[5] = {
		Name = "Metal Man",
		Desc = "Spawn with 10 Armor",
		Type = "ADD_ARMOR",
		Value = 10,
		Level = 5
	}
	
}

RegisterSkills(SKILL)