local shopEnt = false
local shopCategories = false
local shopInv = false
local shopWorth = 0

function OpenShopMenu(ent, invTbl, worth)
	local pxOffset = ScrW()/4
	local pnlWidth, pnlHeight = ScrW() / 4.25, ScrH() / 1.8
	local pxSub = 22.5
	worth = worth or 0
	
	local vendorMoney = worth or 0
	local playerMoney = Money
	
	local activeItem = false
	
	local curCategory = "Vendor"
	local invTitle = "My Inventory"
	
	local buyTbl = {} // All highlighted shop items [slot of shop] = {id, amount selected}
	local sellTbl = {} // All inventory items to be sold [slot of inv] = {id, amount selected}
	
	local function CalculateValue(tbl) // Calculate the total cost of all queued items in 'included' table. 
		local curValue = 0
		
		for k,v in pairs(tbl) do
			local it = GetItem(v[1])
			local amt = v[2] or 1
			
			if it then
				curValue = curValue + (it.Price * amt)
			end	
		end
		
		return curValue
	end
	
	local function CalculateCost() // How much is it going to cost? :) (:
		local buyCost = CalculateValue(buyTbl)
		local sellValue = CalculateValue(sellTbl)
		
		return buyCost - sellValue
	end
	
	local function CreateProperInventory(tbl)
		local pTbl = {}
		
		for k,v in pairs(tbl) do
			if v[1] then
				local it = GetItem(v[1])
				if it.Stack then
					local wasStacked = false
					for key, val in pairs(pTbl) do
						if val[1] == v[1] then
							wasStacked = true
							
							val.Stack = val.Stack + v.Stack or 1				
						end
					end
					
					if !wasStacked then
						table.insert(pTbl, {v[1], Stack = v.Stack})
					end
				else
					table.insert(pTbl, {v[1], v})
				end
			end
		end
		
		PrintTable(pTbl)
		table.sort(pTbl, function(a, b) return GetItem(a[1]).Name < GetItem(b[1]).Name end)
		
		return pTbl
	end
	
	local shopPnl = vgui.Create("DFrame")
	shopPnl:MakePopup()
	shopPnl:SetDraggable(false)
	shopPnl:SetSize(pnlWidth, pnlHeight)
	shopPnl:SetTitle("")
	shopPnl:SetPos(pxOffset - pxOffset / 2.5, ScrH() / 2 - shopPnl:GetTall() / 2)
	
	local shopList = vgui.Create("DPanelList", shopPnl)
	shopList:SetSize(shopPnl:GetWide() - 20, shopPnl:GetTall() - (56 + pxSub + 1))
	shopList:SetPos(10, pxSub +  5)
	shopList:EnableVerticalScrollbar(true)
	
	for k,v in pairs(CreateProperInventory(shopInv)) do
		local shopButton = vgui.Create("ShopButton")
		shopButton:SetSize(shopList:GetWide() - 20, shopList:GetTall() / 9)
		shopButton:SetItem(v[1])
		if v.Stack then
			shopButton:SetStack(v.Stack)
		end
		shopButton.OutlineColor = Color(55,205,55,255)
		
		shopButton.DoClick = function(s)
			if !s.IsHighlighted then
				if v.Stack then
					local x,y = shopPnl:GetPos()
