local ITEM = {}

ITEM.ID = 29
ITEM.Price = 5

ITEM.Name = "Firing Pit"

ITEM.Description = "A machine used to turn ore into it's refined form. Requires a fuel source to run."
ITEM.Category = "Deployable"
ITEM.Model = "models/props_wasteland/laundry_basket001.mdl"

ITEM.CraftData = {
	Category = "Deployable",
	Table = {[8001] = 1000}
}

ITEM.DeployData = {Ent = "ent_refining_machine", Offset = Vector(0,0,20)}

ITEM.Actions = {

}

ITEM.Attributes = {
}

RegisterItem(ITEM)