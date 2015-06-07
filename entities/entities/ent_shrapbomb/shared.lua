ENT.Type = "anim"
if CLIENT then
	function ENT:Draw()
		self.Entity:DrawModel()
	end
	function ENT:Initialize()
		ParticleEffectAttach("shrapbomb_smoke_trail",PATTACH_ABSORIGIN_FOLLOW,self.Entity,0)
	end
else
	AddCSLuaFile()
	function ENT:Initialize()
		self.Entity:SetModel( "models/props_lab/jar01b.mdl" )
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
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
	function ENT:DoExplode( water )
		if !water then
			local light = EffectData()
			light:SetOrigin( self.Entity:GetPos() )
			util.Effect("rocket_impact",light)
			
			ParticleEffect("shrapbomb_explosion_final",self.Entity:GetPos(),Angle())
			self.Entity:EmitSound(Sound("BaseExplosionEffect.Sound"),100,100)
		else
			local effect = EffectData()
			effect:SetOrigin( self.Entity:GetPos() )
			util.Effect("WaterSurfaceExplosion", effect)
		end
		
	
		self:GetDecals()
		self.Entity:EmitSound(Sound("weapons/explode"..tostring(math.random(3,5))..".wav"),70,150)

		local weapon = self.Entity.ThowBy:GetActiveWeapon() and self.Entity
		local multiple = 1
		//if self.Entity.ThowBy:HasPowerUp( "QuadDamage" ) then
		//	multiple = 3
		//end
		util.BlastDamage( weapon, self.Entity.ThowBy, self.Entity:GetPos(), 160, math.random(60,100)*multiple )
		
		local sin,cos,rad = math.sin,math.cos,math.rad;
		local tmp = 0;
		local s,c;
		for i = 1, 8 do
			local X = math.sin((360/8)*i)
			local Y = math.cos((360/8)*i)
			local ent = ents.Create ("ent_shrap");
			local pos = self.Entity:GetPos() + Vector(0,0,10) + Vector(X*2,Y*2,0)
			local vecThrow;
			vecThrow = (self.Entity:GetPos() - pos) * 200;

			ent:SetPos( pos );
			ent:SetAngles( Angle(0,0,0) );
			ent:SetOwner( self.Entity.ThowBy);
			ent.ThowBy = self.Entity.ThowBy
			ent.Time = CurTime() + math.Rand(0.5,1.5)
			ent:Spawn()
			ent:GetPhysicsObject():SetVelocity( vecThrow );
			ent:GetPhysicsObject():AddAngleVelocity( Vector(600,math.random(-1200,1200),0) );
		end
	end
	function ENT:Think()
		if self.Entity.Time <= CurTime() then
			local water = false
			water = self.Entity:WaterLevel() > 0 and true or false
			self.Entity:DoExplode( water )
			SafeRemoveEntity( self.Entity )
		end
		self.Entity:NextThink( CurTime( ) )
		return true
	end
end