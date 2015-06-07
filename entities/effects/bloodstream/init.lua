local BloodSprite = Material("effects/bloodstream")

function EFFECT:Init(data)
	self.Particles = {}
	
	self.PlaybackSpeed = math.random(3, 5)
	self.Width = math.random(4, 8)
	self.EffectPos = data:GetOrigin()
	
	local Speed = math.Rand(100, 1000)
	local Dir = VectorRand() 
	local Squirtdelay = math.Rand( 3, 5 )
	
	for i = 1, math.random( 4, 8 ) do
		Dir = Dir * 0.95 + VectorRand() * 0.02
		
		local p = {}
		p.pos = self.EffectPos
		p.delay = (10 - i) * Squirtdelay
		p.stopped = false
		p.vel = Dir * (Speed * (i /40))
		table.insert(self.Particles, p)
	end
end

function EFFECT:Think()
	local FrameSpeed = self.PlaybackSpeed * FrameTime()
	local LastPos = nil
	
	for k, p in pairs(self.Particles) do
		if (p.stopped) then --do nothing
		elseif (p.delay > 0) then
			p.delay = p.delay - 100 * FrameSpeed
		else
			// Gravity
			p.vel:Sub(Vector(0, 0, 30 * FrameSpeed))
			// Air resistance
			p.vel.x = math.Approach(p.vel.x, 0, 2 * FrameSpeed)
			p.vel.y = math.Approach(p.vel.y, 0, 2 * FrameSpeed)
			
			local trace = {}
			trace.start 	= p.pos
			trace.endpos 	= p.pos + p.vel * FrameSpeed
			trace.mask 		= MASK_NPCWORLDSTATIC
			local tr = util.TraceLine(trace)
			
			if (tr.Hit) then
				tr.HitPos:Add(tr.HitNormal * 2)

				local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
				effectdata:SetNormal(tr.HitNormal)
				util.Effect("bloodsplash", effectdata)
				
				if LastPos != nil then
					if p.pos:Distance(LastPos) > 4 then
						p.vel = Vector(0,0,0)
					end
				end

				if tr.HitNormal.z < -0.75 then
					p.vel.z = 0
				else
					p.stopped = true
				end
			end
			// Add velocity to position
			p.pos = tr.HitPos
		end
		
		LastPos = p.pos
		//self:SetRenderBoundsWS( LastPos - Vector(50,50,50), p.pos + Vector(50,50,50) )
	end
	
	
	self.Width = self.Width - 0.01 * FrameSpeed
	
	if self.Width < 2 then
		return false
	else
		return true
	end
end

function EFFECT:Render() end