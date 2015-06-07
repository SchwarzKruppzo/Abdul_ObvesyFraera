if SERVER then
	AddCSLuaFile()
end

if CLIENT then
	SWEP.PrintName			= "Рейлганчик"			
	SWEP.Author				= "SchwarzKruppzo"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 0
end

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_base"
SWEP.Category			= "Abdul Weapons"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
SWEP.ViewModelFOV		= 55
SWEP.ViewModel			= "models/weapons/v_crailgun.mdl"
SWEP.WorldModel			= "models/weapons/w_crailgun.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.Primary.ClipSize	= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.MaxAmmo		= 10
SWEP.Secondary.ClipSize		= 10
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "RailCells"

SWEP.CrosshairType			= "rail"

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end
function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
	return true
end

function SWEP:Reload() return end
function SWEP:DrawWeaponSelection() end
function SWEP:PrintWeaponInfo() end

function SWEP:Equip( owner )
	owner:SetAmmo( self.Secondary.MaxAmmo, self.Secondary.Ammo )
end
function SWEP:OnPickup( activator )
	activator:SetAmmo( self.Secondary.MaxAmmo, self.Secondary.Ammo )
end

function SWEP:Think()
	if self.Owner:GetAmmoCount( self.Secondary.Ammo ) > self.Secondary.MaxAmmo then
		self.Owner:RemoveAmmo( self.Owner:GetAmmoCount( self.Secondary.Ammo ) - self.Secondary.MaxAmmo, self.Secondary.Ammo );
	end
	self:NextThink( CurTime() )
	return true
end

function SWEP:GetViewModelPosition( pos, ang )
	pos = pos + ang:Forward()*5 - ang:Right()*1 - ang:Up()*1
	return pos, ang
end
function SWEP:PrimaryAttack()
	if ( self.Owner:GetAmmoCount( self.Secondary.Ammo ) <= 0 ) then
		self.Weapon:EmitSound( Sound( "Weapon_SMG1.Empty" ) );
		self.Weapon:SetNextPrimaryFire( CurTime() + 1 );
		return
	end
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	
	if SERVER then self.Owner:LagCompensation(true) end
	
	local tr = util.TraceHull({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * (10^14),
		mins = Vector( -2, -2, -2 ),
		maxs = Vector( 2, 2, 2 ),
		filter = self.Owner
	})	
	
	if SERVER then 
		local beameffect = EffectData()
		local color = string.Explode( " ", self.Owner:GetInfo("abdul_railguncolor"))
		beameffect:SetEntity(self.Weapon)
		beameffect:SetOrigin(tr.HitPos + tr.HitNormal)
		beameffect:SetNormal(self.Owner:GetAimVector())
		beameffect:SetStart( Vector(color[1],color[2],color[3]) )
		netEffect("railgun_laser", beameffect)
		netEffect("railgun_impact", beameffect)
		netParticleEffect("railgun_impact",tr.HitPos + tr.HitNormal,tr.HitNormal:Angle() + Angle(90,0,0))
		if (tr.HitNonWorld && IsValid(tr.Entity)) then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage(220)
			dmginfo:SetDamageType(DMG_ENERGYBEAM)
			dmginfo:SetAttacker(self.Owner)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamageForce(self.Owner:GetUp() * 3500 + self.Owner:GetForward() * 20000)
			dmginfo:SetDamagePosition( tr.HitPos )
			tr.Entity:TakeDamageInfo(dmginfo)
		end
		self:Penetrate( self.Owner, tr )
		self.Owner:LagCompensation(false) 
	end
	
	
	self.Weapon:EmitSound(Sound("Shoot.Railgun"),100,100)
	self.Owner:RemoveAmmo( 1, self.Secondary.Ammo );
	
	self:SetNextPrimaryFire( CurTime() + 1.6 )
end
function SWEP:Penetrate( attacker, tracedata)

	local Dir = tracedata.Normal *  18
	
	local trace 	= {}
	trace.endpos 	= tracedata.HitPos
	trace.start 	= tracedata.HitPos + Dir
	trace.mask 		= MASK_SHOT
	trace.filter 	= {self.Owner}
	   
	local trace 	= util.TraceLine(trace) 
	if !tracedata.Entity:IsPlayer() then
		if (trace.StartSolid or trace.Fraction >= 1.0 or tracedata.Fraction <= 0.0) then return false end
	end
	
	local trace2 	= {}
	trace2.endpos 	= trace.HitPos + tracedata.Normal * (10^14)
	trace2.start 	= trace.HitPos
	trace2.mask 		= MASK_SHOT
	trace2.filter 	= {self.Owner}
	local trace2 	= util.TraceLine(trace2) 
	
	local laser = EffectData()
	local color = string.Explode( " ", self.Owner:GetInfo("abdul_railguncolor"))
	laser:SetOrigin(trace2.HitPos)
	laser:SetNormal(trace2.StartPos)
	laser:SetStart( Vector(color[1],color[2],color[3]) )
	netEffect( "railgun_laser2", laser )
	netEffect( "railgun_impact", laser )
	
	local laser2 = EffectData()
	laser:SetOrigin(trace2.StartPos)
	laser:SetNormal(trace2.HitPos)
	laser:SetStart( Vector(color[1],color[2],color[3]) )
	netEffect( "railgun_impact", laser )
	netParticleEffect("railgun_impact",trace2.HitPos + trace2.HitNormal,trace2.HitNormal:Angle() + Angle(90,0,0))
			
	if (trace2.HitNonWorld && IsValid(trace2.Entity)) then
		local dmginfo = DamageInfo()
		dmginfo:SetDamage(120)
		dmginfo:SetDamageType(DMG_ENERGYBEAM)
		dmginfo:SetAttacker(self.Owner)
		dmginfo:SetInflictor(self)
		dmginfo:SetDamageForce(self.Owner:GetUp() * 3500 + self.Owner:GetForward() * 20000)
		dmginfo:SetDamagePosition( trace2.HitPos )
		trace2.Entity:TakeDamageInfo(dmginfo)
	end
	return true
end
function SWEP:SecondaryAttack() return false end