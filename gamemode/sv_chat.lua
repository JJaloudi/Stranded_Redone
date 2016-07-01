AddCSLuaFile("cl_chat.lua")
util.AddNetworkString("OOCChat")
util.AddNetworkString("LOOCChat")
util.AddNetworkString("FactionChat")


CHATCOMMANDS = {}
local chatPrefixes = {
	"!",
	"/"
}

function AddChatCommand(name, func)
	CHATCOMMANDS[string.lower(name)] = func
end

hook.Add("PlayerSay", "ChatCommands",function(pl, text)
	if !table.HasValue(chatPrefixes, string.sub(text, 1, 1)) then return end
	local found = false
	for k,command in pairs(CHATCOMMANDS) do
		print(string.sub(string.lower(text), 2, string.len(k) + 2))
		if string.sub(string.lower(text), 2, string.len(k) + 1) == string.lower(k) then
			local strExplode = string.Explode(" ", string.sub(text, string.len(k) + 3))
			command(pl, strExplode)
			
			found = true
			print("found")
		end
		
		if found then return false end
	end
end)

function OOCSpeak(pl, text)
	net.Start("OOCChat")
		net.WriteEntity(pl)
		net.WriteString(text)
	net.Broadcast()
end
AddChatCommand("/", OOCSpeak)
AddChatCommand("ooc", OOCSpeak)

AddChatCommand("hunger", function(pl, args)
	local amt = tonumber(args[1])
	if type(amt) == "number" then
		pl:SetHunger(amt)
	end
end)