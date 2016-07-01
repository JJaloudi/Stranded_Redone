GM.Name = "Stranded Redone"
GM.Author = "Jayzor" 

MAX_SLOTS = 3
VIP_SLOTS = 2

MAX_LAYERS = 25

DEFAULT_SLOTS = 35

FLAG_INV = 1
FLAG_BANK = 2
FLAG_TERRITORY = 3
FLAG_LEADER = 4

FLAG_DESC = { 
	[FLAG_INV] = "Inventory Access",
	[FLAG_BANK] = "Bank Access", 
	[FLAG_TERRITORY] = "Territory Access",
	[FLAG_LEADER] = "Faction Control"
}

FLAGS = {
"LEADER",
"INVENTORY",
"BANK"
}

FAC_COST = 20000
FAC_SLOT_COST = 1000
FAC_DEFAULT_SLOTS = 20
FAC_MAX_SLOTS = 30

FAC_POWER_SCALE = 0.01

TERRITORIES = {

	["rp_cscdesert_v2-1"] = {
		["Sandyville"] = {StartPos = Vector(5102.888672, -7699.120117, 64.031250), EndPos = Vector(958.208801, -9877.705078, 500.911102), SafeZone = true},
		["Rusty's Garage"] = {StartPos = Vector(-8089.329102, -10059,.463867, -15), EndPos = Vector(-6246.528809, -8260.517578, 64.031250), Reward = 500, Pay = 75}
	--	["Sandyville Gas Station"] = {Pos = Vector(-1146, 6918, 568), Radius = 1500, Reward = 750, Pay = 150},
	--	["Western Checkpoint"] = {Pos = Vector(-15, -14066, 80), Radius = 2000, Reward = 2500, Pay = 750}
	},
	["rp_rashkinsk"] = {
		["Southern Checkpoint"] = {StartPos = Vector(-9123.416992, -11185.968750, 0.031250), EndPos = Vector(-1905.208984, -9332.031250, 500.031250), Reward = 2500, Pay = 750},
		["Central Hub"] = {StartPos = Vector(-15232.735352, -9390.055664, 0.031250), EndPos = Vector(-9851.031250, -6069.861328, 500.031250), SafeZone = true},
		["Old Military Hangars"] = {StartPos = Vector(-15743.998047, 1925.031250, 0.031250), EndPos = Vector(-11492.094727, 5000.998047, 500.031250), Reward = 5000, Pay = 1500}
	},
	["gm_construct"] = {
		["Central Hub"] = {StartPos = Vector(200.859192, -966.166382, -79.968750), EndPos = Vector(1839.968750, -2257.714844, 2000.968750), SafeZone = true}
 	},
	["gm_valley"] = {
	
		["Waterfront"] = {StartPos = Vector(6904.2568359375, -14334.162109375, 0.03125), EndPos = Vector(-3953.3190917969, -12390.043945313, 903.00537109375), SafeZone = true},
		["Dr. Maddox's Tree of Madness"] = {StartPos = Vector(-2741.3649902344, -9834.576171875, 54.405410766602), EndPos = Vector(-1917.2619628906, -10655.080078125, 665.6184387207), SafeZone = true},
		["Dietrich's House"] = {StartPos = Vector(4536.5947265625, -11836.009765625, 68.029693603516), EndPos = Vector(5502.693359375, -11324.181640625, 482.21658325195), SafeZone = true},
		
		
		["The Communication Center"] = {StartPos = Vector(-7324.6870117188, -12493.399414063, -88.89582824707), EndPos = Vector(-10592.734375, -15318.701171875, 1280.03125)},
		["Training Post"] = {StartPos = Vector(-10588.852539063, -3952.3247070313, -549.08239746094), EndPos = Vector(-13237.078125, -7046.8383789063, 867.75317382813)},
		["Trainyard"] = {StartPos = Vector(-9770.0966796875, 10100.322265625, -1299.2835693359), EndPos = Vector(-5261.3681640625, 7355.6235351563, -287.97137451172)},
		["Construction Yard"] = {StartPos = Vector(-3806.02734375, 1788.0059814453, -2242.1005859375), EndPos = Vector(-6474.931640625, -272.4553527832, 96.453392028809)},
		["Old Farm"] = {StartPos = Vector(1016.2391967773, 10543.857421875, -1310.2828369141), EndPos = Vector(-1334.0106201172, 6456.697265625, 0.96875)},
		["Waterfront Dam"] = {StartPos = Vector(7102.5263671875, -1202.109375, -2291.0671386719), EndPos = Vector(-3567.96875, -4882.9008789063, 1000.068733215332031)},
		["Power Facility"] = {StartPos = Vector(5524.8486328125, -870.48150634766, -2303.96875), EndPos = Vector(7610.4145507813, 1401.7801513672, 300.7661132813)}
	
	}
 	
}

