local ITEM = {}

ITEM.Price = 15
ITEM.ID = 21
ITEM.Name = "Lever"

ITEM.DefaultStack = 5
ITEM.Stack = true


ITEM.Description = "A lever, I can use this to craft something."
ITEM.Category = "Material"
ITEM.Model = "models/props_c17/TrapPropeller_Lever.mdl"

ITEM.CraftData = {
	Category = "Craftable Materials",
	Table = {[8001] = 150}
} 

ITEM.Actions = {
}

ITEM.Attributes = {
}

RegisterItem(ITEM)