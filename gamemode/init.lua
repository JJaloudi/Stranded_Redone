require( "tmysql4" )

include('items.lua')
include("shared.lua")
include("team_quest.lua")
include("team_data.lua")
include("sv_mechanics.lua")
include("player_meta.lua")
include("resources.lua") 
include("sv_skills.lua")
include("sv_world.lua")
include("sv_factions.lua")
include("sv_quests.lua")
include('sv_chat.lua')
include('dialogue_system.lua')
include('quest_system.lua')
include('dungeon_system.lua')
include('apparel_system/init.lua')
include('apparel_system/shared.lua')
include('char_creation/init.lua')
include('char_creation/shared.lua')

AddCSLuaFile("cl_init.lua")
AddCSLuaFile('apparel_system/cl_init.lua')
AddCSLuaFile('apparel_system/shared.lua')
AddCSLuaFile('char_creation/cl_init.lua')
AddCSLuaFile('char_creation/shared.lua')
AddCSLuaFile('cl_chat.lua')
AddCSLuaFile("cl_quests.lua")
AddCSLuaFile("cl_skills.lua")
AddCSLuaFile("cl_network.lua")
AddCSLuaFile('cl_interact.lua') 
AddCSLuaFile("cl_team.lua")
AddCSLuaFile("shared.lua")  
AddCSLuaFile("cl_notification.lua")
AddCSLuaFile("cl_squad.lua")
AddCSLuaFile("cl_inventory.lua")
AddCSLuaFile("cl_factions.lua")
AddCSLuaFile('cl_upgrades.lua')
AddCSLuaFile('cl_shop.lua')
AddCSLuaFile('cl_dialogue.lua')

AddCSLuaFile("vgui/cl_bag_panel.lua")
AddCSLuaFile("vgui/cl_item.lua")
AddCSLuaFile("vgui/cl_frame.lua")
AddCSLuaFile("vgui/cl_button.lua")
AddCSLuaFile("vgui/cl_buttonh.lua")
AddCSLuaFile("vgui/cl_item_button.lua")
AddCSLuaFile('vgui/cl_option_list.lua')
AddCSLuaFile("vgui/cl_crafting.lua")
AddCSLuaFile('vgui/cl_toggle.lua')
AddCSLuaFile('vgui/cl_shop_panel.lua') 
AddCSLuaFile('vgui/cl_upgrade_panel.lua')
AddCSLuaFile('vgui/cl_machine_panel.lua')
AddCSLuaFile('vgui/cl_dialogue_button.lua')
AddCSLuaFile('vgui/cl_pda_buttons.lua')
AddCSLuaFile('vgui/cl_shop_button.lua')
AddCSLuaFile('vgui/cl_emblem_creator.lua')
AddCSLuaFile('vgui/cl_emblem.lua')

concommand.Add("testspawn", function(pl)
	local pos = pl:GetPos()
	local ent = ents.Create("npc_mutant_base")
	ent:SetPos(pos + pl:GetForward() * 500)
	ent:Spawn()
	
	//ent.PersonaID = 2
	//ent:SetModel(table.Random(PERSONAS[GetPersonaKey(ent.PersonaID)].Models))
end)

local path = GM.FolderName
files, dir = file.Find(path.."/gamemode/skills/*","LUA")
for k,v in pairs(files) do
	include("skills/"..v)
	AddCSLuaFile("skills/"..v)
end

files, dir = file.Find(path.."/gamemode/items/*","LUA")
for k,v in pairs(files) do
	include("items/"..v)
	AddCSLuaFile("items/"..v)
end

files, dir = file.Find(path.."/gamemode/quests/*","LUA")
for k,v in pairs(files) do 
	include("quests/"..v)
	AddCSLuaFile("quests/"..v)
end

files, dir = file.Find(path.."/gamemode/personas/*","LUA")
for k,v in pairs(files) do 
	include("personas/"..v)
end

files, dir = file.Find(path.."/gamemode/properties/*","LUA")
for k,v in pairs(files) do
	include("properties/"..v) 
	AddCSLuaFile("properties/"..v)
end 

concommand.Add("getdoor",function(pl)
	local tr = pl:GetEyeTrace()
	if tr.Entity then
		if string.find(tr.Entity:GetClass(),"door") then
			print(tr.Entity:EntIndex()) 
		else
			print(tr.Entity:GetModel())
		end
	end 
end)

db,err = tmysql.initialize("127.0.0.1","root","llamas11","control",3306)
hook.Add("Initialize","Do SQL",function()
	if db then
		print("[SQL] Database connected, prepared to retrieve information.")
	else
		print("[SQL] ERROR! Couldn't connect to DB!")
		error(err)
	end
	
	err = nil
end) 

--[[ hook.Add("InitPostEntity","Register Doors",function()
	for k,v in pairs(PROPERTIES) do
		for key, door in pairs(v.EntranceDoors) do
			local dr = ents.GetByIndex(door)
			dr.PropertyID = k
			dr.Buyable = false
		end
		for index, tbl in pairs(v.Buyable) do
			for key,door in pairs(tbl.Doors) do
				local dr = ents.GetByIndex(door)
				dr.PropertyID = k
				dr.DoorID = index
				dr.Buyable = true
				dr:Fire("lock")		
			end
		end
	end
end) ]]

