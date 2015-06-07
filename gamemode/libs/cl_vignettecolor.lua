gameevent.Listen( "player_hurt" )

local m_iRed = 0
local m_iFadeStart = 0
local m_iFadeEnd = 0
local m_iToy = 0

hook.Add( "player_hurt", "VIGNETTE.LIB.HOOK", function( data )
	if data.userid != LocalPlayer():UserID() then return end
	
	m_iRed = 255
	m_iToy = 5
	m_iFadeStart = UnPredictedCurTime()
	m_iFadeEnd = UnPredictedCurTime() + 0.52
	m_iFadeEnd2 = UnPredictedCurTime() + 0.25
end )
hook.Add( "GetVignetteColor", "VIGNETTE.LIB.HOOK", function()
	if m_iRed > 0 then
		m_iRed = 255 - ( math.TimeFraction( m_iFadeStart, m_iFadeEnd, UnPredictedCurTime() ) * 255 )
		m_iToy = 5 - ( math.TimeFraction( m_iFadeStart, m_iFadeEnd2, UnPredictedCurTime() ) * 5 )
		m_iRed = math.Clamp( m_iRed, 0, 255 )
		m_iToy = math.Clamp( m_iToy, 0, 5 )
	end
	return Color( 0, 0, 0 , 180 )
end )

hook.Add( "RenderScreenspaceEffects", "VIGNETTE.LIB.HOOK", function()

	if m_iRed > 0 then
		local i = math.Clamp( m_iRed/255, 0, 1 )
		local tab = {
			[ "$pp_colour_addr" ] = i, 
			[ "$pp_colour_addg" ] = 0, 
			[ "$pp_colour_addb" ] = 0, 
			[ "$pp_colour_brightness" ] = 0, 
			[ "$pp_colour_contrast" ] = 1, 
			[ "$pp_colour_colour" ] = 1, 
			[ "$pp_colour_mulr" ] = 0.2, 
			[ "$pp_colour_mulg" ] = 0, 
			[ "$pp_colour_mulb" ] = 0
		}
		DrawColorModify( tab )
		DrawToyTown( m_iToy, ScrH() )
	end	
end )