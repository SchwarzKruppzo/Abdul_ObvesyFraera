local clamp, getTextSize, setDrawColor, noTexture, drawPoly, drawRect, drawText = math.Clamp, surface.GetTextSizeEx, surface.SetDrawColor, draw.NoTexture, surface.DrawPoly, surface.DrawRect, draw.DrawAbdulText
local screenScaleEx = ScreenScaleEx
local m_iMig = false
local m_iNextMig = CurTime()
local m_iMigAmmo = false
local m_iNextMigAmmo = CurTime()

local function DrawHealth()
	local LP = LocalPlayer()
	if !LP:Alive() then return end
	if LP:IsSpectator() then return end
	local m_iHealth = clamp( LP:Health(), 0, 999 )
	local m_iBarW = screenScaleEx(300)
	local m_iBarH = screenScaleEx(110)
	local m_iBarBorder = 16
	local m_iHealthBBW = m_iBarW - screenScaleEx(15)
	local m_iMainBar_x = ScrW()/2 - m_iHealthBBW/2
	local text = m_iHealth
	local x = ScrW()/2 - m_iBarW/2
	local y = ScrH() - m_iBarH
	local w,h = getTextSize( text, "AFont_Hud" )
	local var = m_iHealthBBW * clamp( m_iHealth/100, 0, 1 )
	
	m_vMainPanel = {
		{ x = x, y = y + m_iBarH}, 
		{ x = x - screenScaleEx(60), y = y }, 
		{ x = x + m_iBarW + screenScaleEx(60), y = y }, 
		{ x = x + m_iBarW, y = y + m_iBarH}
	}

	setDrawColor( 0, 0, 0, 200 )
	noTexture()
	drawPoly( m_vMainPanel )
	setDrawColor( 255, 255, 255, 255 )
	drawRect( m_iMainBar_x ,y + h, m_iHealthBBW,screenScaleEx(6))
	setDrawColor( 0, 0, 0, 255 )
	drawRect( m_iMainBar_x + 1,y + h + 1, m_iHealthBBW - 2,screenScaleEx(6) - 2)
	drawText( "HEALTH", "AFont_Hud2", "AFont_Hud2_blur",  m_iMainBar_x - 1, y + h + screenScaleEx(5), Color(230,230,230,255), 0, 0, 0 )

	local m_tColor = Color(50,255,50,255)
	setDrawColor( 0, 200, 0, 255 )
	
	if LP:Health() > 100 then
		m_tColor = Color(0,200,255,255)
		setDrawColor( 0, 200, 255, 255 )
	end
	if LP:Health() < 50 then
		if m_iMig then
			setDrawColor( 200, 0, 0, 255 )
			m_tColor = Color(255,50,50,255)
		end
		if m_iNextMig < CurTime() then
			m_iMig = !m_iMig
			m_iNextMig = CurTime() + 0.4
		end
	end
	drawRect( m_iMainBar_x + 1,y + h + 1, var - 2,screenScaleEx(6) - 2)
	drawText( text, "AFont_Hud", "AFont_Hud_blur",  x + m_iBarW/2, y, m_tColor, 1, 0, 0 )
