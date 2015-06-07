surface.CreateFont( "MenuButton",{
	font = "Russo One",
	size = ScreenScaleEx(21),
	weight = 0,
	antialias = true
})
surface.CreateFont( "MenuButton_blur",{
	font = "Russo One",
	size = ScreenScaleEx(21),
	weight = 0,
	blursize = 3
})

local mainmenu = {}

local PANEL = {}
function PANEL:Init()
	self.PanelList = vgui.Create("DPanelList",self)
	self.PanelList:SetSpacing( 5 )
	
	self:AddConVarBool( "Enable/Disable abdul voice", "abdul_enablecommentary" )
	self:AddConVarBool( "Enable/Disable round music", "abdul_roundmusic" )
	self:AddConVarBool( "Enable/Disable round win music", "abdul_roundmusicwin" )
	self:AddConVarBool( "Enable/Disable auto switch to best weapon", "abdul_autoswitchweapon" )
	self:AddConVarBool( "Enable/Disable weapon fast switch", "abdul_fastswitch" )
	self:AddConVarRadius( "Round music volume", "abdul_roundmusic_volume", 0, 1, 1 )
	self:AddButton( "Close", function( button ) 
		if mainmenu.panel.CURRENT_WINDOW then 
			mainmenu.panel.CURRENT_WINDOW:Remove()
			mainmenu.panel.CURRENT_WINDOW = nil
		end
	end, 32 )
end
function PANEL:AddConVarBool( name, convar )
	local DermaCheckbox = vgui.Create( "DCheckBoxLabel", self )
	DermaCheckbox:SetText( name )
	DermaCheckbox:SetConVar( convar )
	DermaCheckbox:SizeToContents()
	
	self.PanelList:AddItem( DermaCheckbox )
end
function PANEL:AddConVarRadius( name, convar, min, max, decimals )
	local DermaNumSlider = vgui.Create( "DNumSlider", self )
	DermaNumSlider:SetDark( false )
	DermaNumSlider:SetText( name )
	DermaNumSlider:SetMin( min )
	DermaNumSlider:SetMax( max )
	DermaNumSlider:SetValue( GetConVar( convar ):GetInt() )
	DermaNumSlider:SetDecimals( decimals )
	DermaNumSlider.OnValueChanged = function( self, value )
		RunConsoleCommand( convar, value )
	end
	DermaNumSlider:SizeToContents()
	
	self.PanelList:AddItem( DermaNumSlider )
end
function PANEL:AddButton( name, func, h )
	local pnl = vgui.Create("AGUI.MenuButton",self)
	pnl.Text = name
	pnl:SetTall( h )
	pnl.DoClick = function( self )
		func( self )
	end
	self.PanelList:AddItem( pnl )
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color(20,22,25,250) )
end
function PANEL:PerformLayout()
 	local w = ScreenScale(150)
    local h = self.PanelList:GetCanvas():GetTall() + 10
    self:SetSize( w, h )
    self:SetPos( ScrW()/2 - w/2, ScrH()/2 - h/2  )
	self.PanelList:SetPos( 5, 5 )
	self.PanelList:SetSize( w - 10, self.PanelList:GetCanvas():GetTall() + 10 )
end
function PANEL:Think()
	self:PerformLayout() 
end
vgui.Register( "AGUI.AbdulSettings", PANEL, "Panel" )

PANEL = {}
function PANEL:Init()
	self.PanelList = vgui.Create("DPanelList",self)
	self.PanelList:SetSpacing( 5 )
	
	self:AddLabel( "Railgun color" )
	self:AddRGBPicker( "abdul_railguncolor" )
	self:AddButton( "Close", function( button ) 
		if mainmenu.panel.CURRENT_WINDOW then 
			mainmenu.panel.CURRENT_WINDOW:Remove()
			mainmenu.panel.CURRENT_WINDOW = nil
		end
	end, 32 )
end
function PANEL:AddLabel( text )
	local DermaLabel = vgui.Create( "DLabel", self )
	DermaLabel:SetText( text )
	DermaLabel:SizeToContents()
	
	self.PanelList:AddItem( DermaLabel )
