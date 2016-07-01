local ITEM = {}

ITEM.ID = 8003
ITEM.Price = 15

if SERVER then
	ITEM.Rarity = 80
end

ITEM.DefaultStack = 100
ITEM.Stack = true


ITEM.Name = "Refined oil"

ITEM.Description = "A power source, that's very valuable. I can use this to power machines too."
ITEM.Category = "Resource"
ITEM.Model = "models/props_junk/gascan001a.mdl"

ITEM.CraftData = {
	Category = "Craftable Materials",
	Table = {[9] = 100},
	Stack = 10
}


ITEM.Actions = {
}

ITEM.Attributes = {
}

RegisterItem(ITEM)