surface.CreateFont( "Notification", 
                    {
                    font    = "Roboto-Light",
                    size    = ScreenScale(11),
                    weight  = 1000,
                    antialias = true,
                    shadow = false
            })

local notifications = {}

net.Receive("NotifyPlayer",function()
	Notify(net.ReadString())
end)

function QueueNotification(text, duration, color, urgent)
	local key = table.Count(notifications) + 1

	notifications[key] = {Text = text, Dur = duration, Col = color, Closing = false,Alpha = 0}
	
	if urgent then
		notifications[1] = notifications[key]
	end 
	
	if !activeNotification then 
		activeNotification = true
	end
	
end

timer.Create("timerhandler", 1,0,function()
	if notifications[1] then
		if notifications[1].Dur - 1 > 0 then
			notifications[1].Dur = notifications[1].Dur - 1
		else
			notifications[1].Closing = true
		end
	end
end)

hook.Add("HUDPaint","DrawNotify",function()
	if notifications[1] then
		local x_size = 150 + (string.len(notifications[1].Text) * ScreenScale(4.7) - 150)
		local x,y = ScrW()/2 - (x_size/2),52.5
		if !notifications[1].Closing then
			notifications[1].Alpha = math.Approach(notifications[1].Alpha, 255,FrameTime() * 50)
		else
			if notifications[1].Alpha <= 0 then
				notifications[1] = nil
			end 
			notifications[1].Alpha = math.Approach(notifications[1].Alpha, 0, FrameTime() * 50)
			if notifications[1].Alpha <= 0 then
				notifications[1] = nil
				for k,v in pairs(notifications) do
					if notifications[2] then
						local new = notifications[2]
						notifications[1] = new
						notifications[k - 1] = notifications[k]
					else
						notifications[1] = nil
					end
				end
			end
		end
		
		local r,g,b = notifications[1].Col.r, notifications[1].Col.g, notifications[1].Col.b
		draw.RoundedBoxEx(8,x,y,x_size,25,Color(r,g,b,notifications[1].Alpha))
		draw.RoundedBoxEx(8,x + 2.5 ,y + 2.5,x_size - 7,20,Color(155,155,155,notifications[1].Alpha))
		draw.SimpleText(notifications[1].Text,"Notification", ScrW()/2,y,Color(r,g,b,notifications[1].Alpha),TEXT_ALIGN_CENTER)
 	end
end)

local hints = {}

net.Receive("HintPlayerEntity",function()
	print("Hello")
	CreateHint(net.ReadEntity, net.ReadString())
end)

local function CreateHint(area, str)
	hints[table.Count(hints) + 1] = {area, str}
	print("YO")
end

hook.Add("HUDPaint", "CreateHint", function()
	for k,v in pairs(hints) do
		print("Hory shit")
		local x,y = 0,0 
		if IsEntity(hint[1]) then
			x,y = v[1]:GetPos():ToScreen().x, v[1]:GetPos():ToScreen().y
		end
		local x_size = 150 + (string.len(v[2]) * ScreenScale(4.7) - 150)
		local r,g,b = GAME_GREEN.r, GAME_GREEN.g, GAME_GREEN.b
		local Alpha = 255 - v[1]:GetPos():Distance(LocalPlayer():GetPos())
			
		draw.RoundedBox(8,x,y,x_size,25,Color(r,g,b,Alpha))
		draw.RoundedBox(8,x + 2.5 ,y + 2.5,x_size - 5,20,Color(155,155,155,Alpha))
		draw.SimpleText(v[2],"Notification", ScrW()/2,y,Color(r,g,b,Alpha),TEXT_ALIGN_CENTER)
	end
end)