ITEM_NAMES = {

	["Tool"] = {
		[1] = {
			"Shoddy",
			"Rusty"
		},
		[2] = {
			"Decent",
			"Reliable"
		},
		[3] = {
			"Trustworthy",
			"Useful"
		},
		[4] = {
			"Legendary",
			"Ingenious"
		}
	}, 
	
	["Weapon"] = {
		[1] = {
			"Basic",
			"Simple",
			"Dank"
		},
		[2] = {
			"Consistent",
			"Working"
		},
		[3] = {
			"Awesome",
			"Historic",
			"Experienced"
		},
		[4] = {
			"Fabled",
			"Myhtical",
			"Infamous"
		}
	}
	
}

BUFF_DMG = 1
BUFF_ACC = 2
BUFF_FIREDMG = 3

BUFF_SWINGSPEED = 1
BUFF_EFFICIENCY = 2

BUFF_TYPES = {
	["Weapon"] = {
		BuffItem = 5,
		[1] = {
			Name = "Damage",
			Description = "This buff adds damage to the weapon it's attached to.",
			Color = Color(155,0,0,255),
			CommonNames = {
				"Heavy Rounds",
				"Heavy Metal",
				"Stainless Rounds"
			}
		},
		[2] = {
			Name = "Accuracy",
			Description = "This buff makes the weapon it's attached to more accurate.",
			Color = Color(55,55,255,255),
			CommonNames = {
				"Deadeye",
				"Point Blank"
			}
		}
--[[ 		[3] = {
			Name = "Burning Rounds",
			Description = "This buff gives you a chance of lighting someone on fire.",
			Color = Color(255,15,15,255),
			CommonNames = {
				"Fire Hazard",
				"Hothead"
			}
		} ]]
	},
	["Tool"] = {
		BuffItem = 8,
		[1] = {
			Name = "Swing Speed",
			Description = "Decreases time it takes to swing your tool again.",
			Color = Color(0,255,255,255),
			CommonNames = {
				"Lighter Handle",
				"Carbon Fiber Handle" 
			}
		},
		[2] = {
			Name = "Tool Efficiency",
			Description = "Makes your tool better at what it does.",
			Color = Color(55,255,55,255),
			CommonNames = {
				"Workhorse",
				"Mechanical Efficiency",
				"Tool Whisperer"
			}
		}			
	}
}

CraftCategories = {}

team.SetUp(1,"Rebels", Color(255,75,55,255))
team.SetUp(2,"Military", Color(55,0,255,255))

function table.IsEqual(this, that)
    if table.Count(this) ~= table.Count(that) then
        return false
    end

    for k, v in pairs(this) do
        if v ~= that[k] then
            return false
        end
    end
    return true
end

function math.isdec(num)
	return num ~= math.floor(num)
end

ITEMS = {}

function RegisterItem(itemtbl)
	table.insert(ITEMS,itemtbl)
	
	if itemtbl.CraftData then
		if itemtbl.CraftData.Category then
			if !CraftCategories[itemtbl.CraftData.Category] then
				CraftCategories[itemtbl.CraftData.Category] = {itemtbl.ID}
			else
				CraftCategories[itemtbl.CraftData.Category][#CraftCategories[itemtbl.CraftData.Category] + 1] = itemtbl.ID
			end
		end
	end
	
	print(itemtbl.Name .. " was registered in shared tables. ID: "..itemtbl.ID)
end

PROPERTIES = {}

function RegisterProperty(prop)
	table.insert(PROPERTIES, prop)

	print("Registered property "..prop.Name.." into listings!")
end

function ents.IsDoor(ent)
	return string.find(ent:GetClass(), "door")
end

function ents.IsProperty(ent)
	if !ents.IsDoor(ent) then return false end
	
	return ent.PropertyID or false
end
		
function GetEstimatedValue(it)
	if GetItem(it[1]).Category == "Weapon" then
		return GetItem(it[1]).Price + #it[2] * 50
	elseif GetItem(it[1]).Category == "Buff" then
		return GetItem(it[1]).Price + it[2][2] * 10
	end
end

function GetItem(id)
	for k,v in pairs(ITEMS) do
		if v.ID == id then
			return ITEMS[k]
		end
	end
end

function ItemIsValid(id)
	for k,v in pairs(ITEMS) do
		if v.ID == id then
			return true
		end
	end
end

function KeyToAttribute(item,key)
	for k,v in pairs(GetItem(item)) do
		if v.Attributes[key] then
			return v.Attributes[key].Name
		end
	end
end

function AttributeToKey(item, name)
	for k,v in pairs(GetItem(item).Attributes) do
		if v.Name == name then
			return k
		end
	end
end

function IDToName(id)
	for k,v in pairs(ITEMS) do
		if v.ID == id then
			return v.Name
		end
	end
end

SKILLS = {}

function RegisterSkills(skilltbl)
	table.insert(SKILLS,skilltbl)
	
	print(skilltbl.Name .. " was registered. ID: "..skilltbl.ID)
end

QUESTS = {}

function RegisterQuest(qtbl)
	table.insert(QUESTS,qtbl)
	
	print(qtbl.Name .. " was registered. ID: "..qtbl.ID)
end

function SkillExists(id)
	for k,v in pairs(SKILLS) do
		if v.ID == id then
			return true
		end
	end
end

function GetSkill(id)
	for k,v in pairs(SKILLS) do
		if v.ID == id then
			return SKILLS[k]
		end
	end
end
