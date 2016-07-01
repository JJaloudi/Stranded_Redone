local ITEM = {}

ITEM.ID = 4
ITEM.Price = 5

ITEM.DefaultStack = 1
ITEM.Stack = true


ITEM.Name = "Chinese Food"

ITEM.Description = "Some leftover chinese food.  Hope it's not rotten..."
ITEM.Category = "Consumable"
ITEM.Model = "models/props_junk/garbage_takeoutcarton001a.mdl"

ITEM.CraftData = {
	Category = "Food",
	Table = {[1] = 100000}
}

ITEM.Actions = {
	[1] = { Name = "Eat", 
	Use = function(user, bag, slot) 
		local ref = bag.Inventory[slot]
		PrintTable(ref)
		local data = ref[2]
		
		user:EmitSound("vo/npc/male01/nice.wav")
		user:SetHunger(100)
		bag:RemoveSlot(slot)
		
		if data[2] == 1 then
			user:EmitSound("vo/npc/male01/moan02.wav")
			user:ConCommand("say Oh god, I think I'm sick...")
		end
	end }
}

ITEM.Use = "Eat"

ITEM.Attributes = {
	[1] = {
		Name = "Consumed", 
		Display = "Food Remaining",
		Moddable = false,
		value = 50,
		max = 50,
		display = true
	},
	[2] = {
		Name = "Rotten",
		Display = "Rotten?",
		Moddable = true,
		value = false,
		display = true
	}
}

RegisterItem(ITEM)