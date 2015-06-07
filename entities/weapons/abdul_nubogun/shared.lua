if SERVER then
	AddCSLuaFile()
end

if CLIENT then
	SWEP.PrintName			= "Пушка Нубика"			
	SWEP.Author				= "SchwarzKruppzo"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 0
end

SWEP.HoldType			= "ar2"
SWEP.Base				= "abdul_bulletbase"
SWEP.Category			= "Abdul Weapons"

SWEP.BobScale			= 0.2
SWEP.SwayScale			= 0.3

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModelFOV		= 70
SWEP.ViewModel			= "models/weapons/v_acp_crb.mdl"
SWEP.WorldModel			= "models/weapons/w_acp_crb.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.CSMuzzleFlashes    = true
SWEP.CSMuzzleX			= true
SWEP.Primary.ClipSize	= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.MaxAmmo		= 100
SWEP.Secondary.ClipSize		= 100
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "45ACP"

SWEP.CrosshairType		= "auto"

SWEP.WOffset = {
	Pos = {
		Up = 0.5,
		Right = 0.7,
		Forward = -1,
	},
	Ang = {
		Up = 0,
		Right = -9,
		Forward = 180,
	}
}

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() )
	return true
end

function SWEP:Reload() return end
function SWEP:DrawWeaponSelection() end
function SWEP:PrintWeaponInfo() end

function SWEP:DrawWorldModel()
	local owner = self:GetOwner()
	
	if IsValid( owner ) then
		local boneIndex = owner:LookupBone( "ValveBiped.Bip01_R_Hand" )
		if boneIndex then
			local pos, ang = owner:GetBonePosition( boneIndex )
			pos = pos + ang:Forward() * self.WOffset.Pos.Forward + ang:Right() * self.WOffset.Pos.Right + ang:Up() * self.WOffset.Pos.Up
			ang:RotateAroundAxis( ang:Up(), self.WOffset.Ang.Up)
			ang:RotateAroundAxis( ang:Right(), self.WOffset.Ang.Right )
			ang:RotateAroundAxis( ang:Forward(),  self.WOffset.Ang.Forward )
			self:SetRenderOrigin( pos )
			self:SetRenderAngles( ang )
			self:DrawModel()
		end
	else
		self:SetRenderOrigin( nil )
		self:SetRenderAngles( nil )
		self:DrawModel()
	end
end
function SWEP:Equip( owner )
	owner:SetAmmo( self.Secondary.MaxAmmo, self.Secondary.Ammo )
end
function SWEP:OnPickup( activator )
	activator:SetAmmo( self.Secondary.MaxAmmo, self.Secondary.Ammo )
end
function SWEP:GetViewModelPosition( pos, ang )
	pos = pos - ang:Up() * 0.6  - ang:Right()/3
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
	self.Owner:ViewPunch(Angle(math.Rand(-0.5,0.5),math.Rand(-0.5,0.5),0))
		
	local bullet = {} 
	bullet.Num = 1
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = (self.Owner:GetAimVector():Angle() + self.Owner:GetPunchAngle()):Forward()
	bullet.Spread = Vector(math.Clamp(math.Rand(-0.05,0.05),0.0000,1),math.Clamp(math.Rand(-0.05,0.05),0.0000,1),0)
	bullet.Tracer = 1 
	bullet.Force = 20
	bullet.Damage = math.random(5,8)
	bullet.AmmoType = "45ACP"
	bullet.Callback = function( ply, tr, dmginfo )
		//local effectdata = EffectData()
		//effectdata:SetOrigin(tr.HitPos)
		//effectdata:SetNormal(tr.HitNormal)	
		//effectdata:SetStart(Vector(0,1,0))
		//effectdata:SetScale(0.4)			
		//effectdata:SetRadius(tr.MatType)
		//util.Effect("50cal_impact",effectdata)
		
		sound.Play("weapons/fx/rics/ric"..math.random(1,5)..".wav", tr.HitPos,math.Rand(50,75),100,math.Rand(0.5,1))
		dmginfo:SetInflictor( self.Weapon )
		
		if math.random(1,3) == 1 then
			self:Penetrate( ply, tr, dmginfo, "45ACP", 0.4 )
		end
	end
	self:NearMiss()
	self.Owner:FireBullets( bullet );
	self.Weapon:EmitSound(Sound("Shoot.NG"),90,100)
	self.Owner:RemoveAmmo( 1, self.Secondary.Ammo );
	self:SetNextPrimaryFire( CurTime() + 1/(700/60) )
end
