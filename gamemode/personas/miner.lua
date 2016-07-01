PERSONA = {}

PERSONA.ID = 2
PERSONA.Name = "Miner"

PERSONA.Type = "Nomad"
PERSONA.Ent = "npc_miner"
PERSONA.Models = { "models/humans/group01/female_01.mdl"}
	
PERSONA.StartingWorth = 0

PERSONA.Dialogue = {
	[1] = {
		Dialogue = "What can I do you for?",
		Responses = {
			{ "You willing to barter some of those supplies?", Type = {"Shop"} },
			{ "What're you doing out here?", Type = {"EndDialogue", 2} },
			{ "See you later.", Type = {"EndDialogue"} }
		}
	}
}

RegisterPersona(PERSONA)