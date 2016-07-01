local ITEM = {}

ITEM.ID = 2
ITEM.DB = "HPVial"
ITEM.Price = 15

ITEM.DefaultStack = 5
ITEM.Stack = true


ITEM.Name = "Health Vial"

ITEM.CraftData = {
	Category = "Medical Supplies",
	Table = {[8001] = 25}
}


ITEM.Description = "A tube filled with green liquid.  Says health vial on it."
ITEM.Category = "Material"
ITEM.Model = "models/healthvial.mdl"

ITEM.Actions = {
}

ITEM.Use = "Heal"

ITEM.Attributes = {
}

RegisterItem(ITEM)