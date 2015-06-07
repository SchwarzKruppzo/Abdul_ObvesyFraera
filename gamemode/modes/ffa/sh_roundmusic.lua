m_tSoundDuration = {}
m_tSoundDuration["roundmusic1.ogg"] = 254
m_tSoundDuration["roundmusic2.ogg"] = 101
m_tSoundDuration["roundmusic3.ogg"] = 175
m_tSoundDuration["roundmusic4.ogg"] = 242
m_tSoundDuration["roundmusic5.ogg"] = 67
m_tSoundDuration["roundmusic6.ogg"] = 217
m_tSoundDuration["roundmusic7.ogg"] = 254
m_tSoundDuration["roundmusic8.ogg"] = 177
m_tSoundDuration["roundmusic9.ogg"] = 94
m_tSoundDuration["roundmusic10.ogg"] = 203
m_tSoundDuration["roundmusic11.ogg"] = 113
m_tSoundDuration["roundmusic12.ogg"] = 133
m_tSoundDuration["roundmusic13.ogg"] = 73
m_tSoundDuration["roundmusic14.ogg"] = 221
m_tSoundDuration["roundmusic15.ogg"] = 270
m_tSoundDuration["roundmusic16.ogg"] = 198
m_tSoundDuration["roundmusic17.ogg"] = 180
m_tSoundDuration["roundmusic18.ogg"] = 173
m_tSoundDuration["roundmusic19.ogg"] = 194
m_tSoundDuration["roundmusic20.ogg"] = 244
m_tSoundDuration["roundmusic21.ogg"] = 181
m_tSoundDuration["roundmusic22.ogg"] = 208

if SERVER then
	SetGlobalBool("RoundMusicState",false)
	SetGlobalInt("RoundMusicLast",0)
	SetGlobalInt("RoundMusicCurrent",0)
	SetGlobalInt("RoundMusicStartTime",nil)
	SetGlobalInt("RoundMusicEndTime",nil)

	util.AddNetworkString("abdul_net.StartRoundMusic")
	util.AddNetworkString("abdul_net.StopRoundMusic")
	
	
	function GetRoundMusicID()
		local i = math.random(1,22)
		if i == GetGlobalInt("RoundMusicLast") then i = math.random(1,22) end
		SetGlobalInt("RoundMusicLast",i)
		return i 
	end
	
	function StartRoundMusic()
		local musicID = GetRoundMusicID()
		local CT = CurTime()
		SetGlobalInt("RoundMusicCurrent",musicID)
		SetGlobalInt("RoundMusicStartTime",CT)
		SetGlobalInt("RoundMusicEndTime",CT + m_tSoundDuration["roundmusic"..musicID..".ogg"])
		SetGlobalBool("RoundMusicState",true)
		
		timer.Simple(1, function()
			net.Start( "abdul_net.StartRoundMusic" )
			net.Broadcast()
		end)
	end
	function NextRoundMusic()
		local musicID = GetRoundMusicID()
		local CT = CurTime()
		SetGlobalInt("RoundMusicCurrent",musicID)
		SetGlobalInt("RoundMusicStartTime",CT)
		SetGlobalInt("RoundMusicEndTime",CT + m_tSoundDuration["roundmusic"..musicID..".ogg"])
		
		timer.Simple(1, function()
			net.Start( "abdul_net.StartRoundMusic" )
			net.Broadcast()
		end)
	end
	function SendRoundMusic( ply )
		local sendTime = CurTime()
		local time = (GetGlobalInt("RoundMusicEndTime") - sendTime) - GetGlobalInt("RoundMusicStartTime")

		timer.Simple(1, function()
			net.Start( "abdul_net.StartRoundMusic" )
				net.WriteString( time + 1)
			net.Send( ply )
		end)
	end
	function StopRoundMusic()
		SetGlobalInt("RoundMusicCurrent",0)
		SetGlobalInt("RoundMusicEndTime",nil)
		SetGlobalInt("RoundMusicStartTime",nil)
		SetGlobalBool("RoundMusicState",false)
		
		timer.Simple(1, function()
			net.Start( "abdul_net.StopRoundMusic" )
			net.Broadcast()
		end)
	end
	function MODE:OnGameStateChanged( int )
		if int == GS_ROUND_PLAYING then
			StartRoundMusic()
		elseif int == GS_ROUND_END or int == GS_ROUND_PREPARE or int == GS_WAITING_PLAYERS then
			StopRoundMusic()
		end
	end
	hook.Add("PlayerInitialSpawn","RoundMusic", function( ply )
		if GetGameState() == GS_ROUND_PLAYING then
			SendRoundMusic( ply )
		end
	end)
	hook.Add("Think","RoundMusic", function( ply )
		if GetGlobalBool("RoundMusicState") then
			if (GetGlobalInt("RoundMusicEndTime") == nil) or (GetGlobalInt("RoundMusicEndTime") == 0) then return end
			if CurTime() > GetGlobalInt("RoundMusicEndTime") then
				NextRoundMusic()
			end
		end
	end)
end
if CLIENT then
	if m_hRoundMusic then
		m_hRoundMusic:Stop()
		m_hRoundMusic = nil
	end
	
	CreateConVar( "abdul_roundmusic", "1", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "Enable/Disable round music (1/0)" )
	CreateConVar( "abdul_roundmusicwin", "1", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "Enable/Disable round win music (1/0)" )
	CreateConVar( "abdul_roundmusic_volume", "1", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "Volume of the round music (1 to 0 float)" )

	cvars.AddChangeCallback("abdul_roundmusic_volume",function(_,_,value)
		if GetGlobalBool("RoundMusicState") then
			if GetConVarNumber("abdul_roundmusic") == 1 then
				if m_hRoundMusic then
					if m_hRoundMusic.SetVolume then
						m_hRoundMusic:SetVolume( value )
					end
				end
			end
		end
	end)
	cvars.AddChangeCallback("abdul_roundmusic",function(_,_,value)
		if GetGlobalBool("RoundMusicState") then
			if m_hRoundMusic then
				if value == 1 then
					if m_hRoundMusic.SetVolume then
						m_hRoundMusic:SetVolume( GetConVarNumber("abdul_roundmusic_volume") )
					end
				else
					if m_hRoundMusic.SetVolume then
						m_hRoundMusic:SetVolume( 0 )
					end
				end
			end
		end
	end)
	
	net.Receive("abdul_net.StartRoundMusic",function()
		local time = tonumber( net.ReadString() )
		local musicID = GetGlobalInt("RoundMusicCurrent")
		if m_hRoundMusic then
			m_hRoundMusic:Stop()
			m_hRoundMusic = nil
		end
		
		local style = ""
		if time != nil then
			style = "noblock"
		end
		if !m_hRoundMusic then
			sound.PlayFile( "sound/abdul/music/roundmusic"..musicID..".ogg", style, function(channel)
				if IsValid(channel) then
					m_hRoundMusic = channel
					if GetConVarNumber("abdul_roundmusic") == 1 then
						m_hRoundMusic:SetVolume( GetConVarNumber("abdul_roundmusic_volume") )
					else
						m_hRoundMusic:SetVolume( 0 )
					end
					if time != nil and style == "noblock" then
						m_hRoundMusic:SetTime( time )
					end
					m_hRoundMusic:Play()
				end
			end)
		end
	end)
	net.Receive("abdul_net.StopRoundMusic",function()
		if m_hRoundMusic then
			m_hRoundMusic:Stop()
			m_hRoundMusic = nil
		end
	end)
end