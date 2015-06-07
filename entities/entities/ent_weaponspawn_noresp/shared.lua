ENT.Type = "anim"
if CLIENT then
	function ENT:Initialize()
		self.Spin = 0
	end
	function ENT:Draw()
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
		self:SetModel(self.MDL)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:SetAngles(Angle(0,90,0))
		self:DrawShadow(true)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:SetModelScale(1.4, 0)
		self.HasGun = true
	end
	function ENT:Think()
		local tracedata = {}
		tracedata.start = self:GetPos()
		tracedata.endpos = self:GetPos() - self:GetUp() * 20
		tracedata.filter = { self }
		local trace = util.TraceLine(tracedata)
		if !trace.Hit then
			self:SetPos(trace.HitPos)
		end
		for k,v in pairs (player.GetAll()) do
			if v:IsSpectator() then continue end
			if v:GetPos():Distance(self:GetPos()) < 75 and self.HasGun == true and v:Alive() then
				self.HasGun = false
				self:SetNoDraw(true)
				v:EmitSound("items/ammo_pickup.wav",100,100)
				v:Give(self.Class)
				v:SelectWeaponByPriority( self.Class )
				hook.Call("PlayerPickupItem",GAMEMODE,v,self.Class)
				self:Remove()
			end
		end
		self:NextThink(CurTime())
		return true
	end

end