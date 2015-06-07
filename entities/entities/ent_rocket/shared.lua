ENT.Type = "anim"
ENT.RenderGroup 		= RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "Style" )
end

if CLIENT then
	function ENT:Draw()
		self.Entity:DrawModel()
	end
	function ENT:DrawTranslucent()
		local LightNrm = self.Entity:GetAngles():Forward()
		local ViewNormal = self.Entity:GetPos() - EyePos()
		local Distance = ViewNormal:Length()
		ViewNormal:Normalize()
		local ViewDot = 1
		local LightPos = self.Entity:GetPos() + LightNrm * 5
		if ( ViewDot >= 0 ) then
			local Visibile	= util.PixelVisible( LightPos, 8, self.Entity.PixVis )	
			if (!Visibile) then return end
			
			local Size = math.Clamp( Distance * Visibile * ViewDot * 2, 64, 1256 )
			local Size2 = math.Clamp( Distance * Visibile * ViewDot * 2, 0, 150 )
			local Size3 = math.Clamp( Distance * Visibile * ViewDot * 2, 0, 128 )
			local Size4 = math.Clamp( Distance * Visibile * ViewDot * 2, 0, 1512 )
			local Size5 = math.Clamp( Distance * Visibile * ViewDot * 2, 0, 1024 )
			Distance = math.Clamp( Distance, 32, 800 )
			local Alpha = math.Clamp( (1000 - Distance) * Visibile * ViewDot, 0, 255 )
			local Alpha2 = math.Clamp( (1000 - Distance) * Visibile * ViewDot, 0, 200 )
			local Alpha3 = math.Clamp( (1000 - Distance) * Visibile * ViewDot, 0, 70 )
			
			render.SetMaterial( Material("sprites/heatwave"))
			render.DrawSprite( LightPos, Size3,Size3/1.5, Color(30,20,0,Alpha))
			render.SetMaterial( Material("sprites/light_ignorez"))
			if self.Entity:GetStyle() != "blue" then
				render.DrawSprite( LightPos, Size*5, Size*5, Color(255, 255, 255, Alpha3/3), Visibile * ViewDot )
				render.DrawSprite( LightPos, Size, Size, Color(255, 180, 120, Alpha3), Visibile * ViewDot )
				render.DrawSprite( LightPos, Size*2, Size*0.4, Color(255, 180, 120, Alpha3), Visibile * ViewDot )
				render.DrawSprite( LightPos, Size2,Size2, Color(255,0,0,Alpha2))
				render.DrawSprite( LightPos, Size3,Size3, Color(255,150,0,Alpha2))
				render.DrawSprite( LightPos, Size3,Size3, Color(255,255,255,Alpha))
				render.DrawSprite( LightPos, Size2,Size2, Color(255,5,20,Alpha))
				render.DrawSprite( LightPos, Size4,Size2, Color(100,100,100,Alpha))
				render.DrawSprite( LightPos, Size5,Size5, Color(30,20,0,Alpha))
			else
				render.DrawSprite( LightPos, Size*5, Size*5, Color(255, 255, 255, Alpha3/3), Visibile * ViewDot )
				render.DrawSprite( LightPos, Size, Size, Color(120, 180, 255, Alpha3), Visibile * ViewDot )
				render.DrawSprite( LightPos, Size*2, Size*0.4, Color(120, 180, 255, Alpha3), Visibile * ViewDot )
				render.DrawSprite( LightPos, Size2,Size2, Color(0,0,255,Alpha2))
				render.DrawSprite( LightPos, Size3,Size3, Color(0,150,255,Alpha2))
				render.DrawSprite( LightPos, Size3,Size3, Color(255,255,255,Alpha))
				render.DrawSprite( LightPos, Size2,Size2, Color(20,5,255,Alpha))
				render.DrawSprite( LightPos, Size4,Size2, Color(100,100,100,Alpha))
				render.DrawSprite( LightPos, Size5,Size5, Color(0,20,30,Alpha))
			end
		end
	end
	
	function ENT:Initialize()
		self.Entity.PixVis = util.GetPixelVisibleHandle()
		ParticleEffectAttach("Rocket_Smoke",PATTACH_ABSORIGIN_FOLLOW,self.Entity,0)
	end
