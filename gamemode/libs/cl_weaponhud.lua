CreateConVar( "abdul_fastswitch", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "Weapon fast switching" )

local w, h = surface.GetTextSizeEx( "1", "AFont_Weapon" )
local sizex = 128
local sizey = h*1.5
local x = ScrW()/1.85
local offset = 0
local m_iCurrentSlot = 1
local m_iLifeTime = 0
local m_iDeathTime = 0
local m_iAlpha = 0
local LIFE_TIME = 4
local DEATH_TIME = 5

local m_iQCurrentSlot = nil
local m_iQOldSlot = nil


local function GetLongWeap()
	local Sizes = {}
	for k,v in pairs( LocalPlayer():GetWeapons() ) do
		local str = ClassToFormat( v:GetClass() )
		local w, h = surface.GetTextSizeEx( str, "AFont_Weapon" )
		
		table.insert( Sizes, w )
	end
	local tbl = Sizes
	local TblLen = #tbl
	if TblLen >= 1 then
		for i = TblLen, 1, -1 do
			for j = 1, i-1 do
				if tbl[j] < tbl[j + 1] then
					local temp = tbl[j]
					tbl[j] = tbl[j + 1]
					tbl[j + 1] = temp
				end
			end
		end
		return tbl
	end
	return { [1] = 0 }
end

local function GetSortedWeapons()
	if !LocalPlayer():Alive() then return {} end
	local tbl = table.Copy( LocalPlayer():GetWeapons() )
	local TblLen = #tbl
	if TblLen >= 1 then
		for i = TblLen, 1, -1 do
			for j = 1, i-1 do
				if !IsValid(tbl[j]) then continue end
				if tbl[j].Slot > tbl[j + 1].Slot then
					local temp = tbl[j]
					tbl[j] = tbl[j + 1]
					tbl[j + 1] = temp
				end
				if tbl[j].SlotPos > tbl[j + 1].SlotPos and tbl[j].Slot > tbl[j + 1].Slot then
					local temp = tbl[j]
					tbl[j] = tbl[j + 1]
					tbl[j + 1] = temp
				end
			end
		end
		return tbl
	end
	return {}
end
local function IsWeaponInSlot( weapon )
	if weapon.SlotPos != 0 then
		return true
	end
end
local function DrawWeaponHud()
	local LP = LocalPlayer()
	if !LP:Alive() then 
		m_iCurrentSlot = 1
		return 
	end
	local m_tWeapons = GetSortedWeapons()
	
	local y = ScrH()/2
	sizex = GetLongWeap()[1] + 8
	for chan, dvach in pairs( m_tWeapons ) do
		local v = dvach
		local k = chan
		m_iAlpha = math.Clamp(255 - math.TimeFraction(m_iLifeTime, m_iDeathTime, CurTime()) * 255, 0, 255)
		local m_iAlphaInverted = 255 - m_iAlpha
		local m_tColorBack = Color( 0, 0, 0, m_iAlpha/1.5 )
		local m_tColorText = Color( 200, 200, 200, m_iAlpha )
		local m_iMaxAmmo = 0
		local m_iAmmo = 0
		
		if v.Secondary then
			m_iMaxAmmo = v.Secondary.MaxAmmo or 0
			m_iAmmo = LP:GetAmmoCount( v.Secondary.Ammo )
		end
	
		local i = chan
		if k == m_iCurrentSlot then
			if offset != (sizey + 1)*k - (sizey + 1)/2 then
				offset = Lerp( 0.2, offset, (sizey + 1)*k - (sizey + 1)/2 ) + 0.1
			end
			m_tColorBack = Color( 0, 25, 50, m_iAlpha/1.5 )
			m_tColorText = Color( 0, 200, 255, m_iAlpha )
		end
		
		local m_tSec = v.Secondary or {}
		local m_sAmmo = m_tSec.Ammo or "nil"
		if LP:GetAmmoCount( m_sAmmo ) <= 0 then
			m_tColorBack = Color( 100, 0, 0, m_iAlpha/1.5 )
			if k == m_iCurrentSlot then
				m_tColorText.r = 255
			else
				m_tColorText.r = 200
			end
			m_tColorText.g = 0
			m_tColorText.b = 0
		end
		local x_offset = 0
		if IsWeaponInSlot( v ) then
			x_offset = 16
		end
		
		local pos_y = y + (sizey + 1)*i - offset
		local pos_y2 = pos_y + sizey/3.2
		surface.SetDrawColor( m_tColorBack )
		surface.DrawRect( x + x_offset, pos_y, sizex, sizey )
		draw.DrawAbdulText( ClassToFormat( v:GetClass() ), "AFont_Weapon", "AFont_Weapon_blur",  x + 2.5 + x_offset, pos_y2, m_tColorText, 0, 1, m_iAlphaInverted )
		local w2, h2 = surface.GetTextSizeEx( k, "AFont_Weapon" )
	
		local id = v.Slot + 1
		if !IsWeaponInSlot( v ) then
			draw.DrawAbdulText( id, "AFont_Weapon", "AFont_Weapon_blur",  x - w2 - 8 + x_offset, pos_y + sizey/2 - h2/8, m_tColorText, 0, 1, m_iAlphaInverted )
		end
		if !v.Melee then
			local w2, h2 = surface.GetTextSizeEx( ClassToFormat( v:GetClass() ), "AFont_Weapon" )
			local m_iBarSizeBG = sizex - 8
			local m_iAmmoI = m_iAmmo/m_iMaxAmmo
			local m_iBarSizeActive = m_iAmmoI * m_iBarSizeBG
			surface.SetDrawColor( Color(0,150,0,m_iAlpha/2) )
			surface.DrawRect( x + 4 + x_offset, pos_y + h2, m_iBarSizeBG, 6 )
			surface.SetDrawColor( Color(0,255,0,m_iAlpha/2) )
			surface.DrawRect( x + 4 + x_offset, pos_y + h2, m_iBarSizeActive, 6 )
		end
	end
