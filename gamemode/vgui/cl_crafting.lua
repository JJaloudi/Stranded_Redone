local Crafting = {}

function Crafting:Init()
	self:SetDraggable(false)	
	self:SetTitle("")
	self:ShowCloseButton(false)
	
	self.CurrentCategory = "None"
end

function Crafting:Initialize()
	self.List = vgui.Create("DPanelList", self)
	local list = self.List
	list:SetSize(self:GetWide() - 1, 150)
	list:SetPos(0,0)
	list:SetPadding(0)
	list:SetSpacing(-1)
	list:EnableVerticalScrollbar(true)
	
	list.Paint = function(s)
		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(0,0,s:GetWide(), s:GetTall()+1)
	end
	
	for catName,tbl in pairs(CraftCategories) do
	
		local category = vgui.Create("PDAButton")
		category.FillSpeed = 20
		category:SetFillColor(Color(235, 215, 0,255))
		category:SText(catName)
		category:SetSize(list:GetWide() + 1, 25.75)
		
		category.DoClick = function() 
			self:SetActiveCategory(catName)
			
			for k,v in pairs(list:GetItems()) do
				if v.Active then
					v.Active = false
				end
			end
			
			category.Active = true
		end
		
		category.PaintOver = function(s)
			surface.SetDrawColor(color_white)
			surface.DrawLine(0,s:GetTall() - 2, s:GetWide(), s:GetTall() - 2)
		end
		
		list:AddItem(category)		
	end
	
	self.ItemList = vgui.Create("DPanelList", self)
	self.ItemList:SetPos(0, list:GetTall())
	self.ItemList:SetSize(list:GetWide(), self:GetTall() - list:GetTall())
	self.ItemList:EnableVerticalScrollbar(true)
	self.ItemList:SetSpacing(0)
end

function Crafting:SetActiveCategory(catName)
	if self.CurrentCategory != catName then
		self.CurrentCategory = catName
		self.ItemList:Clear()
	
	
		for k,v in pairs(CraftCategories[catName]) do
			local item = GetItem(v)
		
			local iPnl = vgui.Create("DButton")
			iPnl:SetSize(self:GetWide() - 2, 50)	
			iPnl:SetText("")
		
			local descTbl = {}
			
			local count = 0
			for key, val in pairs(item.CraftData.Table) do
				count = count + 1
				local prefix = ""
				if val > 1 then
					prefix = "x"..val.." "
				end
				
				if count != table.Count(item.CraftData.Table) then
					descTbl[count] = prefix .. GetItem(key).Name .. " + "
				else
					descTbl[count] = prefix .. GetItem(key).Name
				end 
			end
			
			local descString = table.concat(descTbl, "")
			
			local desc = vgui.Create("RichText", iPnl)
			desc:SetPos(0, 20)
			desc:SetSize(iPnl:GetWide(), iPnl:GetTall() - 20)
			
			function desc:PerformLayout()
				desc:SetFontInternal("CraftingDesc")
			end
			desc:SetVerticalScrollbarEnabled(false)
			desc:InsertColorChange(235, 215, 0,255)
			desc:AppendText(descString)
			
			iPnl.Paint = function(s)
				draw.RoundedBoxEx(1,0,0,s:GetWide(), s:GetTall(), Color(155,155,155,255))
				draw.SimpleText(item.Name, "Inventory", 3, 0, Color(55,55,55,255), TEXT_ALIGN_LEFT)
				--draw.SimpleText(descString,"CraftingDesc", 3, 20, Color(235, 215, 0,255), TEXT_ALIGN_LEFT)
				
				surface.SetDrawColor(color_white)
				surface.DrawOutlinedRect(0,0,s:GetWide(), s:GetTall())
			end
			
			local overlay = vgui.Create("DButton", iPnl)
			overlay:SetSize(iPnl:GetSize())
			overlay:SetText("")
			overlay.Paint = function() end
			
			overlay.DoClick = function(s)
				net.Start("CraftItem")
					net.WriteEntity(LocalPlayer())
					net.WriteEntity(LocalPlayer())//Bench ent
					net.WriteUInt(v,8)
				net.SendToServer()
			end
			
			self.ItemList:AddItem(iPnl)
		end 
	end
end

function Crafting:Paint()
	draw.RoundedBoxEx(1,0,0,self:GetWide(),self:GetTall(),color_white)
	draw.RoundedBoxEx(1,1.25,1.25,self:GetWide() - 3,self:GetTall() - 3,Color(55,55,55,255))
	
	surface.SetDrawColor(color_white)
	surface.DrawOutlinedRect(0,0,self:GetWide(), self:GetTall())
end

function Crafting:PaintOver()
	surface.SetDrawColor(color_white)
	surface.DrawOutlinedRect(0,0,self:GetWide(), self:GetTall())
end

surface.CreateFont( "CraftingDesc", 
               {
                    font    = "Roboto-Light",
                    size    = 11,
                    weight  = 1000,
                    antialias = true,
                    shadow = false
            })


vgui.Register("DCrafting",Crafting, "DFrame")

concommand.Add("test",function()
	local pnl = vgui.Create("DCrafting")
	pnl:SetPos(ScrW() - pnl:GetWide(), 0)
	
	pnl:SetActiveCategory("Craftable Materials")	
end)