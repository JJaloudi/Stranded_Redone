local ITEM = {}

ITEM.Price = 5
if SERVER then
	ITEM.Rarity = 30
end

ITEM.ID = 18
ITEM.Name = "9mm Rounds"

ITEM.Stack = true
ITEM.DefaultStack = 15

ITEM.Description = "Individual rounds I can use for any 9mm weapon."
ITEM.Category = "Material"
ITEM.Model = "models/Items/BoxSRounds.mdl"

ITEM.CraftData = {
	Category = "Ammo",
	Table = {[15] = 15, [16] = 30}
} 

ITEM.Actions = {
}

ITEM.Attributes = {
}

RegisterItem(ITEM)