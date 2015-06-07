include( "shared.lua" )
DEFINE_BASECLASS( "gamemode_base" )

CreateConVar( "abdul_enablecommentary", "1", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "Abdul voice" )
CreateConVar( "abdul_autoswitchweapon", "1", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "Auto switch to best weapon when picking up weapon" )

for k, v in pairs( vgui.GetWorldPanel():GetChildren() ) do
	if v:GetName():find("AGUI") then
		v:Remove()
		gui.EnableScreenClicker( false )
	end
end


function GM:Initialize()
	BaseClass.Initialize( self )
end


function GM:InitPostEntity()
	BaseClass.InitPostEntity( self )
end


function GM:HUDDrawTargetID()
     return false
end


function GM:DrawDeathNotice( x, y )
	return
end


local hudtohide = {"CHudHealth","CHudBattery","CHudCrosshair","CHudAmmo","CHudZoom","CHudSecondaryAmmo"}
function GM:HUDShouldDraw( name )
	if table.HasValue( hudtohide, name ) then return false end
	return true
end

function GM:HUDPaintBackground()
	local m_tColor = hook.Run("GetVignetteColor")
	surface.SetDrawColor( m_tColor )
	surface.SetMaterial( Material("abdul/hudnette.png") )
	surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
end
function GM:HUDPaint()
	hook.Run("HUDMain")
end


function GM:GetVignetteColor()
	return Color(255,255,255,180)
end


function GM:PostDrawViewModel( vm, ply, weapon )
	if ( weapon.UseHands || !weapon:IsScripted() ) then
		local hands = LocalPlayer():GetHands()
		if ( IsValid( hands ) ) then hands:DrawModel() end
	end
end

net.Receive("abdul_net.PlayerSpawn",function()
	hook.Run("OnPlayerSpawned")
end)
net.Receive("abdul_net.PlayerInitialSpawn",function()
	hook.Run("OnPlayerInitialSpawned")
end)
net.Receive("abdul_net.PlayerDeath",function()
	hook.Run("MLG.fx.OnDeath")
end)
net.Receive("abdul_net.OnKill",function()
	hook.Run("MLG.fx.OnKill")
end)


function GM:OnPlayerSpawned() end
function GM:OnPlayerInitialSpawned() end

function GM:PlayerTick( ply, cmd )
	BaseClass.PlayerTick( ply, cmd )
	
	local m_iLimit = 35
	local m_iSpeed = 1.05
	
	
	if IsValid( ply:GetActiveWeapon() ) then
		if ply:GetActiveWeapon():GetClass() == "abdul_awm" then
			m_iLimit = 65
			m_iSpeed = 0.8
		end
	end
	
	
	if ply:KeyDown( IN_ATTACK2 ) then
		if !ply.m_iZoomFov then ply.m_iZoomFov = 0 end
		ply.m_iZoomFov = ply.m_iZoomFov + 1/m_iSpeed
		ply.m_iZoomFov = math.Clamp( ply.m_iZoomFov, 0, m_iLimit )
	elseif !ply:KeyDown( IN_ATTACK2 ) then
		if !ply.m_iZoomFov then ply.m_iZoomFov = 0 end
		ply.m_iZoomFov = ply.m_iZoomFov - 1/m_iSpeed
		ply.m_iZoomFov = math.Clamp( ply.m_iZoomFov, 0, m_iLimit )
	end
end



local viewDelta = 0
local viewSide = 0
local viewValue = 0
local viewTime = 0
local viewOldY = nil
local viewDelta2 = 0
local viewSide2 = 0
local viewValue2 = 0
local viewTime2 = 0
local viewOldP = 0

function NormalizeAngle( a )
    a = math.Round(a)%360
    if a > 180 then
        a = a - 360
    end
    return a
end

function CalcViewRollY( y )
	local modifyY = y

	if !viewOldY then viewOldY = modifyY end
	if !viewTime then viewTime = CurTime() + 0.01 end

	if CurTime() > viewTime then
		viewDelta = math.Round(NormalizeAngle(viewOldY - modifyY),4)
		viewSide = viewDelta
		viewSide = math.Clamp( viewSide, -2, 2 )
		viewOldY = modifyY
		viewTime = CurTime() + 0.01
	end
	viewValue = math.Round(Lerp( 0.1, viewValue, viewSide*2),4)

	return viewValue
end
function CalcViewRollP( p )
	local modifyP = p
	
	if !viewOldP then viewOldP = modifyP end
	if !viewTime2 then viewTime2 = CurTime() + 0.01 end

	if CurTime() > viewTime2 then
		viewDelta2 = math.Round(viewOldP - modifyP,4)
		viewSide2 = viewDelta2
		viewSide2 = math.Clamp( viewSide2, -15, 15 )
		viewOldP = modifyP
		viewTime2 = CurTime() + 0.01
	end
	viewValue2 = math.Round(Lerp( 0.01,viewValue2, viewSide2*1.5),4)

	return viewValue2
end

local function CalcRoll( ang, vel, fl, speed )
	if LocalPlayer():IsSpectator() then return 0 end
	
	local m_iSign;
    local m_iSide;
    local m_iValue;
	local forward = ang:Forward()
	local right = ang:Right()
	local up = ang:Up()

    m_iSide = vel:DotProduct( right )
	
    m_iSign = m_iSide < 0 and -1 or 1
    m_iSide = math.abs(m_iSide)
    
	m_iValue = fl;
    if m_iSide < speed then
		m_iSide = m_iSide * m_iValue / speed;
    else
		m_iSide = m_iValue;
	end
    return m_iSide*m_iSign;
end

function GM:CalcView( ply, pos, ang, fov, nearZ, farZ )
	if !IsValid( ply ) then return end
	if !ply.m_iZoomFov then ply.m_iZoomFov = 0 end
	
    local view = {}
	local side = CalcRoll( ply:GetAngles(), ply:GetVelocity(), 3, 300 );
	
	local view_side = CalcViewRollY( ang.y )
	
    view.origin = pos
	
	ang:RotateAroundAxis(ang:Forward(),side)
	ang.r = ang.r + view_side
	
    view.angles = ang
    view.fov = 75 - ply.m_iZoomFov
	
    return view
end

function CalcView_SuppressPunch( wep, vm, oldPos, oldAng, pos1, ang1 )

	if !IsValid( wep ) then return end
	if LocalPlayer():Alive() then
		local view_size = -CalcViewRollP( LocalPlayer():EyeAngles().p )
		local vm_angles = ang1
		local vp_angles = -LocalPlayer():GetViewPunchAngles()
		local vp_p = vp_angles.p/2
		local vp_y = vp_angles.y/2
		local vp_r = vp_angles.r/2
		vm_angles.p = math.Round(vm_angles.p + vp_p + view_size,4)
		vm_angles.y = math.Round(vm_angles.y + vp_y,4)
		vm_angles.r = math.Round(vm_angles.r + vp_r,4)
	end

end
hook.Add("CalcViewModelView","SUPPRESSPUNCH.GM.HOOK",CalcView_SuppressPunch)