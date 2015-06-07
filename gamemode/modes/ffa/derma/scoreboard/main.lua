surface.CreateFont( "Scoreboard_1",{
	font = "Europe",
	size = ScreenScaleEx(24),
	weight = 800,
	antialias = true
})
surface.CreateFont( "Scoreboard_1_blur",{
	font = "Europe",
	size = ScreenScaleEx(24),
	weight = 800,
	blursize = 3
})
surface.CreateFont( "Scoreboard_Tab",{
	font = "Russo One",
	size = ScreenScaleEx(16),
	weight = 400,
	antialias = true
})
surface.CreateFont( "Scoreboard_Tab_blur",{
	font = "Russo One",
	size = ScreenScaleEx(16),
	weight = 400,
	blursize = 3
})
surface.CreateFont( "Scoreboard_Place",{
	font = "Russo One",
	size = ScreenScaleEx(24),
	weight = 400,
	antialias = true
})
surface.CreateFont( "Scoreboard_Place_blur",{
	font = "Russo One",
	size = ScreenScaleEx(24),
	weight = 400,
	blursize = 3
})

local MAT_GRADIENT_L = Material("gui/gradient")
local MAT_GRADIENT_U = Material("vgui/gradient-u")

local scoreboard = {}
local PANEL = {}
function PANEL:Init()
	self.BaseClass.Init( self )
	
	self.Players = {}
	self.Players_sort = {}
	self:RebuildList()
