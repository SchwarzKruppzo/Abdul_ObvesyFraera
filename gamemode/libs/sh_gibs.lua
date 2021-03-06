if CLIENT then
	m_tGibsEnts = {}
	m_tGibsModels = {}
	m_tGibsBigModels = {}
	m_tGibsModels[1] = {
		model = "models/props_junk/garbage_bag001a.mdl",
		min = Vector(-5,-5,-5),
		max = Vector(5,5,5)
	}
	m_tGibsModels[2] = {
		model = "models/props_debris/concrete_chunk04a.mdl",
		min = Vector(-2,-2,-2),
		max = Vector(2,2,2)
	}
	m_tGibsModels[3] = {
		model = "models/props_debris/concrete_chunk03a.mdl",
		min = Vector(-3,-3,-3),
		max = Vector(3,3,3)
	}
	m_tGibsModels[4] = {
		model = "models/props_debris/concrete_chunk09a.mdl",
		min = Vector(-3,-3,-4),
		max = Vector(3,3,4)
	}
	m_tGibsBigModels[1] = {
		model = "models/props_debris/concrete_column001a_chunk02.mdl",
		min = Vector(-4,-4,-1),
		max = Vector(4,4,25)
	}
	m_tGibsBigModels[2] = {
		model = "models/props_debris/concrete_column001a_chunk06.mdl",
		min = Vector(-5,-5,-10),
		max = Vector(5,5,1)
	}
	util.PrecacheModel( "models/props_junk/garbage_bag001a.mdl" )
	util.PrecacheModel( "models/props_debris/concrete_chunk04a.mdl" )
	util.PrecacheModel( "models/props_debris/concrete_chunk03a.mdl" )
	util.PrecacheModel( "models/props_debris/concrete_chunk09a.mdl" )
	util.PrecacheModel( "models/props_debris/concrete_column001a_chunk02.mdl" )
	util.PrecacheModel( "models/props_debris/concrete_column001a_chunk06.mdl" )

	local rand = math.random
	function q3_GibExplode(pos)
		sound.Play("physics/body/body_medium_break2.wav", pos, 70, 100, 1)
		// Do a small shit
		for i=1,2 do
			for k,v in pairs(m_tGibsModels) do
				local gib = ClientsideModel(v.model,RENDERGROUP_OPAQUE)
				gib:SetPos(pos+Vector(0,0,5))
				gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				gib:PhysicsInitBox(v.min,v.max)
				gib:GetPhysicsObject():SetVelocity(Vector(rand(-150,200),rand(-150,150),rand(200,350)))
				gib:SetMaterial("models/flesh")
				gib:GetPhysicsObject():SetMaterial( "zombieflesh" )
				ParticleEffectAttach("gib_blood",PATTACH_ABSORIGIN_FOLLOW,gib,0)
				table.insert(m_tGibsEnts,gib)
				gib.paint = 0
				gib.impact = 0
				gib.EffectTimer = CurTime() + math.random(2, 6)
				gib.RemoveTimer = CurTime() + math.random(5,10)
			end
			sound.Play("physics/body/body_medium_break4.wav", pos, 50, 100, 1)
		end
		for k,v in pairs(m_tGibsBigModels) do
			local gib = ClientsideModel(v.model,RENDERGROUP_OPAQUE)
			gib:SetModelScale(0.5,0)
			gib:SetPos(pos+Vector(0,0,60))
			gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			gib:PhysicsInitBox(v.min,v.max)
			gib:GetPhysicsObject():SetVelocity(Vector(rand(-150,150),rand(-150,150),rand(200,450)))
			gib:SetMaterial("models/flesh")
			gib:GetPhysicsObject():SetMaterial( "zombieflesh" )
			ParticleEffectAttach("gib_blood",PATTACH_ABSORIGIN_FOLLOW,gib,0)
			table.insert(m_tGibsEnts,gib)    
			
			gib.paint = 0
			gib.impact = 0
			gib.EffectTimer = CurTime() + math.random(2, 6)
			gib.RemoveTimer = CurTime() + math.random(5,10)
		end
		local gib = ClientsideModel("models/Gibs/HGIBS.mdl",RENDERGROUP_OPAQUE)
		gib:SetPos(pos+Vector(0,0,45))
		gib:PhysicsInitBox(Vector(-3,-3,-3),Vector(3,3,3))
		gib:GetPhysicsObject():SetVelocity(Vector(rand(-150,150),rand(-150,150),rand(200,350)))
		ParticleEffectAttach("gib_blood",PATTACH_ABSORIGIN_FOLLOW,gib,0)
		table.insert(m_tGibsEnts,gib)    
			
		gib.paint = 0
		gib.impact = 0
		gib.EffectTimer = CurTime() + math.random(2, 6)
		gib.RemoveTimer = CurTime() + math.random(5,30)
		
		local p = 7
		for i = 0, p do
			local effectdata = EffectData()
			effectdata:SetOrigin( pos + Vector( rand(-20,20), rand(-20,20), 70) )
			effectdata:SetFlags( 1 )
			util.Effect( "bloodstream", effectdata )
		end
		sound.Play( "physics/flesh/flesh_bloody_break.wav", pos, 90, 100, 1 )     
	end
	local m_iDecalTime = 15
	local m_iImpactTime = 6

	hook.Add("Think","GIBS.LIB.HOOK",function()
		for k,v in pairs(m_tGibsEnts) do
			if CurTime() < v.EffectTimer then
				if v:GetPhysicsObject():GetVelocity():Length() > 30 then
					if v.paint < m_iDecalTime then
						v.paint = math.Approach(v.paint,m_iDecalTime,1)
					elseif v.paint == m_iDecalTime then
						local tracedata = {}
						tracedata.startpos = v:GetPos()
						tracedata.endpos = v:GetPos() - Vector(0,0,10)
						local trace = util.TraceLine(tracedata)
						util.Decal("Blood", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
						v.paint = 0
					end
					if v.impact < m_iImpactTime then
						v.impact = math.Approach(v.impact,m_iImpactTime,1)
					elseif v.impact >= m_iImpactTime then
						local effectdata = EffectData()
						effectdata:SetOrigin( v:GetPos() )
						effectdata:SetFlags( 1 )
						util.Effect( "bloodsplash", effectdata )
						v.impact = 0
					end 
				else
					v:StopParticles()
				end
				
				
				
			end
			if CurTime() > v.RemoveTimer then
				v:Remove()
				m_tGibsEnts[k] = nil
			end
		end
	end)
	net.Receive( "abdul_net.DoGib", function( length )
		local x = net.ReadFloat()
		local y = net.ReadFloat()
		local z = net.ReadFloat()
		q3_GibExplode(Vector(x,y,z))
	end )
else
	util.AddNetworkString( "abdul_net.DoGib" )
	local function PlayerDeath(ply, attacker, dmg)
		if ply.m_bCriticalDamage then
			if IsValid(ply:GetRagdollEntity()) then
				ply:GetRagdollEntity():Remove()
			end
			net.Start( "abdul_net.DoGib" )
				net.WriteFloat(ply:GetPos()[1])
				net.WriteFloat(ply:GetPos()[2])
				net.WriteFloat(ply:GetPos()[3])
			net.Broadcast() 
		end
	end
	hook.Add("PlayerDeath", "GIBS.LIB.HOOK", PlayerDeath)

	local function EntityTakeDamage(ply,dmginfo)
		if ply:IsPlayer() then
			if !dmginfo:IsExplosionDamage() then
				if dmginfo:GetDamage() > ply:Health()+100 then
					ply.m_bCriticalDamage = true         
				else
					ply.m_bCriticalDamage = false
				end	
			else
				if dmginfo:GetDamage() > ply:Health() then
					ply.m_bCriticalDamage = true          
				else
					ply.m_bCriticalDamage = false
				end
			end
			if dmginfo:IsFallDamage() then
				if dmginfo:GetDamage() > ply:Health()+50 then
					ply.m_bCriticalDamage = true          
				else
					ply.m_bCriticalDamage = false
				end
			end
		end
	end
	hook.Add("EntityTakeDamage", "GIBS.LIB.HOOK", EntityTakeDamage)
end