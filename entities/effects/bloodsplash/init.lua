Sounds = {"physics/flesh/flesh_bloody_break.wav",
	"physics/flesh/flesh_squishy_impact_hard1.wav",
	"physics/flesh/flesh_squishy_impact_hard2.wav",
	"physics/flesh/flesh_squishy_impact_hard3.wav",
	"physics/flesh/flesh_squishy_impact_hard4.wav"}

function EFFECT:Init(data)
	local Pos = data:GetOrigin()
	local Norm = data:GetNormal()
	self.time = CurTime() + 20
	util.Decal("Blood", Pos + Norm*10, Pos - Norm*10)

	if math.random(1, 3) == 1 then
		sound.Play(table.Random(Sounds), self:GetPos(), 75, math.Rand(70, 140), 1)
	end

	// If we hit the ceiling drip blood randomly for a while
	if (Norm.z < -0.5) then
		self.DieTime 		= CurTime() + 10
		self.Pos 			= Pos
		self.NextDrip 		= 0;
		self.LastDelay		= 0;
	end
end

function EFFECT:Think()
	if (!self.DieTime) then return false end
	if (self.DieTime < CurTime()) then return false end
	if (self.NextDrip > CurTime()) then return true end
	
	self.LastDelay = self.LastDelay + math.Rand(0.1, 0.2)
	self.NextDrip = CurTime() + self.LastDelay

	if CurTime() < self.time then
		return true
	else
		return false
	end
end

function EFFECT:Render()
end