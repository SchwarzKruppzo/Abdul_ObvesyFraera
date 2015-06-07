abdulmode.Include( "shared.lua" )
abdulmode.Include( "cl_mlgeffects.lua" )
abdulmode.Include( "derma/scoreboard/main.lua" )
abdulmode.Include( "derma/menu/main.lua" )

surface.CreateFont( "AFont_Indicator",{
	font = "Russo One",
	size = ScreenScaleEx(24),
	weight = 400,
	antialias = true
})
surface.CreateFont( "AFont_Indicator_blur",{
	font = "Russo One",
	size = ScreenScaleEx(24),
	weight = 400,
	blursize = 3
})
surface.CreateFont( "AFont_Indicator2",{
	font = "Russo One",
	size = ScreenScaleEx(18),
	weight = 400,
	antialias = true
})
surface.CreateFont( "AFont_Indicator2_blur",{
	font = "Russo One",
	size = ScreenScaleEx(18),
	weight = 400,
	blursize = 3
})
surface.CreateFont( "AFont_Indicator1",{
	font = "Russo One",
	size = ScreenScaleEx(24),
	weight = 400,
	antialias = true
})
surface.CreateFont( "AFont_Indicator1_blur",{
	font = "Russo One",
	size = ScreenScaleEx(24),
	weight = 400,
	blursize = 3
})
surface.CreateFont( "AFont_Indicator3",{
	font = "Russo One",
	size = ScreenScaleEx(30),
	weight = 400,
	antialias = true
})
surface.CreateFont( "AFont_Indicator3_blur",{
	font = "Russo One",
	size = ScreenScaleEx(30),
	weight = 400,
	blursize = 3
})

local MAT_GRADIENT_L = Material("gui/gradient")

function DrawPlayerNames()
	local LP = LocalPlayer()
	for k,v in pairs( player.GetAll() ) do
		if v == LP then continue end
		if !v:Alive() then continue end
		if v:GetPos():Distance( LP:GetPos() ) > 700 then continue end
		if not v.NickDrawPixelHandle then
			v.NickDrawPixelHandle = util.GetPixelVisibleHandle()
		end
		local headpos = v:GetPos()
		if v:LookupBone("ValveBiped.Bip01_Head1") then
			headpos=v:GetBonePosition( v:LookupBone("ValveBiped.Bip01_Head1") ) + v:GetUp()*16
		end
		
		local vNorm = headpos - EyePos()
		local dist = vNorm:Length()
		vNorm:Normalize()
		local vDot = 1
		local nickPos = headpos
		local nPos = headpos:ToScreen()
		if ( vDot >= 0 ) then
			local vis	= util.PixelVisible( nickPos, 1, v.NickDrawPixelHandle )	
			if (!vis) then return end
			dist = math.Clamp( dist, 32, 700 )

			local Alpha = math.Clamp( (700 - dist) * vis , 0, 255 )
			
			draw.DrawAbdulText( v:Nick(), "AFont_PlyIndicator", "AFont_PlyIndicator_blur", nPos.x, nPos.y, Color(0,200,255,Alpha), 1, 0, Alpha + 100 )
		end
	end
end

local m_iFightT = CurTime() + 1
function DrawGameState()
	local x = ScrW()/2
	local y = ScrH()/3.2
	local w_pf,h_pf = surface.GetTextSizeEx("P","AFont_GameState1_blur")
	
	
	if GetGameState() == GS_ROUND_PREPARE then
		draw.DrawAbdulText( "PREPARE TO FIGHT", "AFont_GameState1", "AFont_GameState1_blur", x, y, Color(255,255,255,255), 1, 0, 0 )
		draw.DrawAbdulText( math.Round(GetRoundTime(),0), "AFont_GameState2", "AFont_GameState2_blur", x, y + h_pf + 5, Color(255,255,0,255), 1, 0, 0 )

		m_iFightT = CurTime() + 1
	elseif GetGameState() == GS_ROUND_PLAYING then
		if m_iFightT > CurTime() then
			local y = ScrH()/2.5
			draw.DrawAbdulText( "FIGHT!", "AFont_GameState2", "AFont_GameState2_blur", x, y, Color(255,255,255,255), 1, 0, 0 )
		end
	elseif GetGameState() == GS_ROUND_END then
		draw.DrawAbdulText( "Round "..GetRound().." is over", "AFont_GameState1", "AFont_GameState1_blur", x, y , Color(255,255,255,255), 1, 0, 0 )
		draw.DrawAbdulText( player.GetSortedPlayers()[1]:Nick().." won", "AFont_GameState2", "AFont_GameState2_blur", x, y + h_pf + 5, Color(220,255,220,255), 1, 0, 0 )
	elseif GetGameState() == GS_GAME_OVER then
		draw.DrawAbdulText( "All rounds is over", "AFont_GameState1", "AFont_GameState1_blur", x, y , Color(255,255,255,255), 1, 0, 0 )
		draw.DrawAbdulText( player.GetSortedPlayers()[1]:Nick().." won", "AFont_GameState2", "AFont_GameState2_blur", x, y + h_pf + 5, Color(220,255,220,255), 1, 0, 0 )
	end
end

