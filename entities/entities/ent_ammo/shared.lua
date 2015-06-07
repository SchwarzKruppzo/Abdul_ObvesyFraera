ENT.Type = "anim"
ENT.Colors = {}
ENT.Colors["RailCells"] = Color(20,200,20)
ENT.Colors["rockets"] = Color(200,0,0)
ENT.Colors["AK47"] = Color(255,100,0)
ENT.Colors["shotbuck"] = Color(100,100,50)
ENT.Colors["45ACP"] = Color(255,255,255)
ENT.Colors["mlg"] = Color(127,50,220)
ENT.Colors["ShrapBomb"] = Color(127,50,0)

ENT.MaxAmmo = {}
ENT.MaxAmmo["RailCells"] = 10
ENT.MaxAmmo["rockets"] = 15
ENT.MaxAmmo["AK47"] = 100
ENT.MaxAmmo["shotbuck"] = 15
ENT.MaxAmmo["45ACP"] = 100
ENT.MaxAmmo["mlg"] = 15
ENT.MaxAmmo["ShrapBomb"] = 10

if CLIENT then
	surface.CreateFont("AFont_EntAmmo",{font = "Calibri",size = 128,weight = 1000})
	
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
		
		local ang = self:GetAngles()
		ang:RotateAroundAxis( ang:Forward(),90 )
		local pos = self:GetPos() + self:GetUp() * 13 + self:GetRight()*14
		cam.Start3D2D( pos, ang, 0.035 )
				draw.RoundedBox(0,-345,-165,200*3.65,200*2.6,Color(40,40,40,255))
                draw.DrawText(ClassToFormat( self:GetAmmoTyp() ), "AFont_EntAmmo", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
        cam.End3D2D()
		
		local ang = self:GetAngles()
		ang:RotateAroundAxis( ang:Forward(),90 )
		ang:RotateAroundAxis( ang:Right(),180 )
		local pos = self:GetPos() + self:GetUp() * 13 - self:GetRight()*12.5 + self:GetForward()*1.2
		cam.Start3D2D( pos, ang, 0.035 )
				draw.RoundedBox(0,-345,-165,200*3.65,200*2.6,Color(40,40,40,255))
                draw.DrawText(ClassToFormat( self:GetAmmoTyp() ), "AFont_EntAmmo", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
        cam.End3D2D()
	end
	function ENT:IsTranslucent()
		return true
	end
else
	AddCSLuaFile()
	function ENT:Initialize()
		self:SetAmmoTyp( self.ammotyp )
		self:SetModel("models/of_ammo.mdl")
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:DrawShadow(true)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self.HasAmmo = true
		if self.Colors[self:GetAmmoTyp()] then
			self:SetColor(self.Colors[self:GetAmmoTyp()])
		end
	end
	function ENT:Think()
		if self.RespawnTime and CurTime() >= self.RespawnTime then
			self.RespawnTime = nil
			self.HasAmmo = true
			self:SetNoDraw(false)
			self:EmitSound("weapons/physcannon/physcannon_claws_close.wav")
		end
		for k,v in pairs (player.GetAll()) do
			if v:IsSpectator() then continue end
			if v:GetPos():Distance(self:GetPos()) < 50 and self.HasAmmo == true then
				if v:GetAmmoCount( self:GetAmmoTyp() ) < self.MaxAmmo[ self:GetAmmoTyp() ] then
					self.HasAmmo = false
					self:SetNoDraw(true)
					self.RespawnTime = CurTime() + GetConVar("ffa_ammo_restime"):GetInt()
					self:EmitSound("items/ammo_pickup.wav",70,100)
					v:GiveAmmo( self.MaxAmmo[ self:GetAmmoTyp() ] - v:GetAmmoCount( self:GetAmmoTyp() ), self:GetAmmoTyp() );
					hook.Call("PlayerPickupItem",GAMEMODE,v,self:GetAmmoTyp())
				end
			end
		end
	end
	function ENT:KeyValue( key, value )
		if key == "ammotype" then
			self:SetAmmoTyp( value )
		end
	end
end

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "AmmoTyp" );
end