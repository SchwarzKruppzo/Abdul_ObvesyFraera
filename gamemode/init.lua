include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
DEFINE_BASECLASS( "gamemode_base" )

resource.AddWorkshop("437251730")
resource.AddWorkshop("143280395")
resource.AddFile("resource/fonts/europenormal.ttf")
resource.AddFile("resource/fonts/russoone.ttf")

util.AddNetworkString("abdul_net.PlayerSpawn")
util.AddNetworkString("abdul_net.PlayerInitialSpawn")
util.AddNetworkString("abdul_net.PlayerPickupItem")
util.AddNetworkString("abdul_net.PlayerDeath")
util.AddNetworkString("abdul_net.OnKill")

CreateConVar( "abdul_respawntime", "5", FCVAR_NOTIFY, "Player respawn time." )
CreateConVar( "abdul_higharmor", "0", FCVAR_NOTIFY, "If disabled: if the player's armor more than 100 then the armor will decrease every 1-2 seconds, until it reaches 100." )

function GM:PlayerSpawn( client )
	player_manager.SetPlayerClass( client, "player_abdul" )
	BaseClass.PlayerSpawn( self, client )
	if client:IsSpectator() then
		client:StripWeapons()
		client:Spectate(OBS_MODE_ROAMING)
		return
	end
	client:SetupHands()
	
	net.Start("abdul_net.PlayerSpawn") 
	net.Send( client )
end

function CreateMap( ccc )
	local map = game.GetMap() .. "_" .. ccc:lower() .. ".txt"
	if file.Exists( "abdul/maps/"..map, "DATA" ) then
		local str = file.Read( "abdul/maps/"..map )
		local saveTable = util.KeyValuesToTable( str )
		
		for k, x in pairs( saveTable ) do
			local class = x.class
			local _pos = string.Explode(" ", x.pos )
			local pos = Vector(tonumber(_pos[1]),tonumber(_pos[2]),tonumber(_pos[3]))
			local _ang = string.Explode(" ", x.ang )
			local ang = Angle(tonumber(_ang[1]),tonumber(_ang[2]),tonumber(_ang[3]))
			local vars = x.vars or {}
			
			local ent = ents.Create( class )
			ent:SetPos( pos )
			ent:SetAngles( ang )
			for k,v in pairs( vars ) do
				ent[k] = v
			end
			ent:Spawn()
		end
	end
end


function GM:Initialize()
	CreateMap( GetConVarString("abdul_gamemode") )
end


function GM:PlayerSetHandsModel( ply, ent )
	ent:SetModel( "models/weapons/c_arms_cstrike.mdl" )
	ent:SetSkin( 1 )
	ent:SetBodyGroups( "0100000" )
end


function GM:PlayerInitialSpawn( ply )
	BaseClass.PlayerInitialSpawn( self, ply )
	
	net.Start("abdul_net.PlayerSpawn") 
	net.Send( ply )
	net.Start("abdul_net.PlayerInitialSpawn") 
	net.Send( ply )
end

function GM:DecreaseStats( ply )
	if !GetConVar("abdul_higharmor"):GetBool() then
		if ply:Armor() > 100 then
			if not ply.nextArmorDecrease then ply.nextArmorDecrease = CurTime() + math.Rand(1,2) end
			if CurTime() >= ply.nextArmorDecrease then
				ply:SetArmor( ply:Armor() - 1 )
				ply.nextArmorDecrease = CurTime() + math.Rand(1,2)
			end
		end
	end
	if ply:Health() > 100 then
		if not ply.nextHealthDecrease then ply.nextHealthDecrease = CurTime() + math.Rand(1,2) end
		if CurTime() >= ply.nextHealthDecrease then
			ply:SetHealth( ply:Health() - 1 )
			ply.nextHealthDecrease = CurTime() + math.Rand(1,2)
		end
	end
end

function GM:PlayerTick( ply )
	BaseClass:PlayerTick( ply )
	if ply:Alive() then
		ply:SetNWBool( "CanSpawn", false )
		ply:SetNWInt( "NextRespawnTime", CurTime() )
	end
	self:DecreaseStats( ply )
end


