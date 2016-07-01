local ITEM = {}

ITEM.Price = 25
ITEM.ID = 13
ITEM.Name = "Empty Paper"

ITEM.DefaultStack = 1
ITEM.Stack = true


ITEM.Description = "A paper that hasn't been written on."
ITEM.Category = "Material"
ITEM.Model = "models/props_c17/paper01.mdl"

ITEM.CraftData = {
	Category = "Craftable Materials",
	Table = {[9] = 100},
	Stack = 1
}


ITEM.Actions = {
}

ITEM.Attributes = {
}

RegisterItem(ITEM)