else
	AddCSLuaFile()
	function ENT:Initialize()
		self.Entity:SetModel( "models/weapons/w_missile_launch.mdl" )
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		self.Entity.velocity = self.Entity:GetForward()*28

		self.Entity.SoundLoop = CreateSound( self.Entity, Sound("weapons/rpg/rocket1.wav"))
		self.Entity.SoundLoop:Play()
		self.Entity:Think()
	end
	
	function ENT:DoExplode( trace )
		self.Entity:StopParticles()
		self.Entity.SoundLoop:Stop()
		local Pos1 = trace.HitPos + trace.HitNormal
		local Pos2 = trace.HitPos - trace.HitNormal
		util.Decal("scorch", Pos1, Pos2)
		local water = false
		water = self.Entity:WaterLevel() > 0 and true or false
				
		if !water then
			local light = EffectData()
			light:SetOrigin( self.Entity:GetPos() )
			util.Effect("rocket_impact",light)
			
			ParticleEffect("maslorocket_explosion_final",self.Entity:GetPos(),trace.HitNormal:Angle() + Angle(90,0,0))
			self.Entity:EmitSound(Sound("BaseExplosionEffect.Sound"),100,100)
		else
			local effect = EffectData()
			effect:SetOrigin( self.Entity:GetPos() )
			util.Effect("WaterSurfaceExplosion", effect)
		end
		
		self.Entity:EmitSound(Sound("weapons/mortar/mortar_explode1.wav"),70,80)
		self.Entity:EmitSound(Sound("weapons/explode"..tostring(math.random(3,5))..".wav"),70,70)
		local forceLimit = 256
		for k,v in pairs(ents.FindInSphere(self.Entity:GetPos(),100)) do
			if v:IsPlayer() then
				if v == self.Entity.ThowBy then forceLimit = 1024 end
				local Pos1 = trace.HitPos + trace.HitNormal
				local Pos2 = trace.HitPos - trace.HitNormal
				v:SetVelocity(  ((Pos1/2 - Pos2/2)*280 - v:GetAimVector()*280) )
				
				local Pos = trace.HitPos
				Pos = Pos + Vector(0, 0, -32)
		
				local Force = v:GetPos() - Pos
				local Dist = Force:Length()
				Force:Normalize()
				Force = Force * math.Clamp(600 - Dist, 0, forceLimit)
				
				v:SetVelocity( Force)	
			end
		end
		//for k,v in pairs(ents.FindInSphere(self.Entity:GetPos(),200)) do
		//	if v:IsPlayer() then
		//		net.Start("ExplosionEffect")
		//		net.Send(v)
		//	end
		//end
		if !IsValid(self.Entity.ThowBy) then SafeRemoveEntity( self.Entity ) end
		local wep = self.Entity.ThowBy:GetActiveWeapon() and self.Entity
		local multiple = 1
		//if self.Entity.ThowBy:HasPowerUp( "QuadDamage" ) then
		//	multiple = 3
		//end
		util.BlastDamage( wep , self.Entity.ThowBy, self.Entity:GetPos(), 160, math.random(60,100)*multiple )
		SafeRemoveEntity( self.Entity )
	end
	function ENT:Think()
		if !IsValid(self.Entity) then SafeRemoveEntity( self.Entity ) end
		local pos = self.Entity:GetPos()
		local ang = self.Entity:GetAngles()
		local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = pos + self.Entity.velocity
		tracedata.filter = { self.Entity, self.Entity.ThowBy }
		tracedata.mask 	= MASK_SHOT
		tracedata.mins = Vector(-2,-2,-2)
		tracedata.maxs = Vector(2,2,2)
		local trace = util.TraceLine(tracedata)
		local traceHull = util.TraceHull( tracedata )

		if trace.Hit then
			self.Entity:DoExplode( trace )
			return true
		end
		if traceHull.Hit then
			if traceHull.Entity:IsPlayer() then
				self.Entity:DoExplode( trace )
				return true
			end
		end
		//if IsValid(self.ThowBy) then
			//if self.ThowBy:HasPowerUp( "QuadDamage" ) then
			//	self.Entity:SetStyle("blue")
			//else
				self.Entity:SetStyle("red")
			//end
		//end
		self.Entity:SetPos(self.Entity:GetPos() + self.Entity.velocity)
		self.Entity.velocity = self.Entity.velocity - self.Entity.velocity/14 + self.Entity:GetForward()*2
		self.Entity:NextThink( CurTime() )
		return true
	end
end