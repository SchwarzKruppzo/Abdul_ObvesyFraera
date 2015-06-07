ENT.Type = "anim"
if CLIENT then
	function ENT:Initialize()
		self.OriginPos = self:GetPos()
		self.Spin = 0
	end
	function ENT:Draw()
		self:SetRenderOrigin(self.OriginPos + Vector(0,0,math.abs(math.sin(RealTime() * 1) *5.5)))
		self:SetupBones()
		self:DrawModel()
		self.Spin = NormalizeAngle(self.Spin + 1)
		self:SetAngles(Angle(0,self.Spin,0))
	end
	function ENT:IsTranslucent()
		return true
	end
else
	AddCSLuaFile()
	function ENT:Initialize()
		self:SetModel("models/of_armorshard.mdl")
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:DrawShadow(true)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self.HasArmor = true
	end
	function ENT:Think()
		if self.RespawnTime and CurTime() >= self.RespawnTime then
			self.RespawnTime = nil
			self.HasArmor = true
			self:SetNoDraw(false)
			self:EmitSound("weapons/physcannon/physcannon_claws_close.wav")
		end
		for k,v in pairs (player.GetAll()) do
			if v:IsSpectator() then continue end
			if v:GetPos():Distance(self:GetPos()) < 50 and self.HasArmor == true and v:Alive() and v:Armor() < 200 then
				self.HasArmor = false
				self:SetNoDraw(true)
				self.RespawnTime = CurTime() + GetConVar("ffa_armor_restime"):GetInt()
				v:EmitSound("items/battery_pickup.wav",40,100)
				v:SetArmor(math.Clamp(v:Armor() + 5,0,200))
				hook.Call("PlayerPickupItem",GAMEMODE,v,self:GetClass())
			end
		end
	end

end