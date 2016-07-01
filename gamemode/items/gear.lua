local ITEM = {}

ITEM.Price = 40
ITEM.ID = 20
ITEM.Name = "Gear"

ITEM.DefaultStack = 5
ITEM.Stack = true


ITEM.Description = "A gear, I could use this to create some sort of contraption."
ITEM.Category = "Material"
ITEM.Model = "models/props_wasteland/gear02.mdl"

ITEM.CraftData = {
	Category = "Craftable Materials",
	Table = {[8001] = 75}
} 

ITEM.Actions = {
}

ITEM.Attributes = {
}

RegisterItem(ITEM)