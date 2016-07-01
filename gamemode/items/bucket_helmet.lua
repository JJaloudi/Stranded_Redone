local ITEM = {}

ITEM.Price = 10
ITEM.ID = 1002
ITEM.Name = "Bucket Helmet"

ITEM.Description = "The most basic form of armor... Jesus Christ, I don't want to wear this."
ITEM.Category = "Apparel"
ITEM.Model = "models/props_junk/MetalBucket01a.mdl"

ITEM.CraftData = {
	Category = "Armor",
	Table = {[8001] = 200}
}

ITEM.ApparelData = {
	Type = "Head",
	vecOffset = Vector(0,1,-5),
	angOffset = Vector(0,-90,90),
	Scale = 0.75
}


ITEM.Actions = {
}

ITEM.Attributes = {
}

RegisterItem(ITEM)