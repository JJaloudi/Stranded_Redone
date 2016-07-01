local ITEM = {}

ITEM.ID = 10
ITEM.Price = 15

ITEM.DefaultStack = 10
ITEM.Stack = true


ITEM.Name = "Wooden Planks"

ITEM.Description = "Wooden planks, should come in handy for crafting."
ITEM.Category = "Material"
ITEM.Model = "models/props_debris/wood_board06a.mdl"

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