end
function PANEL:AddRGBPicker( convar )
	local DermaRBGPicker = vgui.Create("DRGBPicker", self)
	DermaRBGPicker:SetTall( 160 )
	DermaRBGPicker.OnChange = function( panel, color )
		RunConsoleCommand( convar, tostring( color.r.." "..color.g.." "..color.b ) )
	end
	
	self.PanelList:AddItem( DermaRBGPicker )
end
function PANEL:AddButton( name, func, h )
	local pnl = vgui.Create("AGUI.MenuButton",self)
	pnl.Text = name
	pnl:SetTall( h )
	pnl.DoClick = function( self )
		func( self )
	end
	self.PanelList:AddItem( pnl )
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color(20,22,25,250) )
end
function PANEL:PerformLayout()
 	local w = ScreenScale(150)
    local h = self.PanelList:GetCanvas():GetTall() + 10
    self:SetSize( w, h )
    self:SetPos( ScrW()/2 - w/2, ScrH()/2 - h/2  )
	self.PanelList:SetPos( 5, 5 )
	self.PanelList:SetSize( w - 10, self.PanelList:GetCanvas():GetTall() + 10 )
end
function PANEL:Think()
	self:PerformLayout() 
end
vgui.Register( "AGUI.RailgunSettings", PANEL, "Panel" )
PANEL = {}
function PANEL:Init()
	self.PanelList = vgui.Create("DPanelList",self)
	self.PanelList:SetSpacing( 5 )
	
	self:AddLabel( "Abdul: Obvesy Fraera" )
	self:AddLabel( "Pre-Alpha" )
	self:AddLabel( "A mlg first person arena shooter with abdul" )
	self:AddLabel( "religion and anime, call of-duty elements." )
	self:AddLabel( " By Schwarz Kruppzo (2011-2015)." )
	self:AddButton( "Close", function( button ) 
		if mainmenu.panel.CURRENT_WINDOW then 
			mainmenu.panel.CURRENT_WINDOW:Remove()
			mainmenu.panel.CURRENT_WINDOW = nil
		end
	end, 32 )
end
function PANEL:AddLabel( text )
	local DermaLabel = vgui.Create( "DLabel", self )
	DermaLabel:SetText( text )
	DermaLabel:SizeToContents()
	
	self.PanelList:AddItem( DermaLabel )
end
function PANEL:AddButton( name, func, h )
	local pnl = vgui.Create("AGUI.MenuButton",self)
	pnl.Text = name
	pnl:SetTall( h )
	pnl.DoClick = function( self )
		func( self )
	end
	self.PanelList:AddItem( pnl )
end
function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color(20,22,25,250) )
end
function PANEL:PerformLayout()
 	local w = ScreenScale(150)
    local h = self.PanelList:GetCanvas():GetTall() + 10
    self:SetSize( w, h )
    self:SetPos( ScrW()/2 - w/2, ScrH()/2 - h/2  )
	self.PanelList:SetPos( 5, 5 )
	self.PanelList:SetSize( w - 10, self.PanelList:GetCanvas():GetTall() + 10 )
end
function PANEL:Think()
	self:PerformLayout() 
end
vgui.Register( "AGUI.Credits", PANEL, "Panel" )

PANEL = {}

local function MakeNiceName( str )
	local newname = {}
	for _, s in pairs( string.Explode( "_", str ) ) do
		if ( string.len( s ) == 1 ) then table.insert( newname, string.upper( s ) ) continue end
		table.insert( newname, string.upper( string.Left( s, 1 ) ) .. string.Right( s, string.len( s ) - 1 ) )
	end
	return string.Implode( " ", newname )
end

