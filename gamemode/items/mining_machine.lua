local ITEM = {}

ITEM.ID = 23
ITEM.Price = 5

ITEM.Name = "Mining Machine"

ITEM.Description = "A machine used to retrieve ore from deep underground. Requires oil to run."
ITEM.Category = "Deployable"
ITEM.Model = "models/props_wasteland/laundry_washer001a.mdl"

ITEM.CraftData = {
	Category = "Deployable",
	Table = {[8001] = 1000}
}

ITEM.DeployData = {Ent = "ent_mining_machine", Offset = Vector(0,0,40)}

ITEM.Actions = {

}

ITEM.Attributes = {
}

RegisterItem(ITEM)