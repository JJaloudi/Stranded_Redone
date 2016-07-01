local DialogueButton = {}

surface.CreateFont( "DialogueResponse", 
                    {
                    font    = "Roboto-Light",
                    size    = 15,
                    weight  = 1000,
                    antialias = true,
                    shadow = false
            })


function DialogueButton:Init()
	self.OutlineColor = Color(105,105,105,255)
	self:SetText("")
	self.Font = "Default"
	self.Text = "Button"
	
	self.IsHighlighted = false
end


function DialogueButton:SText(text)
	self.Text = text
end 

function DialogueButton:SetInteractColor(col)
	self.InteractColor = col
end

function DialogueButton:OnCursorEntered()
	self.Active = true
end

function DialogueButton:OnCursorExited()
	self.Active = false
end

function DialogueButton:OnMousePressed()
	self:DoClick()
	surface.PlaySound("UI/buttonclick.wav")
end
	
function DialogueButton:Paint()
	if self.Active then
		draw.RoundedBox(2,0,0,self:GetWide(), self:GetTall(), Color(155,155,155,255))
		
		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(0,0, self:GetWide(), self:GetTall())
	end
	
	draw.SimpleText(self.Text, "DialogueResponse", 7.5, self:GetTall()/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end   
vgui.Register("DialogueButton",DialogueButton,"DButton")