function PANEL:Init()
	self.mdl = vgui.Create("DModelPanel", self)
	self.mdl:SetFOV( 36 )
	self.mdl:SetCamPos( Vector( 0, 0, 0 ) )
	self.mdl:SetDirectionalLight( BOX_RIGHT, Color( 255, 160, 80, 255 ) )
	self.mdl:SetDirectionalLight( BOX_LEFT, Color( 80, 160, 255, 255 ) )
	self.mdl:SetAmbientLight( Vector( -64, -64, -64 ) )
	self.mdl:SetAnimated( true )
	self.mdl.Angles = Angle( 0, 0, 0 )
	self.mdl:SetLookAt( Vector( -100, 0, -22 ) )
	
	self.PanelList = vgui.Create("DPanelList",self)
	self.PanelList:SetSpacing( 5 )

	self.ControlsLbl = vgui.Create("DLabel", self)
	self.ControlsLbl:SetText( "Player color" )
	self.ControlsLbl:Dock( TOP )
	self.ControlsLbl:DockMargin( 2, 0, 0,0 )
	self.PanelList:AddItem( self.ControlsLbl )
	
	self.plycol = vgui.Create("DColorMixer", self)
	self.plycol:SetAlphaBar( false )
	self.plycol:SetPalette( false )
	self.plycol:SetTall( ScreenScale( 50 ) )
	self.PanelList:AddItem( self.plycol )
	
	self.PanelSelect = vgui.Create("DPanelSelect", self)
	self.PanelSelect:SetTall( ScreenScale( 80 ) )
	self.PanelList:AddItem( self.PanelSelect )
	
	self.PanelList2 = vgui.Create("DPanelList",self)
	self.PanelList2:SetSpacing( 5 )
	self.PanelList:AddItem( self.PanelList2 )
	
	for name, model in SortedPairs( player_manager.AllValidModels() ) do
		local icon = vgui.Create( "SpawnIcon" )
		icon:SetModel( model )
		icon:SetSize( 64, 64 )
		icon:SetTooltip( name )
		icon.playermodel = name
		self.PanelSelect:AddPanel( icon, { abdul_playermodel = name } )
	end

	local function UpdateBodyGroups( pnl, val )
		if ( pnl.type == "bgroup" ) then
			self.mdl.Entity:SetBodygroup( pnl.typenum, math.Round( val ) )
			local str = string.Explode( " ", GetConVarString( "abdul_playerbodygroups" ) )
			if ( #str < pnl.typenum + 1 ) then for i = 1, pnl.typenum + 1 do str[ i ] = str[ i ] or 0 end end
			str[ pnl.typenum + 1 ] = math.Round( val )
			RunConsoleCommand( "abdul_playerbodygroups", table.concat( str, " " ) )
		elseif ( pnl.type == "skin" ) then
			self.mdl.Entity:SetSkin( math.Round( val ) )
			RunConsoleCommand( "abdul_playerskin", math.Round( val ) )
		end
	end

	local function RebuildBodygroupTab()
		self.PanelList2:Clear()

		local nskins = self.mdl.Entity:SkinCount() - 1

		if ( nskins > 0 ) then
			local skins = vgui.Create( "DNumSlider" )
			skins:SetText( "Skin" )
			skins:SetTall( 50 )
			skins:SetDecimals( 0 )
			skins:SetMax( nskins )
			skins:SetValue( GetConVarNumber( "abdul_playerskin" ) )
			skins.type = "skin"
			skins.OnValueChanged = UpdateBodyGroups
			
			self.PanelList2:AddItem( skins )
			
			self.mdl.Entity:SetSkin( GetConVarNumber( "abdul_playerskin" ) )
		end

		local groups = string.Explode( " ", GetConVarString( "abdul_playerbodygroups" ) )
		for k = 0, self.mdl.Entity:GetNumBodyGroups() - 1 do
			if ( self.mdl.Entity:GetBodygroupCount( k ) <= 1 ) then continue end

			local bgroup = vgui.Create( "DNumSlider" )
			bgroup:SetText( MakeNiceName( self.mdl.Entity:GetBodygroupName( k ) ) )
			bgroup:SetTall( 50 )
			bgroup:SetDecimals( 0 )
			bgroup.type = "bgroup"
			bgroup.typenum = k
			bgroup:SetMax( self.mdl.Entity:GetBodygroupCount( k ) - 1 )
			bgroup:SetValue( groups[ k + 1 ] or 0 )
			bgroup.OnValueChanged = UpdateBodyGroups
			
			self.PanelList2:AddItem( bgroup )

			self.mdl.Entity:SetBodygroup( k, groups[ k + 1 ] or 0 )
		end
		
	end
	
	local function UpdateFromConvars()
		local model = LocalPlayer():GetInfo( "abdul_playermodel" )
		local modelname = player_manager.TranslatePlayerModel( model )
		util.PrecacheModel( modelname )
		self.mdl:SetModel( modelname )
		self.mdl.Entity.GetPlayerColor = function() return Vector( GetConVarString( "abdul_playercolor" ) ) end
		self.mdl.Entity:SetPos( Vector( -100, 0, -61 ) )
			
		self.plycol:SetVector( Vector( GetConVarString( "abdul_playercolor" ) ) )
		
		RebuildBodygroupTab()
	end
	
	UpdateFromConvars()
	self.plycol.ValueChanged = function( self, color )
		RunConsoleCommand( "abdul_playercolor", tostring( self:GetVector() ) )
	end
	self.PanelSelect.OnActivePanelChanged = function( old, new )
		if old != new then
			RunConsoleCommand( "abdul_playerbodygroups", "0" )
			RunConsoleCommand( "abdul_playerskin", "0" )
		end
		timer.Simple( 0.1, function() UpdateFromConvars() end )
	end
	self:AddButton( "Close", function( button ) 
		if mainmenu.panel.CURRENT_WINDOW then 
			mainmenu.panel.CURRENT_WINDOW:Remove()
			mainmenu.panel.CURRENT_WINDOW = nil
		end
	end, 32 )
end
function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color(20,22,25,250) )
end
function PANEL:AddButton( name, func, h )
	local pnl = vgui.Create("AGUI.MenuButton",self)
	pnl.Text = name
	pnl:Dock( BOTTOM )
	pnl:SetTall( h )
	pnl.DoClick = function( self )
		func( self )
	end
	pnl:DockMargin( 5, 5, 5, 5 )
