local ITEM = {}

ITEM.Price = 10
ITEM.ID = 1003
ITEM.Name = "Soviet Tanker Helmet"

ITEM.Description = "An old soviet tanker helmet, I guess they used these back in the old days. In soviet Russia, hat wears you!"
ITEM.Category = "Apparel"
ITEM.Model = "models/kali/miscstuff/soviet_tanker_helmet.mdl"

ITEM.CraftData = {
	Category = "Armor",
	Table = {[8001] = 200}
}

ITEM.ApparelData = {
	Type = "Head",
	vecOffset = Vector(0,1,-70),
	angOffset = Vector(180,-90,90),
	Scale = 1.1
}


ITEM.Actions = {
}

ITEM.Attributes = {
}

RegisterItem(ITEM)