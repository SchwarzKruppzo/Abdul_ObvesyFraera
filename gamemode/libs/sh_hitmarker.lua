if CLIENT then
	local m_iAlpha = 255
	local m_bHit = false
	local m_iFuck = 0
	
	function DrawHitmarker()
		local LP = LocalPlayer()

		m_bHit = true
		m_iFuck = 1
		m_iAlpha = 255
	end
	
	hook.Add( "HUDPaint", "HITMARKER.LIB.HOOK", function()
		local LP = LocalPlayer()
		if m_bHit then
			surface.PlaySound( "hit.wav" )
			m_bHit = false
			m_iFuck = 1
		end
		if not m_iFuck == 1 then
			m_iAlpha = 0
		end
		if !LP:Alive() then m_iAlpha = 0 return end
			
		m_iAlpha = m_iAlpha - (255/0.5) * FrameTime()
		m_iAlpha = math.Clamp( m_iAlpha, 0, 255 )
		if m_iAlpha == 0 then m_iFuck = 0 end
		local x = ScrW() / 2
		local y = ScrH() / 2
		surface.SetDrawColor( 255, 255, 255, m_iAlpha )
		surface.DrawLine( x - 8, y - 6, x - 12*2, y - 11*2 )
		surface.DrawLine( x + 6, y - 6, x + 11*2, y - 11*2 )
		surface.DrawLine( x - 8, y + 6, x - 12*2, y + 11*2 )
		surface.DrawLine( x + 6, y + 6, x + 11*2, y + 11*2 )
	end )
	net.Receive( "abdul_net.HitMarker", DrawHitmarker)
else
	util.AddNetworkString( "abdul_net.HitMarker" )

	local function Clk( target, dmginfo, ply, hitgroup )
		if not dmginfo:GetAttacker():IsPlayer() then return end
		local attacker = dmginfo:GetAttacker()
		if target:IsValid() then
			if attacker == target then return end
			if attacker:IsPlayer() and target:Health() > 0 then
				if !hook.Run("PlayerFriendly", attacker, target ) then
					net.Start("abdul_net.HitMarker")
					net.Send( attacker )
				end
			end
		end
	end
	hook.Add( "EntityTakeDamage", "HITMARKER.LIB.HOOK", Clk )
end
