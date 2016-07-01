local ITEM = {}

ITEM.Price = 10
ITEM.ID = 1001
ITEM.Name = "Box Backpack Test"

ITEM.Description = "A box for a backpack lolz, dis is a test obv"
ITEM.Category = "Apparel"
ITEM.Model = "models/items/item_item_crate.mdl"

ITEM.CraftData = {
	Category = "Armor", 
	Table = {[8001] = 200}
}

ITEM.ApparelData = {
	Type = "Back",
	vecOffset = Vector(0,10,2),
	angOffset = Vector(0,0,90),
	Scale = 0.5
}


ITEM.Actions = {
}

ITEM.Attributes = {
}

RegisterItem(ITEM) 