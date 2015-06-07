local m_iAlpha = 0
local m_iFadeStart = 0
local m_iFadeEnd = 0

local function DrawGamemodeHint()
	if m_iAlpha > 0 then
		m_iAlpha = 255 - (math.TimeFraction(m_iFadeStart, m_iFadeEnd, UnPredictedCurTime()) * 255)
		local m_iAlphaInverted = -m_iAlpha + 255
		draw.DrawAbdulText( MODE.Name or "", "AFont_Gamemode", "AFont_Gamemode_blur",  ScrW()/2, ScrH()/8, Color(255,255,255,m_iAlpha), 1, 0, m_iAlphaInverted )

	end
end

local function ShowGamemodeHint()
	m_iAlpha = 255
	m_iFadeStart = UnPredictedCurTime() + 4
	m_iFadeEnd = UnPredictedCurTime() + 4.5
end

hook.Add( "HUDPaint", "MODEHINT.LIB.HOOK", DrawGamemodeHint )
hook.Add( "OnPlayerSpawned", "MODEHINT.LIB.HOOK", ShowGamemodeHint )
