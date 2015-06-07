CreateClientConVar( "abdul_railguncolor", "255 0 0", true, true )

local function DrawCurlyBeam( StartPos, EndPos, Angle, alpha )
	local Forward	= Angle:Forward()
	local Right 	= Angle:Right()
	local Up 		= Angle:Up()
	local LastPos
	local Distance = StartPos:Distance( EndPos )
	local StepSize = 16
	local RingTightness = 0.05
	local DistPly = 0
	
	render.SetMaterial( Material("particle/bendibeam") )
	for i=0, Distance, StepSize do
		if DistPly > 2000 then continue end
		
		local sin = math.sin( 100 * -30 + i * RingTightness )
		local cos = math.cos( 100 * -30 + i * RingTightness )
		local Pos = StartPos + (Forward * i) + (Up * sin * 4) + (Right * cos * 4)
		DistPly = LocalPlayer():GetPos():Distance( Pos )
		
		if (LastPos) then
			render.DrawBeam( LastPos, Pos, (math.sin( i*0.002 )+1) * 16, 0, 0, Color( 110, 100, 255, alpha ) )	 
		end		 
		LastPos = Pos
		
	end
end

local EFFECT = {}
function EFFECT:Init(data)
	self.WeaponEnt = data:GetEntity()
	self.Attachment = "1"
	self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Col = data:GetStart()
	self.Color = Color( self.Col.x, self.Col.y, self.Col.z )
	
	self.EndPos = data:GetOrigin()
	self.alpha = 255
	self:SetRenderBoundsWS(self.Position, self.EndPos)
end

function EFFECT:Think()
	local form = (255/1.5) * FrameTime()*3
	self.alpha = self.alpha - form
	self.alpha = math.Clamp(self.alpha,0,255)
	self.Color.r = self.Color.r - form
	self.Color.r = math.Clamp(self.Color.r,0,255)
	self.Color.g = self.Color.g - form
	self.Color.g = math.Clamp(self.Color.g,0,255)
	self.Color.b = self.Color.b - form
	self.Color.b = math.Clamp(self.Color.b,0,255)
	
	local al = math.Clamp(self.alpha,0,255)
	if al <= 0 then return false end	
	return true
end

function EFFECT:Render()
	local Angle = (self.EndPos - self.Position):Angle()
	
	render.SetMaterial(Material("effects/laser1"))
	render.DrawBeam(self.Position, self.EndPos, 32, 0, 0, self.Color)
	DrawCurlyBeam( self.Position, self.EndPos, Angle, self.alpha )
end

effects.Register( EFFECT, "railgun_laser" )

EFFECT = {}
function EFFECT:Init(data)
	self.StartPos = data:GetNormal()
	self.Col = data:GetStart()
	self.Color = Color( self.Col.x, self.Col.y, self.Col.z )
	
	self.EndPos = data:GetOrigin()
	self.alpha = 255
	self:SetRenderBoundsWS(self.StartPos, self.EndPos)
end

function EFFECT:Think()
	local form = (255/1.5) * FrameTime()*3
	self.alpha = self.alpha - form
	self.alpha = math.Clamp(self.alpha,0,255)
	self.Color.r = self.Color.r - form
	self.Color.r = math.Clamp(self.Color.r,0,255)
	self.Color.g = self.Color.g - form
	self.Color.g = math.Clamp(self.Color.g,0,255)
	self.Color.b = self.Color.b - form
	self.Color.b = math.Clamp(self.Color.b,0,255)
	
	local al = math.Clamp(self.alpha,0,255)
	if al <= 0 then return false end	
	return true
end

function EFFECT:Render()
	local Angle = (self.EndPos - self.StartPos):Angle()
	
	render.SetMaterial(Material("effects/laser1"))
	render.DrawBeam(self.StartPos, self.EndPos, 32, 0, 0, self.Color)
	DrawCurlyBeam( self.StartPos, self.EndPos, Angle, self.alpha )
end

effects.Register( EFFECT, "railgun_laser2" )