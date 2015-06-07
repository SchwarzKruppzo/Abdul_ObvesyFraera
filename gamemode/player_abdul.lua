AddCSLuaFile()
DEFINE_BASECLASS( "player_default" )
if ( CLIENT ) then
	CreateConVar( "abdul_playercolor", "0.24 0.34 0.41", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The value is a Vector - so between 0-1 - not between 0-255" )
	CreateConVar( "abdul_playerskin", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The skin to use, if the model has any" )
	CreateConVar( "abdul_playerbodygroups", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The bodygroups to use, if the model has any" )
	CreateConVar( "abdul_playermodel", "kleiner", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The player model to use" )
end

local PLAYER = {}

PLAYER.DuckSpeed			= 0.1
PLAYER.UnDuckSpeed			= 0.1
PLAYER.WalkSpeed 			= 450
PLAYER.RunSpeed				= 450
PLAYER.KillingSpree = 0
PLAYER.Killstreak = 0
PLAYER.KillstreakNext = CurTime()
function PLAYER:SetupDataTables()
	BaseClass.SetupDataTables( self )
end

function PLAYER:Loadout()
	if self.Player:IsSpectator() then return end
	
	self.Player:Give("abdul_machete")
	self.Player:Give("abdul_nubogun")
	self.Player:SelectWeapon("abdul_nubogun")
	//self.Player:GiveAmmo(10,"RailCells")
	//self.Player:GiveAmmo(100,"45ACP")
end

function PLAYER:SetModel()
	local abdul_playermodel = self.Player:GetInfo( "abdul_playermodel" )
	local modelname = player_manager.TranslatePlayerModel( abdul_playermodel )
	util.PrecacheModel( modelname )
	self.Player:SetModel( modelname )
	
	local skin = self.Player:GetInfoNum( "abdul_playerskin", 0 )
	self.Player:SetSkin( skin )

	local groups = self.Player:GetInfo( "abdul_playerbodygroups" )
	if ( groups == nil ) then groups = "" end
	local groups = string.Explode( " ", groups )
	for k = 0, self.Player:GetNumBodyGroups() - 1 do
		self.Player:SetBodygroup( k, tonumber( groups[ k + 1 ] ) or 0 )
	end

end
function PLAYER:Spawn()
	BaseClass.Spawn( self )

	local col = self.Player:GetInfo( "abdul_playercolor" )
	self.Player:SetPlayerColor( Vector( col ) )

	local col = self.Player:GetInfo( "abdul_weaponcolor" )
	self.Player:SetWeaponColor( Vector( col ) )
	
	self.Player.KillingSpree = 0
	self.Player.Killstreak = 0
	self.Player.KillstreakNext = CurTime() + 10
end
function PLAYER:ShouldDrawLocal() 
end
function PLAYER:CreateMove( cmd )
end
function PLAYER:CalcView( view )
end
function PLAYER:GetHandsModel()
	return { model = "models/weapons/c_arms_cstrike.mdl", skin = 1, body = "0100000" }
end

local JUMPING
function PLAYER:StartMove( move )
	if bit.band(move:GetButtons(), IN_JUMP) ~= 0 and bit.band(move:GetOldButtons(), IN_JUMP) == 0 and self.Player:OnGround() then
		JUMPING = true
	end
end
function PLAYER:FinishMove( move )
	if JUMPING then	
		local aim = move:GetMoveAngles()
		local forward, right = aim:Forward(), aim:Right()
		local fspeed = move:GetForwardSpeed()
		local sspeed = move:GetSideSpeed()
	
		forward.z, right.z = 0,0
		forward:Normalize()
		right:Normalize()

		local dir
		if fspeed < 10 and fspeed > -10 then
			dir = forward * fspeed + right * sspeed
		else
			dir = forward
		end
	
		local wishdir = dir:GetNormal()
		
		local speedBoostPerc = .3
		local speedAddition = math.abs(fspeed * speedBoostPerc)
		local maxSpeed = move:GetMaxSpeed() * (speedBoostPerc)
		local newSpeed = speedAddition
		
		if newSpeed > maxSpeed then
			speedAddition = speedAddition - (newSpeed - maxSpeed)
		end
		
		if fspeed < 0 then
			speedAddition = -speedAddition
		end
		
		move:SetVelocity(wishdir * speedAddition + move:GetVelocity())
	end
	JUMPING = nil
end
player_manager.RegisterClass( "player_abdul", PLAYER, "player_default" )