end
function PANEL:PerformLayout()
	local s_w, s_h = ScreenScale(320), self.PanelList:GetCanvas():GetTall() + 32

	self:SetPos( s_w/3.7 + 1, s_h/7 + 1 )
	self:SetSize( s_w - s_w/3.7, s_h )
	self:Center()
	self.mdl:Dock( LEFT )
	self.mdl:SetWide(ScreenScale(60))
	self.mdl:DockMargin( 5, 5, 5, 5 )
	self.mdl:SetTall( self:GetTall())
	self.PanelList:Dock( FILL )
	self.PanelList:DockMargin( 5,5,5,5)
	self.PanelList2:SetTall( self.PanelList2:GetCanvas():GetTall() )
	self.PanelList:SetTall( self.PanelList:GetCanvas():GetTall() + 32)
end
vgui.Register( "AGUI.PlayerSettings", PANEL, "Panel" )

PANEL = {}
function PANEL:Init()
	self:SetTextColor( Color(200,200,200,255) )
	self:SetText("")
	self.CursorEntered = false
	self.Text = ""
	self:SetTall(ScreenScale(16))
end
function PANEL:Paint( w, h )
	local colorgray = self:GetDisabled() and Color(50,50,50,200) or Color(0,0,0,200)
	local color = self.CursorEntered and Color(100 - colorgray.r,102 - colorgray.g,105 - colorgray.b,200) or Color(80 - colorgray.r,82 - colorgray.g,85 - colorgray.b,200)
	draw.RoundedBox( 0, 0, 0, w, h, color )
	draw.DrawAbdulText( self.Text, "MenuButton", "MenuButton_blur", w/2, h/2, Color(255 - colorgray.r,255 - colorgray.g,255 - colorgray.b,255), 1, 1, 0 )
end
function PANEL:OnCursorEntered()
	self.CursorEntered = true
end
function PANEL:OnCursorExited()
	self.CursorEntered = false
