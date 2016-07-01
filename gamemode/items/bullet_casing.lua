local ITEM = {}

ITEM.Price = 25
ITEM.ID = 15
ITEM.Name = "Bullet Casing"

ITEM.DefaultStack = 10
ITEM.Stack = true


ITEM.Description = "A handcrafted bullet casing."
ITEM.Category = "Material"
ITEM.Model = "models/weapons/shell.mdl"

ITEM.CraftData = {
	Category = "Craftable Materials",
	Table = {[10] = 1, [13] = 5},
	Stack = 1
}

ITEM.Actions = {
}

ITEM.Attributes = {
}

RegisterItem(ITEM)