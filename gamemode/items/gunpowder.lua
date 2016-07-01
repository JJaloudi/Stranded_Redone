local ITEM = {}

ITEM.Price = 50
ITEM.ID = 16
ITEM.Name = "Gun Powder"

ITEM.DefaultStack = 50
ITEM.Stack = true


ITEM.Description = "Explosive used to make gun rounds."
ITEM.Category = "Material"
ITEM.Model = "models/Items/Flare.mdl"

ITEM.CraftData = {
	Category = "Craftable Materials",
	Table = {[17] = 10}
}

ITEM.Actions = {
}

ITEM.Attributes = {
}

RegisterItem(ITEM)