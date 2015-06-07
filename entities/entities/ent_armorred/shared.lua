ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Seed = 1
if CLIENT then
	local matWireframe = Material("models/debug/debugwhite")
	local matWhite = Material("models/props_combine/portalball001_sheet")
	
	local params = {
		["$basetexture"] = "sprites/glow_test02",
		["$additive"] = 1,
		["$translucent"] = 1,
		["$vertexcolor"] = 1,
	}
	local matGlow = CreateMaterial("GlowTest2282","UnlitGeneric",params)
	function ENT:Initialize()
		self.OriginPos = self:GetPos() + self:GetUp()*18
		self.Spin = 0
		self.Point = util.GetPixelVisibleHandle()
	end
	function ENT:Think()
		if self:GetHasArmor() then
			self.Dyn = DynamicLight(self.Entity:EntIndex())
			self.Dyn.Pos = self.Entity:GetPos()
			self.Dyn.Size = 100
			self.Dyn.Decay = 0
			self.Dyn.R = 255
			self.Dyn.G = 0
			self.Dyn.B = 0
			self.Dyn.Brightness = 6
			self.Dyn.DieTime = CurTime() + 0.01
		end
	end
	function ENT:DrawTranslucent()
		local LightNrm = self.Entity:GetAngles():Up()
		local ViewNormal = self.Entity:GetPos() - EyePos()
		local Distance = ViewNormal:Length()
		ViewNormal:Normalize()
		local ViewDot = 1
		local LightPos = self.Entity:GetPos() + LightNrm * 5
		if ( ViewDot >= 0 ) then
			local Visibile	= util.PixelVisible( LightPos, 16, self.Entity.Point )	
			
			if (!Visibile) then return end
			local Size = math.Clamp( Distance * Visibile * ViewDot * 2, 0, 128 )
			Distance = math.Clamp( Distance, 32, 800 )
			local Alpha = math.Clamp( (1000 - Distance) * Visibile * ViewDot, 0, 255 )
			render.SetMaterial(Material("sprites/light_ignorez"))
			render.DrawSprite( self:GetPos()+ self:GetUp() *5, Size/2.5,Size/2.5,Color(255,255,255,Alpha))
			render.DrawSprite( self:GetPos()+ self:GetUp() *5, Size,Size,Color(255,0,0,Alpha))
			render.DrawSprite( self:GetPos()+ self:GetUp() *5, Size,Size,Color(255,0,0,Alpha))
			render.DrawSprite( self:GetPos()+ self:GetUp() *5, Size,Size,Color(255,0,0,Alpha))
		end
		self:SetRenderOrigin(self.OriginPos + Vector(0,0,math.abs(math.sin(RealTime() * 1) *5)))
		self:SetupBones()
		self:DrawModel()
		self.Spin = NormalizeAngle(self.Spin + 1)
		self:SetAngles(Angle(0,self.Spin,0))
		local time = (CurTime() * 1.5 + self.Seed) % 1

		self:DrawModel()

		if time <= 1 and EyePos():Distance(self:GetPos()) <= 1024 then
			local oldscale = self:GetModelScale()
			local normal = self:GetUp()
			local rnormal = normal * -1
			local mins = self:OBBMins()
			local dist = self:OBBMaxs().z - mins.z
			mins.x = 0
			mins.y = 0
			local pos = self:LocalToWorld(mins)

			self:SetModelScale(oldscale * 2, 0)

			if render.SupportsVertexShaders_2_0() then
				render.EnableClipping(true)
				render.PushCustomClipPlane(normal, normal:Dot(pos + dist * time * normal))
				render.PushCustomClipPlane(rnormal, rnormal:Dot(pos + dist * time * 1.5 * normal))
			end

			render.SetColorModulation(1, 0, 0)
			render.SuppressEngineLighting(true)

			render.SetBlend(0.5)
			render.ModelMaterialOverride(matWireframe)
			self:DrawModel()
		
			render.SetColorModulation(1, 0.1, 0)
			for i = 0, 25 do
			render.SetBlend(1)
			render.ModelMaterialOverride(matWhite)
			self:DrawModel()
			end

			render.ModelMaterialOverride(0)
			render.SuppressEngineLighting(false)
			render.SetBlend(1)
			render.SetColorModulation(1, 1, 1)

			if render.SupportsVertexShaders_2_0() then
				render.PopCustomClipPlane()
				render.PopCustomClipPlane()
				render.EnableClipping(false)
			end
			self:SetModelScale(oldscale, 0)
		end
	end
	function ENT:IsTranslucent()
		return true
	end
else
	AddCSLuaFile()
	function ENT:Initialize()
		self:SetModel("models/w_armor.mdl")
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:SetPos( self:GetPos() + self:GetUp() * 15 )
		self:DrawShadow(true)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:SetModelScale(1.2,0)
		self:SetHasArmor( true )
	end
	function ENT:Think()
		if self.RespawnTime and CurTime() >= self.RespawnTime then
			self.RespawnTime = nil
			self:SetHasArmor( true )
			self:SetNoDraw(false)
			self:EmitSound("weapons/physcannon/physcannon_claws_close.wav")
		end
		for k,v in pairs (player.GetAll()) do
			if v:IsSpectator() then continue end
			if v:GetPos():Distance(self:GetPos()) < 50 and self:GetHasArmor() and v:Alive() and v:Armor() < 200 then
				self:SetHasArmor( false )
				self:SetNoDraw(true)
				self.RespawnTime = CurTime() + GetConVar("ffa_armorred_restime"):GetInt()
				v:EmitSound("items/battery_pickup.wav",40,100)
				v:SetArmor(math.Clamp(v:Armor() + 150,0,200))
				hook.Call("PlayerPickupItem",GAMEMODE,v,self:GetClass())
			end
		end
	end

end

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "HasArmor" )
end