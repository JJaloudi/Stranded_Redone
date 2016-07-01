local ITEM = {}

ITEM.ID = 7
ITEM.Price = 100
ITEM.Rarity = 30

ITEM.Name = "Axe"
ITEM.EntName = "weapon_melee_base"

ITEM.CraftData = {
	Category = "Tools",
	Table = {[10] = 100, [8001] = 300}
}

ITEM.Description = "An axe. I can use this to get wood from trees and defend myself..."
ITEM.Category = "Tool"
ITEM.Model = "models/weapons/w_crowbar.mdl"

ITEM.Actions = {

}

RegisterItem(ITEM)