local ITEM = {}

ITEM.Price = 250
ITEM.ID = 19
ITEM.Name = "Engine"

ITEM.Description = "An old engine. I could use this to power a machine... or car?"
ITEM.Category = "Machines"
ITEM.Model = "models/props_c17/trappropeller_engine.mdl"

ITEM.CraftData = {
	Category = "Machines",
	Table = {[8001] = 1000, [20] = 2, [21] = 1} 
} 

ITEM.Actions = {
}

ITEM.Attributes = {
}

RegisterItem(ITEM)