local ITEM = {}

ITEM.ID = 20
ITEM.Price = 5

ITEM.Name = "Control Console"

ITEM.Description = "This console is required to claim a territory. Simply deploy it in an uncontrolled territory and it'll belong to your faction."
ITEM.Category = "Deployable"
ITEM.Model = "models/props_lab/reciever_cart.mdl"

ITEM.CraftData = {
	Category = "Deployable",
	Table = {[8001] = 1000}
}

ITEM.DeployData = {Ent = "ent_control_console", Offset = Vector(0,0,35)}


ITEM.Actions = {

}

ITEM.Attributes = {
}

RegisterItem(ITEM)