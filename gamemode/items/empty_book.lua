local ITEM = {}

ITEM.Price = 50
ITEM.ID = 11
ITEM.Name = "Empty Book"

ITEM.Description = "An old book, nothing written inside of it. Perfect for writing my own journal..."
ITEM.Category = "Material"
ITEM.Model = "models/props_lab/bindergraylabel01a.mdl"

ITEM.CraftData = {
	Category = "Craftable Materials",
	Table = {[10] = 1, [13] = 3}
}

ITEM.Actions = {
}

ITEM.Attributes = {
}

RegisterItem(ITEM)