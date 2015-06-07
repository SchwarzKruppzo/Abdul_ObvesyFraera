abdulmode.AddCSLuaFile( "shared.lua" )
abdulmode.AddCSLuaFile( "cl_mlgeffects.lua")
abdulmode.AddCSLuaFile( "sh_deathnotices.lua" )
abdulmode.AddCSLuaFile( "sh_fraghint.lua" )
abdulmode.AddCSLuaFile( "sh_roundmusic.lua" )
abdulmode.AddCSLuaFile( "derma/scoreboard/main.lua" )
abdulmode.AddCSLuaFile( "derma/menu/main.lua" )
abdulmode.Include( "shared.lua" )

CreateConVar( "ffa_maxrounds", "100", FCVAR_NOTIFY, "Max rounds" )
CreateConVar( "ffa_roundtime", "501", FCVAR_NOTIFY, "Round time, in seconds" )
CreateConVar( "ffa_roundstarttime", "6", FCVAR_NOTIFY, "Round start time, in seconds" )
CreateConVar( "ffa_fraglimit", "100", FCVAR_NOTIFY, "Frag limit" )
CreateConVar( "ffa_weapon_restime", "35", FCVAR_NOTIFY, "Weapon Respawn Time" )
CreateConVar( "ffa_armor_restime", "50", FCVAR_NOTIFY, "Armor Respawn Time" )
CreateConVar( "ffa_healthvial_restime", "55", FCVAR_NOTIFY, "Health Vial Respawn Time" )
CreateConVar( "ffa_healthkit_restime", "65", FCVAR_NOTIFY, "Health Kit Respawn Time" )
CreateConVar( "ffa_ammo_restime", "75", FCVAR_NOTIFY, "Ammo Respawn Time" )
CreateConVar( "ffa_powerup_restime", "80", FCVAR_NOTIFY, "PowerUp Respawn Time" )
CreateConVar( "ffa_armoryellow_restime", "90", FCVAR_NOTIFY, "Yellow Armor Respawn Time" )
CreateConVar( "ffa_armorred_restime", "120", FCVAR_NOTIFY, "Red Armor Respawn Time" )

util.AddNetworkString("abdul_net.Lead")
util.AddNetworkString("abdul_net.GameStateChanged")
util.AddNetworkString("abdul_net.RoundMusicWin")
util.AddNetworkString("abdul_net.RoundMusic")

MODE.WeaponDropBlacklist = {
	"abdul_machete"
}

SetGlobalInt("CURRENT_GAME_STATE",0)
SetGlobalInt("CURRENT_ROUND",0)
SetGlobalInt("CURRENT_ROUNDTIME",0)
SetGlobalEntity("CURRENT_WINNER",nil)
SetGlobalInt("CURRENT_FRAGREMAINING",0)

game_NextRoundStart = 0
game_RoundTimer = 0
game_EndRoundTimer = 0
game_GameOverTimer = 0
	
function SetGameRound( int )
	SetGlobalInt("CURRENT_ROUND",int)
end
function SetGameRoundTime( int )
	SetGlobalInt("CURRENT_ROUNDTIME",int)
end
function SetWinner( entity )
	SetGlobalEntity("CURRENT_WINNER",entity)
	Notify(Color(0,200,255),entity:Nick(),Color(255,255,255)," won!")
end
function ResetRounds()
	SetGameRound(0)
	SetGameRoundTime(0)
end
function SwitchGameState( int )
	SetGlobalInt("CURRENT_GAME_STATE",int)
	hook.Run("OnGameStateChanged",int)
end
function SetFragRemaining( int )
	SetGlobalInt("CURRENT_FRAGREMAINING",int)
end

function GM:OnGameStateChanged( int )
	net.Start("abdul_net.GameStateChanged")
		net.WriteString( tostring( int ) )
	net.Broadcast()
end

function FreezeAll( bool )
	for k,v in pairs( player.GetAll() ) do
		if IsValid(v) then
			v:Freeze( bool )
			v:SetEyeAngles(Angle(0,0,0))
		end
	end
