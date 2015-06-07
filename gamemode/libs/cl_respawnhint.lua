local getTextSize = surface.GetTextSizeEx

local function DrawRespawnHint()
	local LP = LocalPlayer()
	local RespawnTime = LP:GetNWInt("NextRespawnTime") - CurTime()
	
	if LP:Alive() then return end
	if LP:GetNWBool("CanSpawn") then
		local text1 = "Press "
		local text2 = "[PRIMARY FIRE]"
		local text3 = " to force spawn."
	
		local w1,h = getTextSize( text1, "AFont_Respawn" )
		local w2,h = getTextSize( text2, "AFont_Respawn" )
		local w3,h = getTextSize( text3, "AFont_Respawn" )
		local w4,h = getTextSize( text1 .. text2 .. text3, "AFont_Respawn" )
		
		local x = ScrW()/2 - ( w1 + w2 + w3 )/2
		draw.DrawAbdulText( text1, "AFont_Respawn", "AFont_Respawn_blur",  x, ScrH()/1.35 - h, Color(255,255,255,255), 0, 0, 0 )
		local x = x + w1
		draw.DrawAbdulText( text2, "AFont_Respawn", "AFont_Respawn_blur",  x, ScrH()/1.35 - h, Color(255,110,110,255), 0, 0, 0 )
		local x = x + w2
		draw.DrawAbdulText( text3, "AFont_Respawn", "AFont_Respawn_blur",  x, ScrH()/1.35 - h, Color(255,255,255,255), 0, 0, 0 )
	end
	if LP:GetNWInt( "NextRespawnTime") && LP:GetNWInt( "NextRespawnTime") > CurTime() then
		local text = "Respawning in " .. math.floor( RespawnTime ) .. " seconds..."
		local w,h = getTextSize( text, "AFont_Respawn" )

		draw.DrawAbdulText( text, "AFont_Respawn", "AFont_Respawn_blur",  ScrW()/2, ScrH() - h - 5, Color(255,255,255,255), 1, 0, 0 )
	end
end
hook.Add( "HUDPaint", "RESPAWNHINT.LIB.HOOK", DrawRespawnHint )