end
hook.Add( "HUDPaint", "WEAPONHUD.LIB.HOOK", DrawWeaponHud )

local function OnSlotChanged()
	m_iLifeTime = CurTime() + LIFE_TIME
	m_iDeathTime = CurTime() + DEATH_TIME
	m_iQCurrentSlot = GetSortedWeapons()[m_iCurrentSlot]
end
local function checkAmmo()
	for k, dvach in pairs( GetSortedWeapons() ) do
		local m_tSec = dvach.Secondary or {}
		local m_iAmmo = m_tSec.Ammo or "smg1"
		if k == m_iCurrentSlot then
			if LocalPlayer():GetAmmoCount( m_iAmmo ) <= 0 then
				m_iCurrentSlot = m_iCurrentSlot + 1
				checkAmmo()
			end
		end
	end
end
local function checkAmmo2()
	for k, dvach in pairs( GetSortedWeapons() ) do
		local m_tSec = dvach.Secondary or {}
		local m_iAmmo = m_tSec.Ammo or "smg1"
		if k == m_iCurrentSlot then
			if LocalPlayer():GetAmmoCount( m_iAmmo ) <= 0 then
				m_iCurrentSlot = m_iCurrentSlot - 1
				checkAmmo2()
			end
		end
	end
end
local function SelectInSlot( slotID, slotIDSorted) 
	local total = 0
	for k,v in pairs( LocalPlayer():GetWeapons() ) do
		if v.Slot != slotID - 1 then continue end
		if v.SlotPos == 0 then continue end
		total = total + 1
	end
	
	if m_iCurrentSlot >= slotIDSorted + total then
		m_iCurrentSlot = slotIDSorted
		return
	end
	
	m_iCurrentSlot = m_iCurrentSlot + 1
	
	if m_iCurrentSlot < slotIDSorted then
		m_iCurrentSlot = slotIDSorted
	end
end
local function BindPress( ply, bind, pressed )
	local weapon = ply:GetActiveWeapon()

	if !ply:InVehicle() and ( !IsValid( weapon ) or !ply:KeyDown(IN_ATTACK) ) then
		bind = string.lower(bind)

		if string.find(bind, "invprev") and pressed then
			m_iCurrentSlot = m_iCurrentSlot - 1
			if m_iCurrentSlot <= 0 then
				m_iCurrentSlot = #GetSortedWeapons()
			end
			checkAmmo2()
			OnSlotChanged()
			return true
		elseif string.find(bind, "invnext") and pressed then
			m_iCurrentSlot = m_iCurrentSlot + 1
			if m_iCurrentSlot > #GetSortedWeapons() then
				m_iCurrentSlot = 1
			end
			checkAmmo()
			OnSlotChanged()
			return true
		elseif string.find(bind, "+attack") and pressed then
			if CurTime() < m_iDeathTime then
				m_iLifeTime = 0
				m_iDeathTime = 0
				for k, v in SortedPairs(GetSortedWeapons()) do
					if (k == m_iCurrentSlot) then
						m_iQOldSlot = LocalPlayer():GetActiveWeapon()
						LocalPlayer():EmitSound("common/wpn_select.wav")
						RunConsoleCommand("abdul_selectwep", v:GetClass())
						return true
					end
				end
			end
		elseif string.find(bind, "slot") and pressed then
			m_iOldSlot = m_iCurrentSlot
			
			local slot = tonumber(string.match(bind, "slot(%d)")) or 1
			for k,v in pairs( LocalPlayer():GetWeapons() ) do
				if v.Slot != (slot - 1) then continue end
				if !IsWeaponInSlot( v ) then
					SelectInSlot( slot, table.KeyFromValue( GetSortedWeapons(), v )) 
					m_iQCurrentSlot = GetSortedWeapons()[m_iCurrentSlot]
					if GetConVar("abdul_fastswitch"):GetBool() then
						OnSlotChanged()
					else
						m_iLifeTime = 0
						m_iDeathTime = 0
						for k, v in SortedPairs(GetSortedWeapons()) do
							if (k == m_iCurrentSlot) then
								if LocalPlayer():GetActiveWeapon() == v then continue end
								
								m_iQOldSlot = LocalPlayer():GetActiveWeapon() 
								LocalPlayer():EmitSound("common/wpn_select.wav")
								RunConsoleCommand("abdul_selectwep", v:GetClass())
								return true
							end
						end
					end
					return true
				end
			end
		elseif string.find(bind, "+menu") and pressed then
			local cache = 0
			m_iLifeTime = 0
			m_iDeathTime = 0
			for k, v in pairs(GetSortedWeapons()) do
				if (v == m_iQOldSlot) then
					cache = m_iQOldSlot
					
					m_iQOldSlot = m_iQCurrentSlot
					m_iQCurrentSlot = cache

					RunConsoleCommand("abdul_selectwep", v:GetClass())
					return true
				end
			end
		end
	end
end
hook.Add( "PlayerBindPress", "WEAPONHUD.LIB.HOOK", BindPress)