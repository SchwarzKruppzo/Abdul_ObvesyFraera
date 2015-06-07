ENT.Type = "anim"
if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
	function ENT:Initialize()
		ParticleEffectAttach("shrapbomb_smoke_trail2",PATTACH_ABSORIGIN_FOLLOW,self.Entity,0)
	end
else
	AddCSLuaFile()
	function ENT:Initialize()
		self.Entity:SetModel( "models/Items/grenadeAmmo.mdl" )
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
		self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self.Entity:SetSolid( SOLID_VPHYSICS )
		self.Entity.Time = CurTime() + math.Rand(0.5,1.5)
	end
	function ENT:GetDecals()
		local traceData1 = {}
		traceData1.start = self.Entity:GetPos()
		traceData1.endpos = self.Entity:GetPos() - self.Entity:GetVelocity()
		traceData1.filter = { self.Entity }
		traceData1.mask 	= MASK_SHOT + MASK_WATER
		local traceData2 = {}
		traceData2.start = self.Entity:GetPos()
		traceData2.endpos = self.Entity:GetPos() - Vector(0,0,100)
		traceData2.filter = { self.Entity }
		traceData2.mask 	= MASK_SHOT + MASK_WATER
		local trace1 = util.TraceLine(traceData1)
		local trace2 = util.TraceLine(traceData2)
		
		
		local trace1Pos1 = trace1.HitPos + trace1.HitNormal
		local trace2Pos1 = trace2.HitPos + trace2.HitNormal
		
		local trace1Pos2 = trace1.HitPos - trace1.HitNormal
		local trace2Pos2 = trace2.HitPos - trace2.HitNormal
		
		util.Decal( "scorch", trace1Pos1, trace1Pos2 )
		util.Decal( "scorch", trace2Pos1, trace2Pos2 )
	end
	function ENT:DoExplode()
		ParticleEffect("stinger_final", self.Entity:GetPos(), Angle(), nil)
		
		self.Entity:GetDecals()
		self.Entity:EmitSound(Sound("weapons/explode"..tostring(math.random(3,5))..".wav"),math.random(60,80),math.random(100,255))
		
		local weapon = self.Entity.ThowBy:GetActiveWeapon() and self.Entity
		local multiple = 1
		//if self.Entity.ThowBy:HasPowerUp( "QuadDamage" ) then
		//	multiple = 3
		//end
		util.BlastDamage( weapon , self.Entity.ThowBy, self.Entity:GetPos(), 260, math.random(15,20)*multiple )
	end
	function ENT:Think()
		if self.Entity.Time <= CurTime() then
			self.Entity:DoExplode()
			SafeRemoveEntity( self.Entity )
		end
		self.Entity:NextThink( CurTime( ) )
		return true
	end
end