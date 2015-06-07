GM.Name = "Abdul: Obvesy Fraera"
GM.Author = "Schwarz Kruppzo"
GM.Email = ""
GM.Website = ""
DeriveGamemode("base")
include( "player_abdul.lua" )

MODE =  {}
MODE.Name = ""
MODE.Tag = ""

local fol = GM.FolderName.."/gamemode/libs/"
local files, folders = file.Find(fol .. "*", "LUA")


for k,v in pairs(files) do
	local prefix = string.Explode( "_" , v )[1]
	if prefix == "sv" then
		if SERVER then include(fol.. v) end
	elseif prefix == "sh" then
		if SERVER then AddCSLuaFile(fol.. v) end
		include(fol.. v)
	elseif prefix == "cl" then
		if SERVER then AddCSLuaFile(fol.. v) end
		if CLIENT then include(fol.. v) end
	end
end


function GM:GetGameDescription()
	return "Abdul: Obvesy Fraera - " .. MODE.Tag
end


team.SetUp(1,"Player",Color(100,150,220))
team.SetUp(2,"Spectator",Color(100,100,100,255))


function GM:CanPlayerSuicide( ply )
	return ( !ply:IsSpectator() )
end


function GM:PlayerSwitchFlashlight( ply, on )
   if not IsValid( ply ) then return false end
   if ( not on ) or !ply:IsSpectator() then
      if on then
         ply:AddEffects( EF_DIMLIGHT )
      else
         ply:RemoveEffects( EF_DIMLIGHT )
      end
   end
   return false
end


function GM:PlayerSpray( ply )
   if not IsValid( ply ) or !ply:IsSpectator() then
      return true 
   end
end


function GM:PlayerUse( ply, ent )
   return !ply:IsSpectator()
end


game.AddParticles("particles/swat4_explosions.pcf")
game.AddParticles("particles/abdul_effects.pcf")
game.AddParticles("particles/lee_particle.pcf")
PrecacheParticleSystem("stinger_final")
PrecacheParticleSystem("smoke_trail")
PrecacheParticleSystem("maslorocket_explosion_final")
PrecacheParticleSystem("shrapbomb_explosion_final")
PrecacheParticleSystem("shrapbomb_smoke_trail")
PrecacheParticleSystem("shrapbomb_smoke_trail2")
PrecacheParticleSystem("Rocket_Smoke")
PrecacheParticleSystem("gib_blood")
PrecacheParticleSystem("railgun_impact")
PrecacheParticleSystem("kalash_muzzle")
PrecacheParticleSystem("mlgclaymore_final")

sound.Add({ 
	name = "Shoot.AK12",
	sound = "weapons/ak12/fire.wav",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 90,
	pitch = {0,100}
})
sound.Add({ 
	name = "Shoot.NG",
	sound = "weapons/slayer's kriss/shoot.wav",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 80,
	pitch = {0,100}
})
sound.Add({ 
	name = "Shoot.Railgun",
	sound = "weapons/railgun/railgf1a.wav",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 120,
	pitch = {0,100}
})
sound.Add({ 
	name = "Shoot.Noscoper",
	sound = "weapons/m98/m98-1.wav",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 100,
	pitch = {0,100}
})
sound.Add({ 
	name = "Shoot.GL",
	sound = "weapons/grenade_launcher1.wav",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 80,
	pitch = {0,100}
})
sound.Add({ 
	name = "Shoot.Shotgun",
	sound = "weapons/shotgun/shotgun_fire7.wav",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 80,
	pitch = {0,100}
})
sound.Add({ 
	name = "Miss.Machete",
	sound = {"weapons/crowbar/crowbar_swing_miss1.wav","weapons/crowbar/crowbar_swing_miss2.wav"},
	channel = CHAN_WEAPON,
	volume = 1,
	level = 70,
	pitch = {0,100}
})
sound.Add({ 
	name = "Impact_Flesh.Machete",
	sound = {"physics/body/body_medium_break2.wav","physics/body/body_medium_break3.wav","physics/body/body_medium_break4.wav"},
	channel = CHAN_WEAPON,
	volume = 1,
	level = 70,
	pitch = {0,100}
})
sound.Add({ 
	name = "Impact_World.Machete",
	sound = {"weapons/crowbar/crowbar_impact_world1.wav","weapons/crowbar/crowbar_impact_world2.wav"},
	channel = CHAN_WEAPON,
	volume = 1,
	level = 70,
	pitch = {0,100}
})
sound.Add({ 
	name = "Weapon_M98.Boltlock",
	sound = "weapons/m98/m98_boltlock.wav",
	channel = CHAN_STATIC,
	volume = 1,
	level = 70,
	pitch = {100,100}
})
sound.Add({ 
	name = "Weapon_M98.Boltback",
	sound = "weapons/m98/m98_boltback.wav",
	channel = CHAN_STATIC,
	volume = 1,
	level = 70,
	pitch = {100,100}
})
sound.Add({ 
	name = "Weapon_M98.Boltpush",
	sound = "weapons/m98/m98_boltpush.wav",
	channel = CHAN_STATIC,
	volume = 1,
	level = 70,
	pitch = {100,100}
})
sound.Add({ 
	name = "Weapon_M98.draw",
	sound = "weapons/m98/m98_deploy.wav",
	channel = CHAN_STATIC,
	volume = 1,
	level = 70,
	pitch = {100,100}
})

util.PrecacheModel( "models/weapons/v_acp_crb.mdl" )
util.PrecacheModel( "models/weapons/c_rpg.mdl" )
util.PrecacheModel( "models/weapons/c_shotgun.mdl" )
util.PrecacheModel( "models/weapons/v_combinegl.mdl" )
util.PrecacheModel( "models/weapons/v_crailgun.mdl" )
util.PrecacheModel( "models/weapons/v_rif_ak12.mdl" )
util.PrecacheModel( "models/weapons/w_missile_launch.mdl" )
util.PrecacheModel( "models/weapons/w_rocket_launcher.mdl" )
util.PrecacheModel( "models/weapons/w_acp_crb.mdl" )
util.PrecacheModel( "models/weapons/w_combinegl.mdl" )
util.PrecacheModel( "models/weapons/w_crailgun.mdl" )
util.PrecacheModel( "models/weapons/w_rif_ak12.mdl" )
util.PrecacheModel( "models/w_claymore_legs.mdl" )
util.PrecacheModel( "models/w_claymore.mdl" )
util.PrecacheModel( "models/w_armor.mdl" )
util.PrecacheModel( "models/of_health5.mdl" )
util.PrecacheModel( "models/of_health25.mdl" )
util.PrecacheModel( "models/of_armorshard.mdl" )
util.PrecacheModel( "models/of_ammo.mdl" )
util.PrecacheModel( "models/weapons/w_snip_m98.mdl" )
util.PrecacheModel( "models/weapons/v_snip_m98.mdl" )
util.PrecacheModel( "models/weapons/v_machete.mdl" )
util.PrecacheModel( "models/weapons/w_machete.mdl" )