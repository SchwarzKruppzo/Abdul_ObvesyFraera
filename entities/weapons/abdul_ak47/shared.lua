

if SERVER then
	AddCSLuaFile()
end

if CLIENT then
	SWEP.PrintName			= "Калаш"			
	SWEP.Author				= "SchwarzKruppzo"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 0
end

SWEP.HoldType			= "ar2"
SWEP.Base				= "abdul_bulletbase"
SWEP.Category			= "Abdul Weapons"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.BobScale			= 0.4
SWEP.SwayScale			= 0.2

SWEP.ViewModelFOV		= 60
SWEP.ViewModel			= "models/weapons/v_rif_ak12.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_ak12.mdl"
SWEP.UseHands			= true

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
SWEP.Secondary.Ammo			= "AK47"
SWEP.RecoilUP	=	0

SWEP.CrosshairType		= "auto"
SWEP.CrosshairSize = 1
SWEP.CrosshairGap = -6

SWEP.WOffset = {
	Pos = {
		Up = 0.7,
		Right = 0.7,
		Forward = 2,
	},
	Ang = {
		Up = 0,
		Right = -10,
		Forward = 180,
	}
}

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() ) 
	return true
end

function SWEP:Reload() return end
function SWEP:DrawWeaponSelection() end
function SWEP:PrintWeaponInfo() end

function SWEP:Equip( owner )
	owner:SetAmmo( self.Secondary.MaxAmmo, self.Secondary.Ammo )
end

function SWEP:Think()
	if self.Owner:GetAmmoCount( self.Secondary.Ammo ) > self.Secondary.MaxAmmo then
		self.Owner:RemoveAmmo( self.Owner:GetAmmoCount( self.Secondary.Ammo ) - self.Secondary.MaxAmmo, self.Secondary.Ammo );
	end
	if ( self.Owner:GetAmmoCount( self.Secondary.Ammo ) > 0 ) then
		if self.Owner:KeyDown( IN_ATTACK ) then
			if self.RecoilUP > -1.5 then
				self.RecoilUP = self.RecoilUP - 0.5/25
			end
		elseif self.Owner:KeyReleased( IN_ATTACK ) then
			if self.RecoilUP <= 0 then
				self.RecoilUP = self.RecoilUP + 1
				self.RecoilUP = math.Clamp( self.RecoilUP, -1000, 0 )
			end
		end
	end
	
	self:NextThink( CurTime() )
	return true
end
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
function SWEP:GetViewModelPosition( pos, ang )
	pos = pos - ang:Up()*0.8 - ang:Forward()*3 - ang:Right()*0.8
	return pos, ang
end
function SWEP:OnPickup( activator )
	activator:AbdulVoice("abdul/wep"..math.random(1,2)..".wav")
	activator:SetAmmo( self.Secondary.MaxAmmo, self.Secondary.Ammo )
end
function SWEP:PrimaryAttack()
	if ( self.Owner:GetAmmoCount( self.Secondary.Ammo ) <= 0 ) then
		self.Weapon:EmitSound( Sound( "Weapon_SMG1.Empty" ) );
		self.Weapon:SetNextPrimaryFire( CurTime() + 1 );
		return
	end
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Owner:ViewPunch(Angle(self.RecoilUP,math.Rand(-0.25,0.25),0))
	
	if CLIENT then
		local fx 		= EffectData()
		fx:SetEntity(self.Weapon)
		fx:SetOrigin(self.Owner:GetShootPos())
		fx:SetNormal(self.Owner:GetAimVector())
		fx:SetAttachment("1")
		util.Effect("k_muzzle",fx)
	end
	//if (IsFirstTimePredicted()) then
	//ParticleEffectAttach("kalash_muzzle",PATTACH_POINT_FOLLOW, self.Owner:GetViewModel(),1)
	//end
	
	local bullet = {} 
	bullet.Num = 1
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = (self.Owner:GetAimVector():Angle() + self.Owner:GetPunchAngle()):Forward()
	bullet.Spread = Vector(math.Clamp(math.Rand(-0.01,0.012),0.0000,1),math.Clamp(math.Rand(-0.01,0.01),0.0000,1),0)
	bullet.Tracer = 1 
	bullet.Force = 30
	bullet.Damage = math.random(12,24)
	bullet.AmmoType = "AK47"
	bullet.Callback = function( ply, tr, dmginfo )
		//if self.Owner:HasPowerUp( "QuadDamage" ) then
		//	dmginfo:ScaleDamage( 3 )
		//end
		//local effectdata = EffectData()
		//effectdata:SetOrigin(tr.HitPos)		
		//effectdata:SetNormal(tr.HitNormal)	
		//effectdata:SetStart(Vector(0,1,0))
		//effectdata:SetScale(0.5)			
		//effectdata:SetRadius(tr.MatType)
		//util.Effect("50cal_impact",effectdata)
		sound.Play("weapons/fx/rics/ric"..math.random(1,5)..".wav", tr.HitPos,math.Rand(50,75),100,math.Rand(0.5,1))
		dmginfo:SetInflictor( self.Weapon )
		self:Penetrate( ply, tr, dmginfo, "AK47", 0.5 )
	end
	self:NearMiss()
	self.Owner:FireBullets( bullet );
	self.Weapon:EmitSound(Sound("Shoot.AK12"),100,100)
	self.Owner:RemoveAmmo( 1, self.Secondary.Ammo );
	self:SetNextPrimaryFire( CurTime() + 1/(560/60) )
end

function SWEP:SecondaryAttack() return false end