include("vgui/cl_bag_panel.lua")
include("vgui/cl_item.lua")
include("vgui/cl_frame.lua")
include("vgui/cl_crafting.lua")
include("vgui/cl_button.lua")
include("vgui/cl_buttonh.lua")
include("vgui/cl_item_button.lua")
include('vgui/cl_option_list.lua')
include('vgui/cl_toggle.lua')
include('vgui/cl_dialogue_button.lua')
include('vgui/cl_shop_panel.lua')
include('vgui/cl_upgrade_panel.lua')
include('vgui/cl_machine_panel.lua')
include('vgui/cl_pda_buttons.lua')
include('vgui/cl_shop_button.lua')
include('vgui/cl_emblem_creator.lua')
include('vgui/cl_emblem.lua')

include('shared.lua')

include('cl_dialogue.lua')
include('cl_network.lua')
include('cl_team.lua')
include('cl_squad.lua')
include('cl_notification.lua')
include('cl_interact.lua')
include('cl_inventory.lua') 
include('cl_skills.lua')
include('cl_upgrades.lua')
include("cl_factions.lua")
include("cl_quests.lua")
include('cl_shop.lua')
include('cl_chat.lua')

include('apparel_system/cl_init.lua')
include('apparel_system/shared.lua')

include('char_creation/cl_init.lua')
include('char_creation/shared.lua')

surface.CreateFont( "Inventory", 
                    {
                    font    = "Roboto-Light",
                    size    = 20,
                    weight  = 1000,
                    antialias = true,
                    shadow = false
            })
			
			surface.CreateFont( "InventorySmall", 
                    {
                    font    = "Roboto-Light",
                    size    = 12,
                    weight  = 1000,
                    antialias = true,
                    shadow = false
            })
			
			surface.CreateFont( "QuestDescription", 
                    {
                    font    = "Roboto-Light",
                    size    = 17,
                    weight  = 1000,
                    antialias = true,
                    shadow = false
            })

canInteract = true

OPEN_PANELS = {}

hook.Add("Think","PreventPanel",function()
	if InfoPanel then
		if InfoPanel.Owner then
			if !InfoPanel.Owner:Valid() then
				if InfoPanel:Valid() then
					InfoPanel:Remove()
				end
				InfoPanel = nil
			end
		else
			if InfoPanel:Valid() then
				InfoPanel:Remove()
			end
		end
	end
end)

function AddPanel(ref)
	local id = #OPEN_PANELS + 1
	OPEN_PANELS[id] = ref
	
	return id
end

function RemovePanel(ref)
	for k,v in pairs(OPEN_PANELS) do
		if v == ref then
			OPEN_PANELS[k] = nil
		end
	end
end

function CloseAllPanels()
	for k,v in pairs(OPEN_PANELS) do
		v:Close()
	end
end

//Save this: maxWidth * value / maxValue

local path = GM.FolderName 
files, dir = file.Find(path.."/gamemode/skills/*","LUA")
for k,v in pairs(files) do
	include("skills/"..v)
end

files, dir = file.Find(path.."/gamemode/items/*","LUA")
for k,v in pairs(files) do
	include("items/"..v)
end

files, dir = file.Find(path.."/gamemode/quests/*","LUA")
for k,v in pairs(files) do
	include("quests/"..v)
end

files, dir = file.Find(path.."/gamemode/properties/*","LUA")
for k,v in pairs(files) do
	include("properties/"..v)
end

local rEle = {"CHudHealth","CHudBattery","CHudSuitPower","CHudAmmo","CHudCrosshair","CHudSecondaryAmmo"}
hook.Add("HUDShouldDraw","Remove Elements",function(ele)
	if table.HasValue(rEle,ele) then
		return false
	end
end)

Skills = {}

for k,v in pairs(SKILLS) do
	Skills[v.ID] = 0 
end

_Inventory = {}
for i = 1, DEFAULT_SLOTS do
	_Inventory[i] = {}
end

net.Receive("SendPlayerInv",function()
	_Inventory = net.ReadTable()
	
	print("Client Inventory Loaded")
end)

concommand.Add("testclient",function()
	PrintTable(_Inventory)
end)

net.Receive("UpdateSlot",function()
	local slot = net.ReadUInt(8)
	local item = net.ReadTable()
		
	_Inventory[slot] = item
	
	if pInventory then
		if pInventory:Valid() then
			pInventory:DoLoad({Items = _Inventory, Ent = LocalPlayer()})
		end
	end
end)

_Location = "Badlands"

net.Receive("UpdateLocation",function()
	_Location = net.ReadString()
	local locOwner = net.ReadString()
	if locOwner == "Disabled/Unowned" then
		_LocationOwner = false
	else
		_LocationOwner = locOwner
	end
	
	print(_LocationOwner)
end)

