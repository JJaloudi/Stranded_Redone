local ITEM = {}

ITEM.ID = 8
ITEM.Price = 400

ITEM.Name = "Tool Buff"
ITEM.BuffType = "Tool"

ITEM.Description = "This is a schematic to increase efficiency in a tool. Place this in your tool's upgrade slots to use it's effect. ALL BUFFS ARE PERMANENT!"
ITEM.Category = "Buff"
ITEM.Model = "models/props_lab/binderbluelabel.mdl"

ITEM.CraftData = {
	Category = "Tools",
	Table = {[11] = 1, [12] = 1}
}


ITEM.Actions = {
}

ITEM.Attributes = {

	[1] = {
		Name = "CustomName",
		Display = "Custom Buff Name",
		Moddable = true,
		value = "Custom Name"
	},
	
	[2] = {
		Name = "BuffType", 
		Display = "Buff Type",
		Moddable = false,
		value = 1,
		max = #BUFF_TYPES
	},
	
	[3] = {
		Name = "BuffAmt", 
		Display = "Buff Effect",
		Moddable = false,
		value = 5,
		max = 100
	}
	
}

RegisterItem(ITEM)