local ITEM = {}

ITEM.ID = 3

ITEM.Price = 75
ITEM.Name = "Box"

ITEM.CraftData = {
	Category = "Containers",
	Table = {[10] = 300}
}


ITEM.Description = "A small box, I guess I could fit some extra stuff in it."
ITEM.Category = "Container"
ITEM.Model = "models/props_junk/cardboard_box004a_gib01.mdl"

ITEM.Actions = {
	[1] = { Name = "Open", 
	Use = function(user, bag, slot) 
		if bag != user then
			user:Notify("You can only access one container at a time.")
		else
			net.Start("OpenItemContainer")
				net.WriteTable(bag.Inventory[slot][2][1])
				net.WriteEntity(bag)
				net.WriteUInt(slot, 8)
			net.Send(user)
		end
	end }
}

ITEM.Use = "Eat"

ITEM.Attributes = {
	[1] = {
		Name = "Containment", 
		Display = "Containment",
		Moddable = false,
		value = {
			[1] = {}, 
			[2] = {}, 
			[3] = {}
		},
		display = true  
	}
}


RegisterItem(ITEM)