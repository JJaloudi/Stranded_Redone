local ITEM = {}

ITEM.Price = 100
ITEM.ID = 12
ITEM.Name = "Empty Schematic"

ITEM.Description = "An empty schematic paper. I could use this to make my own inventions!"
ITEM.Category = "Material"
ITEM.Model = "models/props_lab/clipboard.mdl"

ITEM.CraftData = {
	Category = "Craftable Materials",
	Table = {[11] = 3}
}


ITEM.Actions = {
}

ITEM.Attributes = {
}

RegisterItem(ITEM)