--[[ 				shopPnl:MoveTo(-ScrW() - shopPnl:GetWide(),y, 0.25)
					shopPnl:MoveTo(ScrW() + shopPnl:GetWide(),y, 0.25) ]]
				
					local qPanel = vgui.Create("DFrame")
					qPanel:SetSize(400,125)
					qPanel:Center()
					qPanel:MakePopup()
					qPanel:SetTitle("")
					qPanel:ShowCloseButton(false)
					
					local prompt = vgui.Create("RichText", qPanel)
					prompt:SetSize(qPanel:GetWide() - 10, qPanel:GetTall() - 50)
					prompt:SetPos(5, 0)
					prompt:SetVerticalScrollbarEnabled(false)
					
					prompt:InsertColorChange(55,55,55,255)
					prompt:AppendText("How many ")
					
					prompt:InsertColorChange(55, 205, 55, 255)
					prompt:AppendText(GetItem(v[1]).Name)
					
					prompt:InsertColorChange(55,55,55,255)
					prompt:AppendText(" would you like to")
					
					prompt:InsertColorChange(55, 205, 55, 255)
					prompt:AppendText(" buy")
					
					prompt:InsertColorChange(55,55,55,255)
					prompt:AppendText("?")
					 
					function prompt:PerformLayout()

						self:SetFontInternal( "Inventory" )
						self:SetFGColor( Color( 255, 255, 255 ) )

					end
					
					local val = vgui.Create("DNumSlider", qPanel)
					val:SetSize(qPanel:GetWide() + 190, qPanel:GetTall()/6)
					val:SetPos(-200, qPanel:GetTall()/2 - val:GetTall())
					val:SetMinMax(1, v.Stack)
					val:SetDecimals(0)
					val:SetValue(1)
					
					local acc = vgui.Create("cButton", qPanel)
					acc:SetSize(qPanel:GetWide()/3, 25)
					acc:SetPos(5, qPanel:GetTall() - (acc:GetTall() + 5))
					acc:SText("Accept")
					acc.DoClick = function()
						qPanel:Close()
						
						buyTbl[k] = {v[1], math.Round(val:GetValue())}
						shopButton:SetStack(v.Stack - math.Round(val:GetValue()))
						s:DoHighlight()
					end
					
					local dec = vgui.Create("cButton", qPanel)
					dec:SetSize(qPanel:GetWide()/3, 25)
					dec:SetPos(qPanel:GetWide() - (dec:GetWide() + 5), qPanel:GetTall() - (dec:GetTall() + 5))
					dec:SText("Decline")
					dec.DoClick = function()
						qPanel:Close()
					end
					
					qPanel.Paint = function(s)
						draw.RoundedBoxEx(1,0,0,s:GetWide(), s:GetTall(), Color(155,155,155,255))
						
						surface.SetDrawColor(Color(55,55,55,255))
						surface.DrawOutlinedRect(0,0,s:GetWide(),s:GetTall())
					end
				else
					buyTbl[k] = {v[1], 1}
					s:DoHighlight()
				end
			else
				buyTbl[k] = nil
				
				if v.Stack then
					shopButton:SetStack(v.Stack)
				end
				s:DoHighlight()
			end 
		end
		
		shopList:AddItem(shopButton)
	end
	
	shopPnl.Paint = function(s)	
		draw.RoundedBoxEx(1,0,pxSub,s:GetWide(), s:GetTall() - pxSub, Color(155,155,155,200))
		
		surface.SetDrawColor(Color(55,55,55))
		surface.DrawLine(0,22.5,20,22.5)
		surface.DrawLine(0,s:GetTall() - 1,s:GetWide(),s:GetTall()-1)
		surface.DrawLine(30 + (9.5 * string.len(curCategory) ) - 9.5,22.5,s:GetWide(),22.5)
		
		surface.DrawLine(0,pxSub,0,s:GetTall())
		surface.DrawLine(s:GetWide()-1,pxSub,s:GetWide()-1,s:GetTall())
		
		//Money box
		local xOffset = 20
		local yPos = 50
		local boxHeight = 35
		
		local activeCost = CalculateCost()
		local activeSymbol = "-"
		local addActive = false
		
		if activeCost != 0 then
			if activeCost > 0 then
				activeSymbol = "+"
			else
				activeSymbol = "-"
			end
			
			addActive = "(" .. activeSymbol .. math.abs(activeCost) .. ")"
		else
			addActive = ""
		end
		
		draw.RoundedBoxEx(1,xOffset, s:GetTall() - yPos, s:GetWide() - xOffset * 2, boxHeight, Color(125,125,125,255))
		surface.SetDrawColor(Color(55,55,55))
		surface.DrawOutlinedRect(xOffset, s:GetTall() - yPos, s:GetWide() - xOffset * 2, boxHeight)
		draw.SimpleText("$", "Inventory", xOffset + 5, s:GetTall() - yPos + boxHeight / 5, Color(55,255,55,255))
		draw.SimpleText(vendorMoney .. addActive, "Inventory", xOffset + 19, s:GetTall() - yPos + boxHeight / 5 + 0.5, color_white)
		//
		
		draw.SimpleTextOutlined(curCategory, "Inventory", 22.5 + (0.25 * string.len(curCategory)) , 25, Color(55,55,55), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(155,155,155,200))
	end
	
	local itPreviewPanel = vgui.Create("DFrame")
	itPreviewPanel:SetSize(pnlWidth, pnlHeight)
	local x,y = shopPnl:GetPos()
	itPreviewPanel:SetPos(x + (3.5 + pnlWidth), y)
	itPreviewPanel:SetTitle("")
	itPreviewPanel.Paint = function()
		
		if activeItem then
			
		end
	end
	
	local invPnl = vgui.Create("DFrame")
	invPnl:MakePopup()
	invPnl:SetDraggable(false)
	invPnl:SetSize(pnlWidth, pnlHeight)
	invPnl:SetTitle("")
	invPnl:SetPos(pxOffset * 2.5, ScrH() / 2 - invPnl:GetTall() / 2)
	
	invPnl.Paint = function(s)	
		draw.RoundedBoxEx(1,0,pxSub,s:GetWide(), s:GetTall() - pxSub, Color(155,155,155,200))
		
		surface.SetDrawColor(Color(55,55,55))
		surface.DrawLine(0,22.5,20,22.5)
		surface.DrawLine(0,s:GetTall() - 1,s:GetWide(),s:GetTall()-1)
		surface.DrawLine(30 + (9.7 * string.len(invTitle) ) - 9.5,22.5,s:GetWide(),22.5)
		
		surface.DrawLine(0,pxSub,0,s:GetTall())
		surface.DrawLine(s:GetWide()-1,pxSub,s:GetWide()-1,s:GetTall())
		
		//Money box
		local xOffset = 20
		local yPos = 50
		local boxHeight = 35
		
		local activeCost = CalculateCost()
		local activeSymbol = "-"
		local addActive = false
		
		if activeCost != 0 then
			if activeCost > 0 then
				activeSymbol = "-"
			else
				activeSymbol = "+"
			end
			
			addActive = "(" .. activeSymbol .. math.abs(activeCost) .. ")"
		else
			addActive = ""
		end
		
		draw.RoundedBoxEx(1,xOffset, s:GetTall() - yPos, s:GetWide() - xOffset * 2, boxHeight, Color(125,125,125,255))
		surface.SetDrawColor(Color(55,55,55))
		surface.DrawOutlinedRect(xOffset, s:GetTall() - yPos, s:GetWide() - xOffset * 2, boxHeight)
		draw.SimpleText("$", "Inventory", xOffset + 5, s:GetTall() - yPos + boxHeight / 5, Color(55,255,55,255))
		draw.SimpleText(playerMoney .. addActive, "Inventory", xOffset + 19, s:GetTall() - yPos + boxHeight / 5 + 0.5, color_white)
		//
		
		draw.SimpleTextOutlined(invTitle, "Inventory", 22.5 + (0.25 * string.len(invTitle)) , 25, Color(55,55,55), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(155,155,155,200))
	end
	
	local invList = vgui.Create("DPanelList", invPnl)
	invList:SetSize(invPnl:GetWide() - 20, invPnl:GetTall() - (56 + pxSub + 1))
	invList:SetPos(10, pxSub +  5)
	invList:EnableVerticalScrollbar(true)
	
	for k,v in pairs(CreateProperInventory(_Inventory)) do
		local shopButton = vgui.Create("ShopButton")
		shopButton:SetSize(invList:GetWide() - 20, invList:GetTall() / 9)
		shopButton:SetItem(v[1])
		if v.Stack then
			shopButton:SetStack(v.Stack)
		end
		shopButton.OutlineColor = Color(205,55,55,255)
		
		shopButton.DoClick = function(s)
			if !s.IsHighlighted then
				if v.Stack then
					local x,y = invPnl:GetPos()