end
function ResetAllPlayers()
	for _,weaponspawn in pairs( ents.FindByClass("ent_weaponspawn_noresp")) do weaponspawn:Remove() end
	for k,v in pairs( player.GetAll() ) do
		if IsValid(v) then
			v:StripWeapons()
			v:SetHealth(100)
			v:SetArmor(0)
			v:SetEyeAngles(Angle(0,0,0))
			v:SetFrags(0)
			v:SetDeaths(0)
			v.placeCache = 0
			v:Spawn()
			v:SendLua("RunConsoleCommand('r_cleardecals')")
			hook.Call("PlayerLoadout",GAMEMODE,v)
		end
	end
end
function CanStartMatch()
	local playerCount = #player.GetAlivePlayers()
	if playerCount > 1 then
		return true
	end
end
function GameStateThink()
	if !CanStartMatch() and GetGameState() ~= GS_WAITING_PLAYERS then
		ResetAllPlayers()
		FreezeAll( false )
		SwitchGameState( GS_WAITING_PLAYERS )
		ResetRounds()
	end
	if GetGameState() == GS_WAITING_PLAYERS then
		if CanStartMatch() then
			ResetAllPlayers()
			FreezeAll( true )
			SwitchGameState( GS_ROUND_PREPARE )
			ResetRounds()
			game_NextRoundStart = CurTime() + GetConVar("ffa_roundstarttime"):GetInt()
		end
	elseif GetGameState() == GS_ROUND_PREPARE then
		if game_NextRoundStart <= CurTime() then
			FreezeAll( false )
			for k,v in pairs( player.GetAll()) do
				v:SetEyeAngles(Angle(0,0,0))
				v:SetFrags(0)
				v:SetDeaths(0)
			end
			SetGameRound( GetRound() + 1 )
			SwitchGameState( GS_ROUND_PLAYING )
			game_RoundTimer = CurTime() + GetConVar("ffa_roundtime"):GetInt()
		else
			SetGameRoundTime( game_NextRoundStart - CurTime())
		end
	elseif GetGameState() == GS_ROUND_END then
		if game_EndRoundTimer <= CurTime() then
			FreezeAll( false )
			ResetAllPlayers()
			FreezeAll( true )
			SwitchGameState( GS_ROUND_PREPARE )
			game_NextRoundStart = CurTime() + GetConVar("ffa_roundstarttime"):GetInt()
		else
			SetGameRoundTime( game_EndRoundTimer - CurTime())
		end
	end
end
function RoundThink()
	if GetGameState() == GS_ROUND_PLAYING then
		local totalFrags = 0
		for k,v in pairs(player.GetAll()) do
			if v:IsSpectator() then continue end
			totalFrags = totalFrags + v:Frags()
		end
		local fragRemaining = GetConVar("ffa_fraglimit"):GetInt() - totalFrags
		fragRemaining = math.Clamp( fragRemaining, 0, GetConVar("ffa_fraglimit"):GetInt() )
		if fragRemaining ~= GetFragsRemaining() then
			SetFragRemaining( fragRemaining )
		end
			
		if game_RoundTimer <= CurTime() then
			if GetRound() >= GetConVar("ffa_maxrounds"):GetInt() then
				FreezeAll( true )
				game_GameOverTimer = CurTime() + 11
				SwitchGameState( GS_GAME_OVER )
				SetWinner( player.GetSortedPlayers()[1] )
				net.Start( "abdul_net.RoundMusicWin" )
					net.WriteInt( math.random(1,8) , 32)
				net.Broadcast()
			else
				FreezeAll( true )
				game_EndRoundTimer = CurTime() + 11
				SwitchGameState( GS_ROUND_END )
				SetWinner( player.GetSortedPlayers()[1] )
				net.Start( "abdul_net.RoundMusicWin" )
					net.WriteInt( math.random(1,8) , 32)
				net.Broadcast()
			end
		else
			SetGameRoundTime( game_RoundTimer - CurTime())
		end
	end
end
function MODE:OnTotalFragsChanged( frag )
	local fraglimit = GetConVar("ffa_fraglimit"):GetInt() - frag
	if fraglimit < 4 and fraglimit != 0 then
		Notify(Color( 255, 255, 255, 255 ), fraglimit .. " frags left!")
	end
end