end
local function DrawArmor()
	local LP = LocalPlayer()
	if !LP:Alive() then return end
	if LP:IsSpectator() then return end
	if LP:Armor() == 0 then return end
	
	local m_iBarW = screenScaleEx(300)
	local m_iBarH = screenScaleEx(110)
	local m_iBarBorder = 16
	local m_iArmorBBW = m_iBarW - screenScaleEx(90)
	local m_iMainBar_x = ScrW()/2 + screenScaleEx(300)/2 + m_iBarW/2 - m_iArmorBBW/2 + 5
	local text = LP:Armor()
	local x = ScrW()/2 + screenScaleEx(300)/2 + 5
	local y = ScrH() - m_iBarH
	local w,h = getTextSize( text, "AFont_Hud" )
	local var = m_iArmorBBW * clamp( LP:Armor()/200, 0, 1 )
	
	local m_vPanel = {
		{ x = x, y = y + m_iBarH}, 
		{ x = x + screenScaleEx(60), y = y }, 
		{ x = x + m_iBarW - screenScaleEx(60), y = y }, 
		{ x = x + m_iBarW, y = y + m_iBarH}
	}

	setDrawColor( 0, 0, 0, 200 )
	noTexture()
	drawPoly( m_vPanel )
	setDrawColor( 255, 255, 255, 255 )
	drawRect( m_iMainBar_x ,y + h, m_iArmorBBW,screenScaleEx(6))
	setDrawColor( 0, 0, 0, 255 )
	drawRect( m_iMainBar_x + 1,y + h + 1, m_iArmorBBW - 2,screenScaleEx(6) - 2)
	drawText( "ARMOR", "AFont_Hud2", "AFont_Hud2_blur",  m_iMainBar_x - 1, y + h + screenScaleEx(5), Color(230,230,230,255), 0, 0, 0 )

	local m_tColor = Color(255,250,50,255)
	setDrawColor( 200, 150, 0, 255 )
	drawRect( m_iMainBar_x + 1,y + h + 1, var - 2,screenScaleEx(6) - 2)
	drawText( text, "AFont_Hud", "AFont_Hud_blur",  x + m_iBarW/2, y, m_tColor, 1, 0, 0 )
end

local function DrawAmmo()
	local LP = LocalPlayer()
	if !LP:Alive() then return end
	if LP:IsSpectator() then return end
	if !LP:GetActiveWeapon().Secondary then return end
	if LP:GetActiveWeapon().Melee then return end
	
	local m_iMaxAmmo = LP:GetActiveWeapon().Secondary.MaxAmmo or 0
	local m_iAmmo = LP:GetAmmoCount( LP:GetActiveWeapon().Secondary.Ammo )
	local m_iAmmoName = ClassToFormat( LP:GetActiveWeapon().Secondary.Ammo )
	local m_iWeaponName = ClassToFormat( LP:GetActiveWeapon():GetClass() )
	local m_iBarW = screenScaleEx(300)
	local m_iBarH = screenScaleEx(110)
	local m_iBarBorder = 16
	local m_iArmorBBW = m_iBarW - screenScaleEx(90)
	local m_iMainBar_x = ScrW()/2 - m_iBarW - screenScaleEx(300)/2 + m_iBarW/2 - m_iArmorBBW/2 - 5
	local text = m_iAmmo
	local x = ScrW()/2 - m_iBarW - screenScaleEx(300)/2 - 5
	local y = ScrH() - m_iBarH
	local w,h = getTextSize( text, "AFont_Hud" )
	local var = m_iArmorBBW * clamp( m_iAmmo/m_iMaxAmmo, 0, 1 )
	local font_w,font_h = getTextSize( m_iWeaponName, "AFont_Hud2")
	
	local m_vPanel = {
		{ x = x, y = y + m_iBarH},
		{ x = x + screenScaleEx(60), y = y }, 
		{ x = x + m_iBarW - screenScaleEx(60), y = y },
		{ x = x + m_iBarW, y = y + m_iBarH}
	}

	setDrawColor( 0, 0, 0, 200 )
	noTexture()
	drawPoly( m_vPanel )
	setDrawColor( 255, 255, 255, 255 )
	drawRect( m_iMainBar_x ,y + h, m_iArmorBBW,screenScaleEx(6))
	setDrawColor( 0, 0, 0, 255 )
	drawRect( m_iMainBar_x + 1,y + h + 1, m_iArmorBBW - 2,screenScaleEx(6) - 2)
	drawText( m_iWeaponName, "AFont_Hud2", "AFont_Hud2_blur",  m_iMainBar_x - 1, y + h - font_h - 1, Color(230,230,230,255), 0, 0, 0 )
	drawText( "AMMO - " .. m_iAmmoName, "AFont_Hud2", "AFont_Hud2_blur",  m_iMainBar_x - 1, y + h + screenScaleEx(5), Color(230,230,230,255), 0, 0, 0 )

	local m_tColor = Color(255,255,255,255)
	setDrawColor( 150, 150, 150, 255 )
	if m_iAmmo <= m_iMaxAmmo/2.5 then
		if m_iMigAmmo then
			setDrawColor( 200, 0, 0, 255 )
			m_tColor = Color(255,50,50,255)
		end
		if m_iNextMigAmmo < CurTime() then
			m_iMigAmmo = !m_iMigAmmo
			m_iNextMigAmmo = CurTime() + 0.4
		end
	end
	drawRect( m_iMainBar_x + 1,y + h + 1, var - 2,screenScaleEx(6) - 2)
	drawText( text, "AFont_Hud", "AFont_Hud_blur",  x + m_iBarW/2, y, m_tColor, 1, 0, 0 )