GAME_MAIN = Color(95,95,95,255)
GAME_SECOND = Color(55,55,55,255)
GAME_OUTLINE = color_white
Exp = 100
DoFocus = false
local oldHP = 100
local oldAR = 100
hook.Add("HUDPaint","Render Hud",function()
	if _Location != "Badlands" then
		draw.SimpleTextOutlined(_Location, "Inventory", ScrW()/2, 0,Color(155,155,155,255), TEXT_ALIGN_CENTER,nil, 1, color_black)
		if TERRITORIES[string.lower(game.GetMap())][_Location].SafeZone then
			draw.SimpleText("This territory is a safe zone", "InventorySmall", ScrW()/2, 20,color_white, TEXT_ALIGN_CENTER)
		else
			if !_LocationOwner then
 				draw.SimpleText("This territory is unclaimed", "InventorySmall", ScrW()/2, 20,color_white, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText("Controlled by ".._LocationOwner, "InventorySmall", ScrW()/2, 20,color_white, TEXT_ALIGN_CENTER)
			end
		end
	end

	local stam_x, stam_y = 10,10
	
	draw.RoundedBoxEx(1,stam_x,stam_y, 175, 30, GAME_MAIN)
	draw.RoundedBoxEx(1,stam_x,stam_y, 175 * math.Clamp(Stamina,0,100) / 100, 30, Color(55,55,255,255))
	surface.SetDrawColor(GAME_OUTLINE)
	surface.DrawOutlinedRect(stam_x,stam_y, 175,30)
	draw.SimpleText("Stamina","Default", stam_x + 87.5, stam_y + 12.5,GAME_OUTLINE,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	
	local hung_x, hung_y = 10,45
	
	draw.RoundedBoxEx(1,hung_x,hung_y, 175, 30, GAME_MAIN)
	draw.RoundedBoxEx(1,hung_x,hung_y, 175 * math.Clamp(Hunger,0,100) / 100, 30, Color(55,155,55,255))
	surface.SetDrawColor(GAME_OUTLINE)
	surface.DrawOutlinedRect(hung_x,hung_y, 175,30)
	draw.SimpleText("Hunger","Default", hung_x + 87.5, hung_y + 12.5,GAME_OUTLINE,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	
	draw.RoundedBoxEx(1,hung_x,hung_y + 35, 175, 30,  GAME_MAIN)
	draw.RoundedBoxEx(1,hung_x,hung_y + 35, 175 * Exp / (Level * 200), 30, Color(150,150,55,255))
	surface.SetDrawColor(GAME_OUTLINE)
	surface.DrawOutlinedRect(hung_x,hung_y + 35, 175,30)
	draw.SimpleText("Level: "..Level.." | Exp: "..Exp.."/"..Level * 200,"Default",hung_x + 87.5,hung_y + 50, color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	
	if DoFocus then
		draw.RoundedBoxEx(1,0,0, ScrW(), ScrH(), Color(0,0,0, 235))
	end
end)

function Notify(str)
	notification.AddLegacy( str, NOTIFY_GENERIC, 5 )
	surface.PlaySound( "buttons/button15.wav" )
end


--[[ net.Receive("OpenItemContainer",function()
	OpenBag(net.ReadTable(), net.ReadEntity(), net.ReadUInt(8))
end) ]]

surface.CreateFont( "No", 
                    {
                    font    = "Roboto-Light",
                    size    = 40,
                    weight  = 1000,
                    antialias = true,
                    shadow = false
            })

hook.Add("HUDPaint","Change your res!", function()
	if ScrW() <= 800 && ScrH() <= 600 then
		draw.RoundedBoxEx(1,0,0,ScrW(),ScrH(),color_black)
		draw.SimpleText("CHANGE YOUR RESOLUTION TO SOMETHING HIGHER!!!", "No", ScrW()/2, ScrH()/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		draw.SimpleText("THIS GAMEMODE DOESN'T SUPPORT RESOLUTIONS 800x600 OR LOWER!", "No", ScrW()/2, ScrH()/2+20, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
end)

bagOpen = false
isInventory = false


concommand.Add("getlocation",function()
	local pl = LocalPlayer()
	local x,y,z = pl:GetPos().x, pl:GetPos().y, pl:GetPos().z
	print("Vector("..x..","..y..","..z..")")
end)

surface.CreateFont( "Crafting", 
                    {
                    font    = "Roboto-Light",
                    size    = ScreenScale(5.9),
                    weight  = 1000,
                    antialias = true,
                    shadow = false
            })
			

MAP_VIEWS = {
	["rp_cscdesert_v2-1"] = {
		[1] = {
			Begin ={Vec = Vector(4897, -8664, 500)},
			End = {Vec = Vector(3854, -8664, 500)},
			Angles = Angle(9.000758, -172.619659, 0.00000)
		},
		[2] = {
			Begin = {Vec = Vector(101, -9748, 636)},
			End = {Vec = Vector(1035, -9131, 636)},
			Angles = Angle(19.437262, 31.010828, 0.000000)
		}
	},
	["rp_rashkinsk"] = {
		[1] = {
			Begin = {Vec = Vector(-1480.973267, 9855.332031, 300.031250)},
			End = {Vec = Vector(-3868.041260, 9855.782227, 300.031250)},
			Angles = Angle(-2, 180, 0)
		}
	}
}
--[[ 
local activeView = 1 
local startPoint = MAP_VIEWS[game.GetMap()][activeView]
local xB, yB, zB = startPoint.Begin.Vec.x, startPoint.Begin.Vec.y, startPoint.Begin.Vec.z

hook.Add("CalcView", "Intro Effect", function(pl, pos, angles, fov)
--[[ 	if !CharID then
		local view = {} 
		xB, yB = math.Approach(xB, startPoint.End.Vec.x, 1), math.Approach(yB, startPoint.End.Vec.y, 1)
		view.origin = Vector(xB, yB, zB)
		view.angles = startPoint.Angles
		view.fov = fov
			
		if view.origin:Distance(startPoint.End.Vec) <= 5 then
			print("YER")
			if activeView + 1 <= table.Count(MAP_VIEWS[game.GetMap()]) then
				activeView = activeView + 1
				startPoint = MAP_VIEWS[game.GetMap()][activeView]
				xB, yB, zB = startPoint.Begin.Vec.x, startPoint.Begin.Vec.y, startPoint.Begin.Vec.z
			else
				activeView = 1
				startPoint = MAP_VIEWS[game.GetMap()][activeView]
				xB, yB, zB = startPoint.Begin.Vec.x, startPoint.Begin.Vec.y, startPoint.Begin.Vec.z
			end
		end
		
		return view	
	end
end) ]]  
	
GhostItem = false
local curRot = 0
net.Receive("StartGhosting", function()
	GhostItem = net.ReadUInt(16)
	
	print("yea")
	
	GhostModel = ClientsideModel(GetItem(GhostItem).Model)
	GhostModel:SetRenderMode(RENDERMODE_TRANSALPHA)
	GhostModel:SetColor(Color(255, 255, 255, 200))
	
	curRot = 0
	
end)
local isSent = false
net.Receive("EndGhosting",function()
	if GhostModel && GhostItem then
		GhostModel:Remove()
		GhostItem = false
		GhostModel = nil
	end
	isSent = false
end)

local lastRot = CurTime()
hook.Add("Think", "DoDeployable",function()
	if !GhostModel && !GhostItem then return end
	local user = LocalPlayer() 
	
	if lastRot <= CurTime() then
		if input.IsKeyDown(KEY_E) then	
			if curRot + 1 < 180 then
				curRot = curRot + 2
			else
				curRot = -180
			end
		
			lastRot = CurTime() + 0.001
		elseif input.IsKeyDown(KEY_Q) then
			if curRot - 1 > -180 then
				curRot = curRot - 2
			else
				curRot = 180
			end
		
			lastRot = CurTime() + 0.001
		end
	end
	
	local tr = util.TraceLine( {
			start = user:GetShootPos() ,
			endpos = user:GetShootPos() + (user:GetForward() * 100),
			filter = function(ent) if ent != user then return true end end
		} )
	
	local endPoint = util.TraceLine( {
			start = tr.HitPos ,
			endpos = tr.HitPos - Vector(0,0,90),
			filter = function(ent) if ent != user then return true end end
		} )
	
	GhostModel:SetPos(endPoint.HitPos + GetItem(GhostItem).DeployData.Offset)
	local p, y, r = user:GetAngles().p, user:GetAngles().y, user:GetAngles().r
	GhostModel:SetAngles(Angle(0, y + curRot, 0))
	
	if !isSent then
		if input.IsMouseDown(MOUSE_LEFT) then
			net.Start("FinishPlacement")
				net.WriteEntity(user)
				net.WriteUInt(GhostItem, 16)
				net.WriteVector(GhostModel:GetPos())
				net.WriteAngle(GhostModel:GetAngles())
			net.SendToServer()
			
			isSent = true
		elseif input.IsMouseDown(MOUSE_RIGHT) then

		end
	end
end)

concommand.Add("TestEmblem", function()
	local Panel = vgui.Create("EmblemCreator")
	Panel:Center()
	Panel:MakePopup(true)
	
	Panel:LoadData(false)
end)