function MODE:HUDPaint()
	local round_t = "Round"
	local round = GetRound()
	local timer_t = "Round Time"
	local timert = GetRoundTime()
	local frags_t = "Frags Remaining"
	local frags = GetFragsRemaining()
	local lead_t = "Leading"
	local lead = "No one"
	if #player.GetSortedPlayers() >= 1 then
		lead = player.GetSortedPlayers()[1]:Nick()
	end
	
	if #lead > 24 then
		lead = string.Left(lead, 21).."..."
	end
	
	local w_round, h_round = surface.GetTextSizeEx(round,"AFont_Indicator_blur")
	local w_timer_t, h_timer_t = surface.GetTextSizeEx(timer_t,"AFont_Indicator_blur")
	local w_timert, h_timert = surface.GetTextSizeEx(timert,"AFont_Indicator_blur")
	local w_fragst, h_fragst = surface.GetTextSizeEx(frags_t,"AFont_Indicator2_blur")
	local w_frags, h_frags = surface.GetTextSizeEx(frags,"AFont_Indicator_blur")
	local w_lead_t, h_lead_t = surface.GetTextSizeEx(lead_t,"AFont_Indicator2_blur")
	local w_lead, h_lead = surface.GetTextSizeEx(lead,"AFont_Indicator_blur")
	local total = h_round + h_timer_t + h_timert + h_fragst + h_frags + h_lead_t + h_lead + 40
	local y = 5
	
	if GetGameState() != 0 then
		surface.SetMaterial(MAT_GRADIENT_L)
		surface.SetDrawColor(Color(0,0,0,200))
		surface.DrawTexturedRect(0,0,ScreenScaleEx(140),total)
		
		draw.DrawAbdulText( round_t, "AFont_Indicator2", "AFont_Indicator2_blur",  5, y, Color(210,240,240,255), 0, 0, 0 )
		y = h_round
		draw.DrawAbdulText( round, "AFont_Indicator", "AFont_Indicator_blur",  10, y, Color(255,255,255,255), 0, 0, 0 )
		y = y + h_timer_t + 5
		draw.DrawAbdulText( timer_t, "AFont_Indicator2", "AFont_Indicator2_blur",  5, y, Color(210,240,240,255), 0, 0, 0 )
		y = y + h_timert - 5
		draw.DrawAbdulText( os.date( "%M:%S", GetRoundTime() ), "AFont_Indicator", "AFont_Indicator_blur",  10, y, Color(255,255,255,255), 0, 0, 0 )
		y = y + h_fragst + 10
		draw.DrawAbdulText( frags_t, "AFont_Indicator2", "AFont_Indicator2_blur",  5, y, Color(210,240,240,255), 0, 0, 0 )
		y = y + h_frags - 5
		draw.DrawAbdulText( frags, "AFont_Indicator", "AFont_Indicator_blur",  10, y, Color(255,255,255,255), 0, 0, 0 )
		y = y + h_lead_t + 10
		draw.DrawAbdulText( lead_t, "AFont_Indicator2", "AFont_Indicator2_blur",  5, y, Color(210,240,240,255), 0, 0, 0 )
		y = y + h_lead - 5
		draw.DrawAbdulText( lead, "AFont_Indicator", "AFont_Indicator_blur",  10, y, Color(255,255,255,255), 0, 0, 0 )
	end
	
	if GetGameState() == 0 then
		draw.DrawAbdulText( "Waiting for additional players", "AFont_Indicator3", "AFont_Indicator3_blur", ScrW()/2,ScrH()/5, Color(255,60,60,255), 1, 0, 0 )
	end
	
	DrawPlayerNames()
	DrawGameState()
end
function GM:OnGameStateChanged( gamestate )
	if !IsValid(LocalPlayer()) then return end
	
	
	if gamestate == GS_ROUND_PREPARE then
		LocalPlayer():EmitSound("abdul/prepare.wav")
	elseif gamestate == GS_ROUND_PLAYING then
		LocalPlayer():EmitSound("abdul/fight.wav")
		hook.Run("MLG.fx.OnFight")
	end
end
function MODE:Think() end

m_bPlayRoundMusicWinState = false

net.Receive("abdul_net.RoundMusicWin",function()
	local i = net.ReadInt(32)
		if !m_bPlayRoundMusicWinState then
		local sound = "abdul/music/music"..tostring(i)..".mp3"
		LocalPlayer():EmitSound( Sound( sound ), 80, 100 )
		m_bPlayRoundMusicWinState = true
		local time = SoundDuration( sound )
		timer.Create( tostring(LocalPlayer():EntIndex()).."RoundMusic",time, 1, function()
			if IsValid(LocalPlayer()) then m_bPlayRoundMusicWinState = false end
		end)
		hook.Run("MLG.fx.OnRoundWin")
	end
end)
net.Receive("abdul_net.Lead",function( len )
	if !LocalPlayer() then return end
	
	local isLeading = net.ReadBool()
	if isLeading then
		LocalPlayer():EmitSound("abdul/takenlead.wav")
		hook.Run("MLG.fx.OnTakenLead")
	else
		LocalPlayer():EmitSound("abdul/lostlead.wav")
		hook.Run("MLG.fx.OnLostLead")
	end
end)
net.Receive("abdul_net.GameStateChanged",function( len )
	local gamestate = tonumber( net.ReadString() )

	hook.Run("OnGameStateChanged", gamestate )
end)
