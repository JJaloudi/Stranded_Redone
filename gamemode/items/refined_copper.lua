local ITEM = {}

ITEM.ID = 8002
ITEM.Price = 25

if SERVER then
	ITEM.Rarity = 60
end

ITEM.Name = "Refined Copper"

ITEM.DefaultStack = 100
ITEM.Stack = true


ITEM.Description = "A piece of refined copper. Useful for crafting."
ITEM.Category = "Material"
ITEM.Model = "models/props_junk/iBeam01a.mdl"

ITEM.Actions = {
}

ITEM.Attributes = {
}

RegisterItem(ITEM)