--[[ 				shopPnl:MoveTo(-ScrW() - invPnl:GetWide(),y, 0.25)
					invPnl:MoveTo(ScrW() + invPnl:GetWide(),y, 0.25) ]]
				
					local qPanel = vgui.Create("DFrame")
					qPanel:SetSize(400,125)
					qPanel:Center()
					qPanel:MakePopup()
					qPanel:SetTitle("")
					qPanel:ShowCloseButton(false)
					
					local prompt = vgui.Create("RichText", qPanel)
					prompt:SetSize(qPanel:GetWide() - 10, qPanel:GetTall() - 50)
					prompt:SetPos(5, 0)
					prompt:SetVerticalScrollbarEnabled(false)
					
					prompt:InsertColorChange(55,55,55,255)
					prompt:AppendText("How many ")
					
					prompt:InsertColorChange(205, 55, 55, 255)
					prompt:AppendText(GetItem(v[1]).Name)
					
					prompt:InsertColorChange(55,55,55,255)
					prompt:AppendText(" would you like to")
					
					prompt:InsertColorChange(205, 55, 55, 255)
					prompt:AppendText(" sell")
					
					prompt:InsertColorChange(55,55,55,255)
					prompt:AppendText("?")
					 
					function prompt:PerformLayout()

						self:SetFontInternal( "Inventory" )
						self:SetFGColor( Color( 255, 255, 255 ) )

					end
					
					local val = vgui.Create("DNumSlider", qPanel)
					val:SetSize(qPanel:GetWide() + 190, qPanel:GetTall()/6)
					val:SetPos(-200, qPanel:GetTall()/2 - val:GetTall())
					val:SetMinMax(1, v.Stack)
					val:SetDecimals(0)
					val:SetValue(1)
					
					local acc = vgui.Create("cButton", qPanel)
					acc:SetSize(qPanel:GetWide()/3, 25)
					acc:SetPos(5, qPanel:GetTall() - (acc:GetTall() + 5))
					acc:SText("Accept")
					acc.DoClick = function()
						qPanel:Close()
						
						sellTbl[k] = {v[1], math.Round(val:GetValue())}
						shopButton:SetStack(v.Stack - math.Round(val:GetValue()))
						s:DoHighlight()
					end
					
					local dec = vgui.Create("cButton", qPanel)
					dec:SetSize(qPanel:GetWide()/3, 25)
					dec:SetPos(qPanel:GetWide() - (dec:GetWide() + 5), qPanel:GetTall() - (dec:GetTall() + 5))
					dec:SText("Decline")
					dec.DoClick = function()
						qPanel:Close()
					end
					
					qPanel.Paint = function(s)
						draw.RoundedBoxEx(1,0,0,s:GetWide(), s:GetTall(), Color(155,155,155,255))
						
						surface.SetDrawColor(Color(55,55,55,255))
						surface.DrawOutlinedRect(0,0,s:GetWide(),s:GetTall())
					end
				else
					sellTbl[k] = {v[1], 1}
					s:DoHighlight()
				end
			else
				sellTbl[k] = nil
				
				if v.Stack then
					shopButton:SetStack(v.Stack)
				end
				s:DoHighlight()
			end 
		end
		
		invList:AddItem(shopButton)
	end
end

concommand.Add("testshop", OpenShopMenu)