function GM:PlayerDeathThink( ply )
	if ( ply:GetNWInt( "NextRespawnTime") && ply:GetNWInt( "NextRespawnTime") > CurTime() ) then 
		ply:SetNWBool( "CanSpawn", false )
		return 
	end
	ply:SetNWBool( "CanSpawn", true )
	if ( ply:KeyPressed( IN_ATTACK ) || ply:KeyPressed( IN_ATTACK2 ) || ply:KeyPressed( IN_JUMP ) ) then
		ply:Spawn()
	end
end


function GM:PlayerDeathSound()
	return true
end


function GM:PlayerSilentDeath( victim )
	BaseClass:PlayerSilentDeath( victim, infl, attack)
	
	victim:SetNWInt( "NextRespawnTime", CurTime() + GetConVar("abdul_respawntime"):GetInt() )
end


function GM:PlayerDeath( victim, infl, attack )
	BaseClass:PlayerDeath(victim, infl, attack)
	
	for k,v in pairs(ents.FindByClass("ent_claymore")) do
		if v:GetThowBy() == victim then
			v:Remove()
		end
	end
	victim:ResetToolsLimit()
	victim:SetNWInt( "NextRespawnTime", CurTime() + GetConVar("abdul_respawntime"):GetInt() )
	
	net.Start("abdul_net.PlayerDeath")
		net.WriteEntity( attack )
		net.WriteEntity( infl )
	net.Send( victim )
	net.Start("abdul_net.OnKill")
		net.WriteEntity( victim )
		net.WriteEntity( infl )
	net.Send( attack )
	
	if math.random(1,5) == 5 then
		attack:EmitSound( "abdul/mlg/funny"..math.random(1,3)..".mp3" )
	end
	if math.random(1,4) == 4 then
		victim:EmitSound( "abdul/mlg/sad.mp3", 75 )
	end
end


function GM:DoPlayerDeath( ply, attacker, dmg )
	BaseClass:DoPlayerDeath( ply, attacker, dmg)
end


function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	BaseClass:ScalePlayerDamage( ply, hitgroup, dmginfo)
	
	if hitgroup == HITGROUP_HEAD then
		dmginfo:ScaleDamage( 2 )
		ply.GotHeadshot = true
	else
		ply.GotHeadshot = false
	end
end


function GM:PlayerFriendly( ply, ply2 )
	return false
end


function GM:PlayerPickupItem( ply, class )
	net.Start( "abdul_net.PlayerPickupItem" )
		net.WriteString( class )
	net.Send( ply )
	
	for k,v in pairs( ply:GetWeapons()) do
		if IsValid(v) then
			if v:IsWeapon() then
				if v:GetClass() == class then
					if v.OnPickup then
						v:OnPickup( ply )
					end
				end
			end
		end
	end
end

local m_tWeaponPriority = {
	"abdul_machete",
	"abdul_nubogun",
	"abdul_claymore",
	"abdul_shotgun",
	"abdul_ak47",
	"abdul_maslachesator",
	"abdul_rocketlauncher",
	"abdul_noscoper",
	"abdul_railgun"
}
local meta = FindMetaTable("Player")

function meta:SelectWeaponByPriority( class )
	if tonumber(self:GetInfo("abdul_autoswitchweapon")) == 0 then return end
	
	local weapon = self:GetActiveWeapon():GetClass()
	local key = table.KeyFromValue( m_tWeaponPriority, weapon )
	local key2 = table.KeyFromValue( m_tWeaponPriority, class )
	if key2 >= key then
		self:SelectWeapon( class )
	elseif self:GetAmmoCount( self:GetActiveWeapon().Secondary.Ammo ) <= 0 then
		self:SelectWeapon( class )
	end
end
concommand.Add("abdul_selectwep", function(client, command, arguments)
	client:SelectWeapon( arguments[1] )
end)
concommand.Add("teamspec",function(ply)
	if !ply:IsSpectator() then
		ply:SetTeam(2)
		ply:Spawn()
	end
end)
concommand.Add("teamgame",function(ply)
	if ply:IsSpectator() then
		ply:SetTeam(1)
		ply:KillSilent()
	end
end)