end
function PANEL:AddPlayer( ply )
	for k,v in pairs( self.Players ) do
		if v.ply == ply then
			return
		end
	end
	local plypanel = vgui.Create("AGUI.Scoreboard.Player", self)
	plypanel:SetPlayer( ply, #self.Players + 1 )
	self:AddItem(plypanel)
	table.insert( self.Players, { panel = plypanel, ply = ply } )
	
	self:PerformLayout()
end

function PANEL:RebuildList()
	self:Clear()
	self.Players = {}
	for z,x in pairs(player.GetSortedPlayers()) do
		self:AddPlayer( x )
	end
	for k,v in pairs(self.Players) do self.Players_sort[k] = v.ply end
end

function PANEL:Paint( w, h ) end
function PANEL:PerformLayout()
	self.BaseClass.PerformLayout( self )
end
function PANEL:Think()
	for k,v in pairs(self.Players) do self.Players_sort[k] = v.ply end
	
	if !table.Compare( self.Players_sort, player.GetSortedPlayers() ) then
		self:RebuildList()
	end
	self:InvalidateLayout()
end
function PANEL:ApplySchemeSettings()
	self.BaseClass.ApplySchemeSettings( self )
end
vgui.Register( "AGUI.Scoreboard.Frame", PANEL, "DPanelList" )
PANEL = {}
function PANEL:Init()
	self.BaseClass.Init( self )
	
	self.Players = {}
	self.Players_sort = {}
	self:RebuildList()
end
function PANEL:AddPlayer( ply )
	for k,v in pairs( self.Players ) do
		if v.ply == ply then
			return
		end
	end
	local plypanel = vgui.Create("AGUI.Scoreboard.Player", self)
	plypanel:SetPlayer( ply, #self.Players + 1 )
	self:AddItem(plypanel)
	table.insert( self.Players, { panel = plypanel, ply = ply } )
	
	self:PerformLayout()
end

function PANEL:RebuildList()
	self:Clear()
	self.Players = {}
	for z,x in pairs(player.GetSpectatorPlayers()) do
		self:AddPlayer( x )
	end
	for k,v in pairs(self.Players) do self.Players_sort[k] = v.ply end
end

function PANEL:Paint( w, h ) end
function PANEL:PerformLayout()
	self.BaseClass.PerformLayout( self )
end
function PANEL:Think()
	for k,v in pairs(self.Players) do self.Players_sort[k] = v.ply end
	
	if !table.Compare( self.Players_sort, player.GetSpectatorPlayers() ) then
		self:RebuildList()
	end
	self:InvalidateLayout()
end
function PANEL:ApplySchemeSettings()
	self.BaseClass.ApplySchemeSettings( self )
end
vgui.Register( "AGUI.Scoreboard.Frame2", PANEL, "DPanelList" )

PANEL = {}
function PANEL:Init()
	self.Avatar = vgui.Create( "AvatarImage", self )
    self.Avatar:SetSize(22, 22)
    self.Avatar:SetMouseInputEnabled(false)
    
    self:SetText("")
    self.Place = 0
    self.Player = nil
    self.Ping = "0"
    self.Frags = "0"
    self.Deaths = "0"
    self:SetCursor( "hand" )
end
function PANEL:SetPlayer( ply, place )
    self.Player = ply
	self.Place = place
    self.Avatar:SetPlayer(ply)
end

local colors = {}
colors[true] = {white = Color( 255, 255, 255, 255 ),
				green = Color( 0, 255, 0, 255 ),
				red = Color( 255, 0, 0, 255 ),
				black = Color( 0, 0, 0, 255 )}
colors[false] = {white = Color( 210, 210, 210, 255 ),
				 green = Color( 0, 210, 0, 255 ),
				 red = Color( 210, 0, 0, 255 ),
				 black = Color( 0, 0, 0, 200 )}
function PANEL:Paint( w, h )
	if not IsValid(self.Player) then return end
	
	local name = self.Player:Name()
	local color = colors[self.entered or false]
	surface.SetMaterial(MAT_GRADIENT_L)
	surface.SetDrawColor(color.black)
	surface.DrawTexturedRect(0,0,w*2,h)
	local w_n,h_n = surface.GetTextSizeEx( "99", "Scoreboard_Tab_blur" )
	
	if !self.Player:IsSpectator() then
		draw.DrawAbdulText( self.Place, "Scoreboard_Tab", "Scoreboard_Tab_blur", 8, h/2, color.white, 0, 1, 0 )
	end
	local x = w_n + 8*3 + 24
	draw.DrawAbdulText( name, "Scoreboard_Tab", "Scoreboard_Tab_blur", x, h/2, color.white, 0, 1, 0 )
	x = w/1.7
	if !self.Player:IsSpectator() then
		draw.DrawAbdulText( self.Frags, "Scoreboard_Tab", "Scoreboard_Tab_blur", x, h/2, color.green, 2, 1, 0 )
	end
	x = w/1.25
	if !self.Player:IsSpectator() then
		draw.DrawAbdulText( self.Deaths, "Scoreboard_Tab", "Scoreboard_Tab_blur", x, h/2, color.red, 2, 1, 0 )
	end
	x = w - 8
	draw.DrawAbdulText( self.Ping, "Scoreboard_Tab", "Scoreboard_Tab_blur", x, h/2, color.white, 2, 1, 0 )
end
function PANEL:DoClick( w )
	self.Options = DermaMenu()
    self.Options:AddOption("Show Steam profile", function()
    	self.Player:ShowProfile()
    end)
    local muteText = self.Player:IsMuted() and "UnMute" or "Mute"
    self.Options:AddOption(muteText, function()
    	self.Player:SetMuted(!self.Player:IsMuted())
    end)
    self.Options:Open()
end
function PANEL:OnCursorEntered()
    self.entered = true
end
function PANEL:OnCursorExited()
    self.entered = false
end
function PANEL:PerformLayout()
	local w_n,h_n = surface.GetTextSizeEx( "99", "Scoreboard_Tab_blur" )
	
	self:SetTall(24)

	self.Avatar:SetPos( w_n + 8*2 + 1,1	)
end
function PANEL:Think()
	if not IsValid(self.Player) then return end
    
    self.Ping = tostring( self.Player:Ping() )
    self.Frags = tostring( self.Player:Frags() )
    self.Deaths = tostring( self.Player:Deaths() ) 
    
	self:PerformLayout()
end
function PANEL:ApplySchemeSettings() end
vgui.Register( "AGUI.Scoreboard.Player", PANEL, "Button" )


PANEL = {}
function PANEL:Init()
	self.ListT = vgui.Create("AGUI.Scoreboard.Frame", self)
	self.ListT:EnableHorizontal( false )
	self.ListT:EnableVerticalScrollbar( true ) 
	self.ListS = vgui.Create("AGUI.Scoreboard.Frame2", self)
	self.ListS:EnableHorizontal( false )
	self.ListS:EnableVerticalScrollbar( true ) 
end
function PANEL:Paint( w, h )
	local w_t,h_t = surface.GetTextSizeEx( MODE.Name, "Scoreboard_1_blur" )
	local w_n,h_n = surface.GetTextSizeEx( "99", "Scoreboard_Tab_blur" )
    draw.RoundedBox( 0, 0, 20 + h_t, w, 27, Color(0,0,0,240) )
	surface.SetMaterial(MAT_GRADIENT_U)
	surface.SetDrawColor(Color(0,0,0,200))
	surface.DrawTexturedRect(0,0,w,h_t*10)
    draw.DrawAbdulText( MODE.Name, "Scoreboard_1", "Scoreboard_1_blur", 10, 10, Color(255,255,255,255), 0, 0, 0 )
	h = 20 + h_t
	draw.DrawAbdulText( "#", "Scoreboard_Tab", "Scoreboard_Tab_blur", 8, h + 5, Color(230,230,230,255), 0, 0, 0 )
	draw.DrawAbdulText( "Name", "Scoreboard_Tab", "Scoreboard_Tab_blur", w_n + 8*3 + 24, h + 5, Color(230,230,230,255), 0, 0, 0 )
	draw.DrawAbdulText( "Ping", "Scoreboard_Tab", "Scoreboard_Tab_blur", w - 8, h + 5, Color(230,230,230,255), 2, 0, 0 )
	draw.DrawAbdulText( "Deaths", "Scoreboard_Tab", "Scoreboard_Tab_blur", w/1.25, h + 5, Color(255,0,0,255), 2, 0, 0 )
	draw.DrawAbdulText( "Kills", "Scoreboard_Tab", "Scoreboard_Tab_blur", w/1.7, h + 5, Color(0,255,0,255), 2, 0, 0 )
end
function PANEL:PerformLayout()
	local w_t,h_t = surface.GetTextSizeEx( MODE.Name, "Scoreboard_1_blur")
	local w_t2,h_t2 = surface.GetTextSizeEx( "NAME", "Scoreboard_Tab_blur" )
	local offset = h_t + 20 + 10 + h_t2
	
 	local w = math.max(ScrW() * 0.4, 640)
    local h = ScrH() * 0.8
	local tall = 0
	local tall2 = 0
	
	if self.ListT then
		tall = self.ListT:GetCanvas():GetTall()
	end
	if self.ListS then
		tall2 = self.ListS:GetCanvas():GetTall()
	end
	
    self:SetSize(w,math.Clamp(offset + tall + 24 + tall2,0,h))
    self:SetPos( (ScrW() - w) / 2, (ScrH() - (math.Clamp(offset + tall + 24 + tall2,0,h))) / 2 )
    
    self.ListT:SetPos( 0, offset)
    self.ListT:SetSize( w, math.Clamp(tall,0,h - offset))
	
	self.ListS:SetPos( 0, tall + offset + 24)
	self.ListS:SetSize( w, math.Clamp(tall2,0,h - offset - 24*2))
end
function PANEL:Think()
	self:PerformLayout() 
end
function PANEL:ApplySchemeSettings() end
vgui.Register( "AGUI.Scoreboard", PANEL, "Panel" )


function scoreboard.Remove()
   if scoreboard.panel then
      scoreboard.panel:Remove()
      scoreboard.panel = nil
   end
end
function scoreboard.Create()
   scoreboard.panel = vgui.Create("AGUI.Scoreboard")
end

scoreboard.Remove()

function MODE:HUDDrawScoreBoard()
	if !scoreboard.panel then return end
	if !scoreboard.panel:IsVisible() then return end
	
	local panel_x,panel_y,panel_w,panel_h = scoreboard.panel:GetBounds()
	
	if GetGameState() == GS_ROUND_PLAYING then
		local m_iPlace = LocalPlayer():GetPlace()
		local m_tPlace = m_tPlacePrefix[ m_iPlace ] or m_tPlacePrefix[4]
		local text1 = m_iPlace .. m_tPlace.pref
		local text2 = " place with " .. LocalPlayer():Frags()
		local w1,h = surface.GetTextSizeEx( text1, "Scoreboard_Place" )
		local w2,h = surface.GetTextSizeEx( text2, "Scoreboard_Place" )
		local w3,h = surface.GetTextSizeEx( text1 .. text2, "Scoreboard_Place" )
		local y = panel_y - h - 10
		local x = ScrW()/2 - ( w1 + w2 )/2
		draw.DrawAbdulText( text1, "Scoreboard_Place", "Scoreboard_Place_blur",  x, y, m_tPlace.color, 0, 0, 0 )
		local x = x + w1
		draw.DrawAbdulText( text2, "Scoreboard_Place", "Scoreboard_Place_blur",  x, y, Color(255,255,255,255), 0, 0, 0 )
	end
	
	local y = panel_y + panel_h + 5
	local w1,h = surface.GetTextSizeEx( "H", "AFont_Hint_small" )
	draw.DrawAbdulText( "Press F1 to show settings menu", "AFont_Hint_small", "AFont_Hint_small_blur",  ScrW()/2, y, Color(200,240,255,255), 1, 0, 0 )
	
	local y = panel_y + panel_h + 10 + h
	draw.DrawAbdulText( GetHostName(), "Scoreboard_Place", "Scoreboard_Place_blur",  ScrW()/2, y, Color(255,255,255,255), 1, 0, 0 )
	
end

function GM:ScoreboardShow()
	if not scoreboard.panel then
		scoreboard.Create()
	end
	gui.EnableScreenClicker(true)
	scoreboard.panel:SetVisible(true)
	return false 
end

function GM:ScoreboardHide()
	gui.EnableScreenClicker(false)

	if scoreboard.panel then
		scoreboard.panel:SetVisible(false)
	end
	return false 
end