end
vgui.Register( "AGUI.MenuButton", PANEL, "DButton" )

PANEL = {}
function PANEL:Init()
	self.CURRENT_WINDOW = nil
	self.Buttons = {}
	self:AddButton( "Abdul Settings", function( button ) 
		if self.CURRENT_WINDOW then return end
		
		local frame = vgui.Create("AGUI.AbdulSettings")
		frame:Center()
		
		self.CURRENT_WINDOW = frame
	end )
	self:AddButton( "Railgun Settings", function( button ) 
		if self.CURRENT_WINDOW then return end
		
		local frame = vgui.Create("AGUI.RailgunSettings")
		frame:Center()
		
		self.CURRENT_WINDOW = frame
	end )
	self:AddButton( "Player Settings", function( button ) 
		if self.CURRENT_WINDOW then return end
		
		local frame = vgui.Create("AGUI.PlayerSettings")
		frame:Center()
		
		self.CURRENT_WINDOW = frame
	end )
	self:AddButton( "Join Game", function( button ) 
		RunConsoleCommand("teamgame")
		RunConsoleCommand("showabdulmenu")
	end, function( button )
		if LocalPlayer():IsSpectator() then
			if button:GetDisabled() then button:SetDisabled( false ) end
		else
			if !button:GetDisabled() then button:SetDisabled( true ) end
		end
	end	)
	self:AddButton( "Join Spectator", function( button ) 
		RunConsoleCommand("teamspec")
		RunConsoleCommand("showabdulmenu")
	end, function( button )
		if LocalPlayer():IsSpectator() then
			if !button:GetDisabled() then button:SetDisabled( true ) end
		else
			if button:GetDisabled() then button:SetDisabled( false ) end
		end
	end	 )
	self:AddButton( "Credits", function( button ) 
		if self.CURRENT_WINDOW then return end
		
		local frame = vgui.Create("AGUI.Credits")
		frame:Center()
		
		self.CURRENT_WINDOW = frame
	end )
	self:AddButton( "Close", function( button ) 
		RunConsoleCommand("showabdulmenu")
	end )
end
function PANEL:AddButton( name, func, disablecheck )
	local pnl = vgui.Create("AGUI.MenuButton",self)
	pnl.Text = name
	pnl.DoClick = function( self )
		func( self )
	end
	pnl.Think = function( self )
		if disablecheck then
			disablecheck( self )
		end
	end
	table.insert( self.Buttons, pnl )
end
function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0,240) )
end
function PANEL:PerformLayout()
 	local w = ScreenScale(100)
    local h = 5 + (5 + ScreenScale(16))*table.Count(self.Buttons)
    self:SetSize( w, h )
    self:SetPos( ScrW()/2 - w/2, ScrH()/2 - h/2 )
	
	for k,v in pairs( self.Buttons ) do
		local i = k - 1
		v:SetWide( w - 10 )
		v:SetPos( 5, 5 + (5 + ScreenScale(16))*i )
	end
end
function PANEL:Think()
	self:PerformLayout() 
end
function PANEL:ApplySchemeSettings() end
vgui.Register( "AGUI.Menu", PANEL, "Panel" )

function mainmenu.Remove()
   if mainmenu.panel then
      mainmenu.panel:Remove()
      mainmenu.panel = nil
   end
end
function mainmenu.Create()
   mainmenu.panel = vgui.Create("AGUI.Menu")
end

mainmenu.Remove()

concommand.Add("showabdulmenu",function()
	if not mainmenu.panel then
		mainmenu.Create()
		gui.EnableScreenClicker(true)
		mainmenu.panel:SetVisible(true)
	else
		if mainmenu.panel.CURRENT_WINDOW then
			mainmenu.panel.CURRENT_WINDOW:Remove()
			mainmenu.panel.CURRENT_WINDOW = nil
		end
		if !mainmenu.panel:IsVisible() then
			gui.EnableScreenClicker(true)
			mainmenu.panel:SetVisible(true)
		else
			gui.EnableScreenClicker(false)
			mainmenu.panel:SetVisible(false)
		end
	end
end)