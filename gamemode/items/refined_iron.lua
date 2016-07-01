local ITEM = {}

ITEM.ID = 8001
ITEM.Price = 25

if SERVER then
	ITEM.Rarity = 60
end

ITEM.Name = "Refined Iron"

ITEM.DefaultStack = 100
ITEM.Stack = true


ITEM.Description = "A piece of refined iron. Useful for crafting."
ITEM.Category = "Material"
ITEM.Model = "models/gibs/metal_gib4.mdl"

ITEM.Actions = {
}

ITEM.Attributes = {
}

RegisterItem(ITEM) 