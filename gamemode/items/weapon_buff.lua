local ITEM = {}

ITEM.ID = 5
ITEM.Price = 500

ITEM.Name = "Weapon Buff"
ITEM.BuffType = "Weapon"

ITEM.Description = "This is a schematic to increase efficiency in a weapon. Place this in your weapons upgrade slots to use it's effect. ALL BUFFS ARE PERMANENT!"
ITEM.Category = "Buff"
ITEM.Model = "models/props_lab/binderredlabel.mdl"

ITEM.CraftData = {
	Category = "Weapons",
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