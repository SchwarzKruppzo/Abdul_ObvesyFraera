if SERVER then
	util.AddNetworkString( "abdul_net.Deathnotice" )
	hook.Add( "PlayerDeath", "DEATHNOTICE.LIB.HOOK", function( victim, inflictor, attacker )
		net.Start( "abdul_net.Deathnotice" )
			net.WriteString( victim:Nick() )
			net.WriteString( inflictor:GetClass() )
			if !IsValid( attacker ) then 
				net.WriteString( "" )
			else
				net.WriteString( attacker:Nick() )
			end
			
			net.WriteBit( victim.GotHeadshot or false )
		net.Broadcast()
	end )
else
	local m_tDeathnotes = {}
	local m_tDeathreasons = {}
	net.Receive( "abdul_net.Deathnotice", function( len )
		local victim = net.ReadString()
		local inflictor = net.ReadString()
		local attacker = net.ReadString()
		local gotheadshot = net.ReadBit()
		local tbl = {victim = victim, inflictor = inflictor, attacker = attacker, head = gotheadshot}
		table.insert( m_tDeathnotes, tbl )
	end)
	m_tDeathreasons["player"] = " suicided "
	m_tDeathreasons["abdul_railgun"] = " [%sRAILGUN] "
	m_tDeathreasons["abdul_nubogun"] = " [%sNUBOGUN] "
	m_tDeathreasons["abdul_ak47"] = " [%sKALASH] "
	m_tDeathreasons["env_explosion"] = " [%sEXPLOSION] "
	m_tDeathreasons["ent_shrap"] = " [%sMASLOCHEZATOR] "
	m_tDeathreasons["ent_shrapbomb"] = " [%sMASLOCHEZATOR] "
	m_tDeathreasons["abdul_shotgun"] = " [%sMASLOBABA] "
	m_tDeathreasons["ent_rocket"] = " [%sMASLOROCKET] "
	m_tDeathreasons["abdul_machete"] = " [%sMACHETE] "
	m_tDeathreasons["ent_claymore"] = " [%sCLAYMORE] "
	m_tDeathreasons["abdul_noscoper"] = " [%s420NOSCOPE] "
	
	local getTextSize = surface.GetTextSizeEx
	
	local function DrawDeathnotices()
		local x = ScrW() - 10
		local y = 0
		for k,v in ipairs( m_tDeathnotes ) do
			if not v.fade then 
				v.fade = CurTime() + 4
			end
			if not v.alpha then v.alpha = 255 end
			if v.fade < CurTime() then
				v.alpha = v.alpha - 64 / 20;
				v.alpha = math.Clamp( v.alpha, 0, 255 );
			end
			if k > 1 then 
				local text2_w,text2_h = getTextSize( "[", "AFont_Deathnotice" )
				y = y + text2_h
			end
			
			local m_iAlphaInverted = -v.alpha + 255
			if v.alpha ~= 0 then
				local weapon = m_tDeathreasons[ v.inflictor ] or m_tDeathreasons["player"]
				if weapon == m_tDeathreasons["player"] then
					local text1_w,text1_h = getTextSize( v.victim, "AFont_Deathnotice" )
					local text2_w,text2_h = getTextSize( weapon, "AFont_Deathnotice" )
					draw.DrawAbdulText( v.victim, "AFont_Deathnotice", "AFont_Deathnotice_blur",  x - text2_w, y, Color(120,255,120,v.alpha), 2, 0, m_iAlphaInverted )
					draw.DrawAbdulText( weapon, "AFont_Deathnotice", "AFont_Deathnotice_blur",  x, y, Color(255,255,255,v.alpha), 2, 0, m_iAlphaInverted )

				else
					if v.head == 1 then
						weapon = string.format( weapon, "HEAD - " )
					else
						weapon = string.format( weapon, "" )
					end
					local text1_w,text1_h = getTextSize( v.attacker, "AFont_Deathnotice" )
					local text2_w,text2_h = getTextSize( weapon, "AFont_Deathnotice" )
					local text3_w,text3_h = getTextSize( v.victim, "AFont_Deathnotice" )
					draw.DrawAbdulText( v.attacker, "AFont_Deathnotice", "AFont_Deathnotice_blur",  x - text2_w - text3_w, y, Color(120,255,120,v.alpha), 2, 0, m_iAlphaInverted )
					draw.DrawAbdulText( weapon, "AFont_Deathnotice", "AFont_Deathnotice_blur",  x - text3_w, y, Color(255,255,255,v.alpha), 2, 0, m_iAlphaInverted )
					draw.DrawAbdulText( v.victim, "AFont_Deathnotice", "AFont_Deathnotice_blur",  x, y, Color(0,200,255,v.alpha), 2, 0, m_iAlphaInverted )
				end
			else
				table.remove( m_tDeathnotes, k )
			end
		end
	end
	hook.Add( "HUDPaint", "DEATHNOTICE.LIB.HOOK", DrawDeathnotices )
end