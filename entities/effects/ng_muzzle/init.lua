

function EFFECT:Init(data)
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	if !IsValid(self.WeaponEnt) then return end
	if !IsValid(self.WeaponEnt:GetOwner()) then return end
	self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
	self.AddVel = self.WeaponEnt:GetOwner():GetVelocity()

	local emitter = ParticleEmitter(self.Position)
		
	local particle = emitter:Add("sprites/heatwave", self.Position)
	particle:SetVelocity(80*self.Forward + 20*VectorRand())
	particle:SetDieTime(math.Rand(0.15,0.2))
	particle:SetStartSize(math.random(4,5))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(180,480))
	particle:SetRollDelta(math.Rand(-1,1))
	particle:SetAirResistance(160)

		
	for i=-1,1 do 
		local particle = emitter:Add("particle/smokesprites_000"..math.random(1,9), self.Position)
		particle:SetVelocity(80*i*self.Right)
		particle:SetDieTime(math.Rand(0.2,0.3))
		particle:SetStartAlpha(math.Rand(20,30))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.random(1,1))
		particle:SetEndSize(math.Rand(5,5))
		particle:SetRoll(math.Rand(180,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(200,200,200)
		particle:SetAirResistance(160)
	end
	
	for i=0,5 do 
		local particle = emitter:Add("effects/muzzleflash"..math.random(1,4), self.Position+(self.Forward*i*2))
		particle:SetVelocity((self.Forward*i*5) + self.AddVel)
		particle:SetDieTime(0.05)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(5-i)
		particle:SetEndSize(10-i)
		particle:SetRoll(math.Rand(180,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(255,255,255)	
	end
	
	emitter:Finish()
end

function EFFECT:Think() return false end
function EFFECT:Render() end