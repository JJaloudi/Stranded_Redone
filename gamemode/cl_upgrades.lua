function OpenUpgradesMenu()

	local base = vgui.Create("cFrame")
	
	base:SetSize(ScrW()/3.5, ScrH())
	base:SetPos(-base:GetWide(),0)
	base:ShowCloseButton(false)
	base:MakePopup()
	base:SetDraggable(false)
	base.buffbase = false
	
	base:MoveTo(0,0,0.5)
	
	net.Start("RequestWeapons")
		net.WriteEntity(LocalPlayer())
	net.SendToServer()
	
	net.Receive("SendWeapons",function()	
	
		local wep = net.ReadTable()

		local wepList = vgui.Create("DPanelList",base)
		wepList:SetSize(base:GetWide(), base:GetTall() - 60)
		wepList:SetPos(0, 10)
		wepList:SetPadding(2)
		wepList.Paint = function() end
		
		base.wepButton = {}
		base.upButton = {}
		
		for k,v in pairs(wep) do
		
			base.wepButton[k] = vgui.Create("DPanel")
			base.wepButton[k]:SetSize(base:GetWide(), wepList:GetTall()/10)
			base.wepButton[k]:SetText("")
			base.wepButton[k].isActive = false
			
			base.upButton[k] = vgui.Create("cButton",base.wepButton[k])
			base.upButton[k]:SetSize(27.5, base.wepButton[k]:GetTall())
			base.upButton[k]:SetPos(base.wepButton[k]:GetWide() - 31, 0)
			base.upButton[k]:SText(">")
			
			base.upButton[k].DoClick = function()
			
				if !base.buffbase then
				
					base.buffbase = vgui.Create("cFrame")
					base.buffbase:SetDraggable(false)
					base.buffbase:ShowCloseButton(false)
					local bb = base.buffbase
					bb:SetSize(200, ScrH())
					bb:SetPos(-base:GetWide(), 0)
					bb:MoveTo(base:GetWide(), 0, 0.5)
					bb:MoveToBack()
					bb:MoveTo(base:GetWide(), 0, 0.5)
					bb.PaintOver = function(s)
						surface.SetDrawColor(color_white)
						surface.DrawOutlinedRect(0,0,s:GetWide(),s:GetTall())
						draw.RoundedBoxEx(1,1,s:GetTall()/2 - 29, s:GetWide()-2, 29, color_black)
						draw.RoundedBoxEx(1,1,0,s:GetWide()-2, 25,color_black)
						draw.SimpleText("Available Buffs", "Inventory", s:GetWide()/2,20, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP )
						draw.SimpleText("Current Buffs", "Inventory", s:GetWide()/2,s:GetTall()/2 - 15, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )

					end
					net.Start("RequestBuffs") net.WriteEntity(LocalPlayer()) net.WriteUInt(k,8) net.SendToServer()
					
					local bbList = vgui.Create("DPanelList", bb)
					bbList:SetSize(bb:GetWide(), ScrH()/2 - 55)
					bbList:EnableVerticalScrollbar(true)
					bbList:SetPos(0,25)	
					bbList:SetSpacing(0)
					
					net.Receive("SendBuffs",function()
						local bTbl = net.ReadTable()
						for key, buff in pairs(bTbl) do
							
							if GetItem(buff.ID).BuffType == GetItem(v.Item).Category then
							
								local buffslotButton = vgui.Create("DPanel")
								buffslotButton:SetSize(bbList:GetWide(), (ScrH()/2) / 5) 
								
								if buff.Data then
									buffslotButton.Data = buff.Data	
									buffslotButton.Data.Slot = key
								end
								PrintTable(bTbl)
								
								buffslotButton.Paint = function(s)
									draw.RoundedBoxEx(1,0,0,s:GetWide(),s:GetTall(), Color(155,155,155,255))
									
									draw.SimpleText(buff.Data[3],"Inventory", s:GetWide()/2, 12.5, color_black, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
									draw.SimpleText(BUFF_TYPES[GetItem(v.Item).Category][buff.Data[1]].Name , "Inventory", s:GetWide()/2, s:GetTall()/2 - 12.5, BUFF_TYPES[GetItem(v.Item).Category][buff.Data[1]].Color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
									draw.SimpleText("+"..buff.Data[2],"Inventory", s:GetWide()/2, s:GetTall()/2 + 5, BUFF_TYPES[GetItem(v.Item).Category][buff.Data[1]].Color, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
										
									surface.SetDrawColor(color_white)
									surface.DrawOutlinedRect(0,0,s:GetWide(),s:GetTall())
								end
								
								
								buffslotButton:Droppable("buff")
								
								bbList:AddItem(buffslotButton)  
							end
							
						end
					end)
					

					
					
					local bsList = vgui.Create("DPanelList", bb)
					bsList:SetSize(bb:GetWide(), bb:GetTall() /2)
					bsList:SetPos(0,bb:GetTall()/2)
					PrintTable(v.Data)
					
					for key, buff in pairs(v.Data) do
					
						PrintTable(buff)
					
						local buffslotButton = vgui.Create("DPanel")
						buffslotButton:SetSize(bbList:GetWide(), (ScrH()/2) / 5)
						
						buffslotButton.Paint = function(s)
							draw.RoundedBoxEx(1,0,0,s:GetWide(),s:GetTall(), Color(200,200,200,255))
							draw.SimpleText(key..".)","Inventory", 4,2.5, color_black)
							
							if buff[1] then
								 draw.SimpleText(buff[3],"Inventory", s:GetWide()/2, 12.5, color_black, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
								 draw.SimpleText(BUFF_TYPES[GetItem(v.Item).Category][buff[1]].Name , "Inventory", s:GetWide()/2, s:GetTall()/2 - 12.5, BUFF_TYPES[GetItem(v.Item).Category][buff[1]].Color, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
								 draw.SimpleText("+"..buff[2],"Inventory", s:GetWide()/2, s:GetTall()/2 + 5, BUFF_TYPES[GetItem(v.Item).Category][buff[1]].Color, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
							else
								draw.SimpleText("Empty Slot", "Inventory", s:GetWide()/2, 12.5, color_black, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
								
								draw.SimpleText("DROP BUFF HERE", "Inventory", s:GetWide()/2, s:GetTall()/2,  color_black, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
							end 		
					
							surface.SetDrawColor(color_white)
							surface.DrawOutlinedRect(0,0,s:GetWide(),s:GetTall())
						end
						
						buffslotButton:Receiver("buff",function(rcv,pDropped,bDrop)
							if !bDrop then return end
							
							if buff[1] then
								Notify("This slot is already occupied! All buffs are permanent.")
							else
								
								net.Start("UpgradeWeapon")
									net.WriteEntity(LocalPlayer())
									net.WriteUInt(k, 8)
									net.WriteUInt(key, 8)
									net.WriteUInt(pDropped[1].Data.Slot, 8)
								net.SendToServer()
								
								buff[1], buff[2], buff[3] = pDropped[1].Data[1], pDropped[1].Data[2], pDropped[1].Data[3]
								pDropped[1]:Remove()
								
								net.Receive("SendUpdatedName", function() v.Name = net.ReadString() end)
								
							end
						end)
						
						bsList:AddItem(buffslotButton)  
					end
					
					
					base.upButton[k]:SText("<")
					base.wepButton[k].isActive = true
					
				else
				
					for k,v in pairs(base.upButton) do
						v:SText(">")
					end
					
					base.wepButton[k].isActive = false
					
					base.buffbase:MoveTo(-base:GetWide(), 0, 0.3, 0, -1,function()
						
						base.buffbase:Close()
						base.buffbase = false
						
					end)
				
				end
			
			end
			
			local wepImg = vgui.Create("SpawnIcon",base.wepButton[k])
			wepImg.Paint = function() end; wepImg.PaintOver = function(s) 
				surface.SetDrawColor(color_white)
				surface.DrawOutlinedRect(0,0,s:GetWide(),s:GetTall())
			end
			wepImg:SetModel(GetItem(v.Item).Model)
			wepImg:SetSize(base.wepButton[k]:GetTall() - 25, base.wepButton[k]:GetTall() - 25)
			wepImg:SetPos(3,base.wepButton[k]:GetTall() - wepImg:GetTall() - 5) 
			wepImg.isDisplay = true
			
			local imgList = vgui.Create("DPanelList", base.wepButton[k])
			imgList:SetSize( wepImg:GetWide() * 5.5, base.wepButton[k]:GetTall() - 20)
			imgList:SetPos(45 + wepImg:GetWide(), (base.wepButton[k]:GetTall() / 2) - imgList:GetTall()/2 + 10)
			imgList:EnableHorizontal(true)
			imgList:SetSpacing(5)
				

				local offCount = 0
				for key, buff in pairs(v.Data) do
					
					offCount = offCount + 1
					
					local Data = {Name = buff[3], Type = buff[1], Amount = buff[2]}
					
					local buffImg = vgui.Create("DPanel", base.wepButton[k])
					buffImg:SetSize((imgList:GetWide()/6) - 2.5, imgList:GetTall() - 2)
					
					
					buffImg.Paint = function() end; buffImg.PaintOver = function(s)
						if !buff[1] then									
							draw.RoundedBoxEx(1,0,0,s:GetWide(), s:GetTall(), Color(255,255,255,99+math.sin(CurTime()*math.abs(5))*50))
						else
							draw.RoundedBoxEx(1,0,0,s:GetWide(), s:GetTall(), Color(55,255,95,255))
						end
						draw.SimpleText(key, "Default",2.5,2.5,color_black)
						surface.SetDrawColor(color_white)
						surface.DrawOutlinedRect(0,0,s:GetWide(),s:GetTall())
						
					end
					
					imgList:AddItem(buffImg)
				end
		
			base.wepButton[k].Paint = function(s)
				if s.isActive then
					draw.RoundedBoxEx(1,0,0,s:GetWide(),s:GetTall(),Color(155,155,155,255))
				else
					draw.RoundedBoxEx(1,0,0,s:GetWide(),s:GetTall(),Color(55,55,55,255))
				end
				surface.SetDrawColor(color_white)
				draw.SimpleText(v.Name, "Inventory", 5, 20, color_white,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				draw.SimpleText("=","Inventory", base.wepButton[k]:GetTall() - 5, s:GetTall()/2 - 2.5,color_white)
				surface.DrawOutlinedRect(0,0,s:GetWide()-27,s:GetTall())
			end
			
			wepList:AddItem(base.wepButton[k])
		end
		
	end)
	
	local cancel = vgui.Create("cButton",base)
	cancel:SetSize(base:GetWide(), 50)
	cancel:SetPos(0,base:GetTall() - cancel:GetTall())
	cancel:SText("Close")
	
	cancel.DoClick = function() 
		if base.buffbase then 

			base.buffbase:Close() 
			
		end
	
		base:MoveTo(-ScrW()/2, 0, 0.2, 0, -1, function() 
			
			base:Close() 
			gui.EnableScreenClicker(false)
			
		end) 
		
	end
	
end
concommand.Add("upgrades",OpenUpgradesMenu) 