local nextTimeNotify = 0
local curTotalFrags = 0
function FragsThink()
	if GetGameState() == GS_ROUND_PLAYING then
		local totalFrags = 0
		for k,v in pairs(player.GetAll()) do
			if v:IsSpectator() then continue end
			totalFrags = totalFrags + v:Frags()
		end
		if curTotalFrags != totalFrags then
			curTotalFrags = totalFrags
			hook.Run("OnTotalFragsChanged", curTotalFrags )
		end
		if math.Round(GetRoundTime(),0) == 300 then
			if nextTimeNotify < CurTime() then
				nextTimeNotify = CurTime() + 1
				Notify(Color( 255, 255, 255, 255 ), "5 minutes remaining!")
			end
		elseif math.Round(GetRoundTime(),0) == 60 then
			if nextTimeNotify < CurTime() then
				nextTimeNotify = CurTime() + 1
				Notify(Color( 255, 255, 255, 255 ), "1 minute remaining!")
			end
		end
		if totalFrags >= GetConVar("ffa_fraglimit"):GetInt() then
			if GetRound() >= GetConVar("ffa_maxrounds"):GetInt() then
				FreezeAll( true )
				game_GameOverTimer = CurTime() + 11
				SwitchGameState( GS_GAME_OVER )
				SetWinner( player.GetSortedPlayers()[1] )
				net.Start( "abdul_net.RoundMusicWin" )
					net.WriteInt( math.random(1,8) , 32)
				net.Broadcast()
			else
				FreezeAll( true )
				game_EndRoundTimer = CurTime() + 11
				SwitchGameState( GS_ROUND_END )
				SetWinner( player.GetSortedPlayers()[1] )
				net.Start( "abdul_net.RoundMusicWin" )
					net.WriteInt( math.random(1,8) , 32)
				net.Broadcast()
			end					
		end
	end
end
function LeadThink( ply )
	if GetGameState() != GS_ROUND_PLAYING then return end
	
	if ply.placeCache != ply:GetPlace() then
		if ply.placeCache == 1 then
			if ply:GetPlace() != 1 then
				net.Start("abdul_net.Lead")
					net.WriteBool( false )
				net.Send( ply )
			end
		else
			if ply:GetPlace() == 1 then
				if ply:Frags() == 0 then return end
				Notify(Color(0,200,255),ply:Nick(),Color(255,255,255)," has taken the lead.")
				net.Start("abdul_net.Lead")
					net.WriteBool( true )
				net.Send( ply )
			end
		end
		ply.placeCache = ply:GetPlace() or 1
	end
end
function AbdulCheckSounds( ply )
	local p = ply:GetEyeTrace().Entity
	if p:IsPlayer() then
		if not ply.nextCheckSound then ply.nextCheckSound = 0 end
		if CurTime() >= ply.nextCheckSound then
			ply:AbdulVoice( "abdul/check/check"..tostring(math.random(1,24))..".mp3" )
			ply.nextCheckSound = CurTime() + 60
		end
	end
end
function MODE:PlayerTick( ply )
	LeadThink( ply )
	AbdulCheckSounds( ply )
end
function MODE:DoPlayerDeath( ply, attacker, dmg )
	if !ply.GetActiveWeapon then return end
	if table.HasValue( MODE.WeaponDropBlacklist, ply:GetActiveWeapon():GetClass() ) then return end
	
	local ent = ents.Create("ent_weaponspawn_noresp")
	ent:SetPos(ply:GetPos() + ply:GetUp() * 15)
	ent.Class = ply:GetActiveWeapon():GetClass()
	ent.MDL = ply:GetActiveWeapon().WorldModel
	ent:Spawn()
end
function MODE:PlayerDeath( victim, infl, attack )
	if victim:IsPlayer() then
		victim:AbdulVoice( "abdul/death/death"..tostring(math.random(1,40))..".mp3" )
	end
	if attack then
		if attack:IsPlayer() then 
			if victim ~= attack then 
				attack:AbdulVoice( "abdul/kill/kill"..tostring(math.random(1,34))..".mp3" ) 
			end 
		end 
	end
end
function MODE:ShowHelp( ply )
	ply:ConCommand("showabdulmenu")
end
function MODE:Think()
	GameStateThink()
	RoundThink()
	FragsThink()
end