local SetDrawColor = surface.SetDrawColor
local DrawRect = surface.DrawRect
local SetMaterial = surface.SetMaterial
local DrawTexturedRect = surface.DrawTexturedRect
local DrawRect = surface.DrawRect
local DrawCircle = surface.DrawCircle

local m_tCrosshairs = {}

local function DrawRailgunCrosshair()
	local x = CrosshairTrace.DrawX
	local y = CrosshairTrace.DrawY
	
	DrawCircle( x, y, ScreenScale(4.8), Color(255,255,255))
	DrawCircle( x, y, ScreenScale(4.8) + 0.9, Color(0,0,0))
	
	SetDrawColor(0,0,0,255)
	DrawRect( x + ScreenScale(5) + 1, y - 1, ScreenScale(5), 3 )
	DrawRect( x - ScreenScale(10), y - 1, ScreenScale(5), 3 )
	
	SetDrawColor(255,255,255,255)
	DrawRect( x + ScreenScale(5), y, ScreenScale(5), 1 )
	DrawRect( x - ScreenScale(10) + 1, y, ScreenScale(5), 1 )
end
local function DrawRocketCrosshair( offset, size )
	local x = CrosshairTrace.DrawX
	local y = CrosshairTrace.DrawY
	
    local gap2 = 0
    local cl = 8 + size
    local gap = 8 + offset
	
    SetDrawColor(0,0,0,255)
	DrawRect(x - 3 - gap2 - cl - gap, y + 2 + gap, 3, cl + 2 + gap2)
    DrawRect(x - 3 - gap2 - cl - gap, y + 1 + gap + cl, cl + 2 + gap2, 3)
	SetDrawColor(255,255,255,255)
	DrawRect(x - 2 - gap2 - cl - gap, y + 3 + gap, 1, cl + gap2)
    DrawRect(x - 2 - gap2 - cl - gap, y + 2 + gap + cl, cl + gap2, 1)
    
    SetDrawColor(0,0,0,255)
	DrawRect(x - 3 - gap2 - cl - gap, y - cl - gap2 - 3 - gap, 3, cl + 2 + gap2)
    DrawRect(x - 3 - gap2 - cl - gap, y - cl - gap2 - 3 - gap, cl + 2 + gap2, 3)
	SetDrawColor(255,255,255,255)
	DrawRect(x - 2 - gap2 - cl - gap, y - cl - gap2 - 2 - gap, 1, cl + gap2)
    DrawRect(x - 2 - gap2 - cl - gap, y - cl - gap2 - 2 - gap, cl + gap2, 1)
    
    SetDrawColor(0,0,0,255)
	DrawRect(x + 1 + gap2 + cl + gap, y + 2 + gap, 3, cl + 2 + gap2)
	DrawRect(x + 2 + gap2 + gap, y + 1 + gap + cl, cl + 2 + gap2, 3)
	SetDrawColor(255,255,255,255)
	DrawRect(x + 2 + gap2 + cl + gap, y + 3 + gap, 1, cl + gap2)
    DrawRect(x + 3 + gap2 + gap, y + 2 + gap + cl, cl + gap2, 1)
    
    SetDrawColor(0,0,0,255)
	DrawRect(x + 1 + gap2 + cl + gap, y - cl - gap2 - 3 - gap, 3, cl + 2 + gap2)
    DrawRect(x + 2 + gap2 + gap, y - cl - gap2 - 3 - gap, cl + 2 + gap2, 3)
	SetDrawColor(255,255,255,255)
	DrawRect(x + 2 + gap2 + cl + gap, y - cl - gap2 - 2 - gap, 1, cl + gap2)
    DrawRect(x + 3 + gap2 + gap, y - cl - gap2 - 2 - gap, cl + gap2, 1)

end
local function DrawShotgunCrosshair( offset, size )
	local x = CrosshairTrace.DrawX
	local y = CrosshairTrace.DrawY
	
	DrawCircle( x, y, ScreenScale(size), Color(255,255,255))
	DrawCircle( x, y, ScreenScale(size) + 1, Color(0,0,0))
end
local function DrawBulletCrosshair( offset, size )
	local x = CrosshairTrace.DrawX
	local y = CrosshairTrace.DrawY
    local gap2 = 0
    local cl = 8 + size
    local gap = 12 + offset
	
	SetDrawColor(0,0,0,255)
    DrawRect(x - 3 - gap2 - cl - gap, y - 1, cl + 2 + gap2, 3)
    SetDrawColor(255,255,255,255)
    DrawRect(x - 2 - gap2 - cl - gap, y, cl + gap2, 1)
    
    SetDrawColor(0,0,0,255)
	DrawRect(x + 2 + gap, y - 1, cl + 2 + gap2, 3)
	SetDrawColor(255,255,255,255)
	DrawRect(x + 3 + gap, y, cl + gap2, 1)

	SetDrawColor(0,0,0,255)
	DrawRect(x - 1, y + 2 + gap, 3, cl + 2 + gap2)
	SetDrawColor(255,255,255,255)
	DrawRect(x, y + 3 + gap, 1, cl + gap2)
				
	SetDrawColor(0,0,0,255)
	DrawRect(x - 1, y - cl - gap2 - 3 - gap, 3, cl + 2 + gap2)
	SetDrawColor(255,255,255,255)
	DrawRect(x, y - cl - gap2 - 2 - gap, 1, cl + gap2)
end


m_tCrosshairs["rail"] = DrawRailgunCrosshair
m_tCrosshairs["auto"] = DrawBulletCrosshair
m_tCrosshairs["rocket"] = DrawRocketCrosshair
m_tCrosshairs["shotgun"] = DrawShotgunCrosshair

local function DrawCrosshairs()
	local LP = LocalPlayer()
	CrosshairTraceData = {}
	CrosshairTraceData.start = LP:GetShootPos()
	CrosshairTraceData.endpos = CrosshairTraceData.start + (LP:EyeAngles()):Forward() * 16384
	CrosshairTraceData.filter = LP
	CrosshairTrace = util.TraceLine(CrosshairTraceData)
	CrosshairTrace.DrawPos = CrosshairTrace.HitPos:ToScreen()
	CrosshairTrace.DrawX = math.Round(CrosshairTrace.DrawPos.x,0.5)
	CrosshairTrace.DrawY = math.Round(CrosshairTrace.DrawPos.y,0.5)
	
	local Weapon = LP:GetActiveWeapon()
	if LP:IsSpectator() then return end
	if !LP:Alive() then return end
	if !IsValid( Weapon ) then return end
	
	if m_tCrosshairs[ Weapon.CrosshairType ] then
		local offset = Weapon.CrosshairGap or 0
		local size = Weapon.CrosshairSize or 0
		m_tCrosshairs[ Weapon.CrosshairType ]( offset, size)
	else
		
	end
	
	DrawCircle( CrosshairTrace.DrawX, CrosshairTrace.DrawY, ScreenScale(0.1), Color(255,60,60,255))
end
hook.Add( "HUDPaint", "CROSSHAIR.LIB.HOOK", DrawCrosshairs )