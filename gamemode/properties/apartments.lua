local PROP = {}

PROP.Name = "EvoCity Apartments"
PROP.Description = "The luxorious apartments of EvoCity!"

PROP.EntranceDoors = {229}

PROP.Buyable = {

	[1] = {Name = "Apartment #1",
		Doors = {220,225,224},
		Cost = 150
		},
		
	[2] = {Name = "Apartment #2",
		Doors = {217, 228, 221},
		Cost = 150
	}
	
}


RegisterProperty(PROP)