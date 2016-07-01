local dData = {} //Current dialogue data stored here
local dPanel = false //Variable where the panel is stored
local bFocusNPC = false // Focus on NPC?
local pCaption = false

local function OpenDialogue()
	local base = vgui.Create("DFrame")
	base:SetSize(ScrW()/2.5, 100)
	base:SetPos(ScrW()/2 - base:GetWide()/2, ScrH() - base:GetTall() - 10)
	base:MakePopup()
	base:ShowCloseButton(false)
	base:SetTitle("")
	base:SetDraggable(false)
	
	local responseList = vgui.Create("DPanelList", base)
	responseList:SetSize(base:GetWide() - 10, base:GetTall() - 10)
	responseList:SetPos(5, 5)
	responseList:EnableVerticalScrollbar(true)
	
	for k,v in pairs(dData.Responses) do
		local button = vgui.Create("DialogueButton")
		button:SText(v.Response)
		button:SetSize(responseList:GetWide(), responseList:GetTall()/3)
		button.DoClick = function()
			net.Start("HandleResponse")
				net.WriteEntity(LocalPlayer())
				net.WriteEntity(dData.Ent)
				net.WriteUInt(dData.NPCID, 16)
				net.WriteUInt(dData.DialogueID, 16)
				net.WriteUInt(v.ID, 16)
			net.SendToServer()
		end
		
		responseList:AddItem(button)
	end

	base.Paint = function(s)
		draw.RoundedBoxEx(1,0,0,s:GetWide(), s:GetTall(), Color(55,55,55,105))
	
		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(0,0, s:GetWide(), s:GetTall())
	end

	return base
end

local function ToggleFocus(b)
	bFocusNPC = b or !bFocusNPC
	if bFocusNPC then
		if !pCaption then
			pCaption = vgui.Create("RichText")		
			function pCaption:PerformLayout()
				pCaption:SetFontInternal( "Inventory" )
			end
			pCaption:SetVerticalScrollbarEnabled(false)
			
			pCaption:SetSize(ScrW()/2.5, 75)
			pCaption:SetPos(ScrW()/2 - pCaption:GetWide()/2, ScrH() - pCaption:GetTall() - 10)
			
			pCaption:InsertColorChange(55, 155, 55, 255)
			pCaption:AppendText(dData.NPCName .. ": ")
			
			pCaption:InsertColorChange(255, 255, 255, 255)
			pCaption:AppendText(dData.DialogueLine)
			
			pCaption.Paint = function(s)
				
			end
		end
		
		if dPanel then
			if dPanel:IsValid() then
				dPanel:Close() 
				dPanel = false
			end
		end
	else 
		if !dPanel then
			dPanel = OpenDialogue()
		end
		
		if pCaption then
			local x,y = dPanel:GetPos()
			pCaption:SetPos((x + dPanel:GetWide()/2) - pCaption:GetWide()/2 + 15, y - pCaption:GetTall())
		end
	end
end

net.Receive("StartDialogue",function()
	local npcEnt = net.ReadEntity()
	local npcName = net.ReadString()
	local npcID = net.ReadUInt(16)
	local diagID = net.ReadUInt(16)
	local greetString = net.ReadString()
	local responseTbl = net.ReadTable()
	local camData = net.ReadTable()
	
	dData = {NPCName = npcName,Ent = npcEnt, NPCID = npcID, DialogueID = diagID, DialogueLine = greetString, Responses = responseTbl, CamData = camData}
	
	ToggleFocus(true)
	
	timer.Simple(math.Clamp(string.len(dData.DialogueLine) * .25, 3, 8), function()
		if bFocusNPC then
			ToggleFocus(false)
		end
	end)
end) 

net.Receive("EndDialogue", function()
	if dPanel then
		if dPanel:IsValid() then
			dPanel:Close()
		end
	end
	
	if pCaption then
		if pCaption:IsValid() then
			pCaption:Remove()
		end
	end
	
	dPanel = false
	pCaption = false
	bFocusNPC = false
	dData = nil
end)

net.Receive("UpdateDialogue",function()
	if dPanel then
		if dPanel:IsValid() then
			dPanel:Close()
		end
	end
	
	if pCaption then
		if pCaption:IsValid() then
			pCaption:Remove()
		end
	end
	
	dPanel = false
	pCaption = false
	
	dData.DialogueID = net.ReadUInt(16)
	dData.DialogueLine = net.ReadString()
	dData.Responses = net.ReadTable()
	dData.CamData = net.ReadTable()
	
	ToggleFocus(true)
	
	timer.Simple(math.Clamp(string.len(dData.DialogueLine) * .25, 3, 8), function()
		if bFocusNPC then
			ToggleFocus(false)
		end
	end)
end)

hook.Add("CalcView", "HandleCamView", function(pl, vec, ang, fov)

	if bFocusNPC then
		if dData then
			if dData.CamData then
				local camera = {}
				local loc = dData.CamData
				camera.origin = loc.Vec
				camera.angles = loc.Ang
				camera.fov = fov
					
				return camera
			end
		end
	end

end)

--[[ hook.Add( "ShouldDrawLocalPlayer", "MyShouldDrawLocalPlayer", function( ply )
	if !dPanel then return end
	
	return true
end ) ]]

local function HandleSkip(pl, nKey)
	if !bFocusNPC then return end
	ToggleFocus(false)
end
hook.Add("KeyPress", "HandleSkip", HandleSkip)