end
local function DrawSpectator()
	local LP = LocalPlayer()
	if !LP:IsSpectator() then return end
	local target = LP:GetObserverTarget()
	if !IsValid(target) then return end
	
	local text1 = "You are spectating "
	local text2 = target:Nick()
	
	local w1,h = getTextSize( text1, "AFont_Respawn" )
	local w2,h = getTextSize( text2, "AFont_Respawn" )
	local w3,h = getTextSize( text1 .. text2, "AFont_Respawn" )
	
	
	local x = ScrW()/2 - ( w1 + w2 )/2
	draw.DrawAbdulText( text1, "AFont_Respawn", "AFont_Respawn_blur",  x, ScrH() - 5 - h, Color(255,255,255,255), 0, 0, 0 )
	local x = x + w1
	draw.DrawAbdulText( text2, "AFont_Respawn", "AFont_Respawn_blur",  x, ScrH() - 5 - h, Color(255,110,110,255), 0, 0, 0 )
end
local function DrawClaymore()
	if LocalPlayer():IsSpectator() then return end
	if !IsValid(LocalPlayer():GetWeapon("abdul_claymore")) then return end
	local b_w,b_h = surface.GetTextSizeEx( "0", "AFont_Tools" )
	local size = ScreenScaleEx(36)
	local x = m_vMainPanel[2].x + 5
	local y = m_vMainPanel[2].y - size - 8
	
	local rect_x = m_vMainPanel[2].x
	local rect_y = m_vMainPanel[2].y - size - 13
	local rect_w = ScrW() - m_vMainPanel[2].x - m_vMainPanel[2].x
	local rect_h = size + 10
	
	setDrawColor( 0, 0, 0, 200 )
	drawRect( rect_x,rect_y,rect_w,rect_h)
	
	local color = LocalPlayer():GetToolsLimit( "Claymore" ) == 6 and Color(250,50,50,255) or Color(220,250,255,255)
	surface.SetDrawColor(color)

	surface.SetMaterial(Material("abdul/claymore.png"))
	surface.DrawTexturedRect( x,y,size,size)
	
	draw.DrawAbdulText( "x"..LocalPlayer():GetToolsLimit( "Claymore" ), "AFont_Tools", "AFont_Tools_blur",  x + size, y + size/2 - 2, color, 0, 0, 0 )
end
local function DrawSpawns()
	cam.Start3D(EyePos(),EyeAngles())
		for k,v in pairs(ents.FindByClass("ent_weaponspawn")) do
			local trace = {}
			trace.start = v:GetPos()
			trace.endpos = v:GetPos() - Vector(0,0,1)*100000
			trace.mask = CONTENTS_SOLID
			local tr = util.TraceLine( trace )
			
			render.SetMaterial( Material("sprites/physg_glow1") )
			render.DrawQuadEasy( tr.HitPos + tr.HitNormal, tr.HitNormal, 128, 128, Color(55,200,255) )
			render.DrawQuadEasy( tr.HitPos + tr.HitNormal, tr.HitNormal, 64, 64, color_white )
		end
	cam.End3D()
end

function GM:HUDMain()
	DrawHealth()
	DrawArmor()
	DrawAmmo()
	DrawClaymore()
	DrawSpectator()
end

hook.Add("PostDrawOpaqueRenderables","MAIN.LIB.HOOK",DrawSpawns)