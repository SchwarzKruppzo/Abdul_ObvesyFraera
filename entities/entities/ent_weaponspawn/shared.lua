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
		if self.mdl then
			self:SetModel( self.mdl )
		end
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:SetAngles(Angle(0,90,0))
		self:SetPos( self:GetPos() + self:GetUp()*15)
		self:DrawShadow(true)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:SetModelScale(1.4, 0)
		self.HasGun = true
	end
	function ENT:Think()
		if self.RespawnTime and CurTime() >= self.RespawnTime then
			self.RespawnTime = nil
			self.HasGun = true
			self:SetNoDraw(false)
			self:EmitSound("weapons/physcannon/physcannon_claws_close.wav")
		end
		for k,v in pairs (player.GetAll()) do
			if v:IsSpectator() then continue end
			if v:GetPos():Distance(self:GetPos()) < 65 and self.HasGun == true and v:Alive() then
				self.HasGun = false
				self:SetNoDraw(true)
				self.RespawnTime = CurTime() + GetConVar("ffa_weapon_restime"):GetInt()
				v:EmitSound("items/ammo_pickup.wav",100,100)
				v:Give(self.class)
				v:SelectWeaponByPriority( self.class )
				hook.Call("PlayerPickupItem",GAMEMODE,v,self.class)
			end
		end
	end
	function ENT:KeyValue( key, value )
		if key == "class" then
			self.class = value
		elseif key == "model" then
			self:SetModel( value )
		end
	end
end