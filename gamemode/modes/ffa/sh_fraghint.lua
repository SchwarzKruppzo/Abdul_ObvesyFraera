if SERVER then
	util.AddNetworkString( "abdul_net.Fragged" )
	hook.Add( "PlayerDeath", "FRAGHINT.LIB.HOOK", function( victim, inflictor, attacker )
		if victim ~= attacker then
			net.Start( "abdul_net.Fragged" )
				net.WriteString( victim:Nick() )
				net.WriteString( inflictor:GetClass() )
			net.Send( attacker )
		end
	end )
else
	local getTextSize = surface.GetTextSizeEx
	
	function GM:ShouldFragHintDraw()
		return true
	end
	
	local m_iFragHintTime = 0
	local m_iFragHint = false
	local m_iFragHintNick = ""
	local m_iFragHintNextTime = 0
	local m_iFragHintShow = false
	local m_iFragHintWeapon = nil
	
	net.Receive( "abdul_net.Fragged", function( len )
		m_iFragHint = true
		m_iFragHintTime = CurTime() + 0.5
		m_iFragHintNick = net.ReadString()
		m_iFragHintWeapon = net.ReadString()
		m_iFragHintNextTime = CurTime() + 8
		m_iFragHintShow = true
	end)
	
	m_tPlacePrefix = {}
	m_tPlacePrefix[1] = { pref = "st", color = Color(40,70,255,255) }
	m_tPlacePrefix[2] = { pref = "nd", color = Color(225,100,100,255) }
	m_tPlacePrefix[3] = { pref = "rd", color = Color(225,225,100,255) }
	m_tPlacePrefix[4] = { pref = "th", color = Color(255,255,255,255) }
	
	
	local function DrawFragHint()
		if !hook.Run("ShouldFragHintDraw") then return end
		
		if m_iFragHint then
			if m_iFragHintTime > CurTime() then
				
			else
				m_iFragHint = false
			end
		end
		if m_iFragHintShow then
			if m_iFragHintNextTime > CurTime() then
				local m_iPlace = LocalPlayer():GetPlace()
				local m_tPlace = m_tPlacePrefix[ m_iPlace ] or m_tPlacePrefix[4]
				local text = "You fragged " .. m_iFragHintNick
				local w,h2 = getTextSize( text, "AFont_Frag" )
				draw.DrawAbdulText( "You fragged " .. m_iFragHintNick, "AFont_Frag", "AFont_Frag_blur",  ScrW()/2, ScrH()/3, Color(255,255,255,255), 1, 0, 0 )

				local text1 = m_iPlace .. m_tPlace.pref
				local text2 = " place with " .. LocalPlayer():Frags()
			
				local w1,h = getTextSize( text1, "AFont_Frag2" )
				local w2,h = getTextSize( text2, "AFont_Frag2" )
				local w3,h = getTextSize( text1 .. text2, "AFont_Frag2" )
				
				local x = ScrW()/2 - ( w1 + w2 )/2
				draw.DrawAbdulText( text1, "AFont_Frag2", "AFont_Frag2_blur",  x, ScrH()/3 + h2 + 2, m_tPlace.color, 0, 0, 0 )
				local x = x + w1
				draw.DrawAbdulText( text2, "AFont_Frag2", "AFont_Frag2_blur",  x, ScrH()/3 + h2 + 2, Color(255,255,255,255), 0, 0, 0 )
			else
				m_iFragHintShow = false
			end
		end
	end
	hook.Add( "HUDPaint", "FRAGHINT.LIB.HOOK", DrawFragHint )
end