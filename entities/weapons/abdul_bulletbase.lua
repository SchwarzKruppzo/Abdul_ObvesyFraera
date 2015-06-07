if SERVER then
	AddCSLuaFile()
end
SWEP.Base				= "weapon_base"

function SWEP:Think()
	if self.Owner:GetAmmoCount( self.Secondary.Ammo ) > self.Secondary.MaxAmmo then
		self.Owner:RemoveAmmo( self.Owner:GetAmmoCount( self.Secondary.Ammo ) - self.Secondary.MaxAmmo, self.Secondary.Ammo );
	end
	self:NextThink( CurTime() )
	return true
end

function SWEP:NearMiss()
	local tracedata = {}
	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 6000000 )
	tracedata.filter = self.Owner
	tracedata.mins = Vector( -6,-6,-6 )
	tracedata.maxs = Vector( 6,6,6 )
	tracedata.mask = MASK_SHOT_HULL
	local tr = util.TraceHull( tracedata )
	if IsValid(tr.Entity) then
		if tr.Entity:IsPlayer() then
			local strTbl = {"03","04","05","06","07","09","11","12","13","14"}
	
			sound.Play("weapons/fx/nearmiss/bulletltor"..table.Random(strTbl)..".wav", tr.Entity:GetPos(),60,100,math.Rand(0.5,1))
		end
	end
end

function SWEP:Penetrate( attacker, tracedata, dmginfo, ammotype, effectScale )
	local Dir = tracedata.HitNormal * math.random(20,23) 
	
	local trace 	= {}
	trace.endpos 	= tracedata.HitPos
	trace.start 	= tracedata.HitPos + Dir
	trace.mask 		= MASK_SHOT
	trace.filter 	= {self.Owner}
	   
	local trace 	= util.TraceLine(trace) 
	if (trace.StartSolid or trace.Fraction >= 1.0 or tracedata.Fraction <= 0.0) then return false end
	
	local bullet = {} 
	bullet.Num = 1
	bullet.Src = trace.HitPos
	bullet.Dir = tracedata.Normal	
	bullet.Spread = Vector(0, 0, 0)
	bullet.Tracer = 1 
	bullet.Force = 5
	bullet.Damage = dmginfo:GetDamage()/1.3
	bullet.AmmoType = ammotype
	bullet.Callback = function( ply, tr, dmginfo )
		//if self.Owner:HasPowerUp( "QuadDamage" ) then
		//	dmginfo:ScaleDamage( 3 )
		//end
		local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)		
		effectdata:SetNormal(tr.HitNormal)	
		effectdata:SetStart(Vector(0,1,0))
		effectdata:SetScale(effectScale)			
		effectdata:SetRadius(tr.MatType)
		util.Effect("50cal_impact",effectdata)
		
		local effectdata = EffectData()
		effectdata:SetOrigin(tr.StartPos)		
		effectdata:SetNormal(-tr.HitNormal)	
		effectdata:SetStart(Vector(0,1,0))
		effectdata:SetScale(effectScale)			
		effectdata:SetRadius(tr.MatType)
		util.Effect("50cal_impact",effectdata)
		sound.Play("weapons/fx/rics/ric"..math.random(1,5)..".wav", tr.HitPos,math.Rand(50,75),100,math.Rand(0.5,1))
		dmginfo:SetInflictor( self.Weapon )
	end
	if IsValid( attacker ) then
		attacker:FireBullets( bullet )
	end
	return true
end

function SWEP:SecondaryAttack()
	return false
end