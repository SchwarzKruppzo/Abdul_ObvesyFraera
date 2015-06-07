m_tKillingSprees = m_tKillingSprees or {}
m_tKillStreaks = m_tKillStreaks or {}

m_tKillingSprees[5] = { text = "KILLING SPREE", sound = "killingspree.wav" }
m_tKillingSprees[10] = { text = "MASLYATA", sound = "adept.wav" }
m_tKillingSprees[15] = { text = "MASLOROJIY", sound = "maslorozii.wav" }
m_tKillingSprees[20] = { text = "MASLOTERMINATOR", sound = "masloterminator.wav" }
m_tKillStreaks[2] = { text = "DOUBLE KILL", sound = "doublekill.wav" }
m_tKillStreaks[3] = { text = "EXCELLENT", sound = "excellent.wav" }
m_tKillStreaks[4] = { text = "PERFECT", sound = "perfect.wav" }
m_tKillStreaks[6] = { text = "MONSTER KILL", sound = "monsterkill.wav" }
m_tKillStreaks[7] = { text = "1337xLUDICROUSx228 KILL", sound = "ludicrouskill.wav" }
m_tKillStreaks[8] = { text = "KIRITO LIKE", sound = "ultrakill.wav" }
m_tKillStreaks[9] = { text = "CHEATS KILL", sound = "unstoppable.wav" }


local meta = FindMetaTable("Player")

if SERVER then
	util.AddNetworkString( "abdul_net.KS_Changed" )
	util.AddNetworkString( "abdul_net.KS_Reset" )
	util.AddNetworkString( "abdul_net.KS_Headshot" )
	
	function meta:IncreaseKS()
		if not self.KillingSpree then self.KillingSpree = 0 end
		if not self.Killstreak then self.Killstreak = 0 end
		if not self.KillstreakNext then self.KillstreakNext = CurTime() + 10 end
		self.KillingSpree = self.KillingSpree + 1
		self.Killstreak = self.Killstreak + 1
		self.KillstreakNext = CurTime() + 10
		net.Start( "abdul_net.KS_Changed" )
			net.WriteInt( self.KillingSpree, 32 )
			net.WriteInt( self.Killstreak, 32 )
		net.Send( self )
	end
	function meta:ResetSpree()
		self.KillingSpree = 0
		net.Start( "abdul_net.KS_Reset" )
		net.Send( self )
	end
	function meta:ResetStreak()
		self.Killstreak = 0
	end
	function meta:DidHeadshot()
		net.Start( "abdul_net.KS_Headshot" )
		net.Send( self )
	end
	
	hook.Add("PlayerDeath","KILLSPREES.LIB.HOOK",function( victim, inflictor, attacker )
		if attacker != victim then
			if IsValid(attacker) then
				if attacker.IncreaseKS then
					attacker:IncreaseKS()
				end
				if attacker.DidHeadshot then
					if victim.GotHeadshot then
						attacker:DidHeadshot()
					end
				end
			end
			if victim.KillingSpree > 1 then
				Notify(Color(255,120,120),attacker:Nick(),Color(255,255,255)," stopped ",Color(0,200,255,255),victim:Nick(),Color(255,255,255),"'s killing spree ("..victim.KillingSpree..").")
			end
		else
			if victim.KillingSpree > 1 then
				Notify(Color(255,120,120),victim:Nick(),Color(255,255,255)," stopped his own's killing spree ("..victim.KillingSpree..").")
			end
		end
		victim:ResetSpree()
		victim:ResetStreak()
	end)
	hook.Add("Think","KILLSPREES.LIB.HOOK",function()
		for k,v in pairs(player.GetAll()) do
			if v:IsSpectator() then continue end
			if !v.KillstreakNext then v.KillstreakNext = CurTime() end
			if v.KillstreakNext <= CurTime() then
				v:ResetStreak()
			end
		end
	end)
else
	local m_sSpreeName = ""
	local m_sSound = ""
	local m_iNextHint = 0
	local m_bHintShow = false
	
	net.Receive( "abdul_net.KS_Changed", function( len )
		local m_iSpree = net.ReadInt(32)
		local m_iStreak = net.ReadInt(32)
		
		local m_t1 = m_tKillingSprees[m_iSpree]
		local m_t2 = m_tKillStreaks[m_iStreak]
		
		if m_t1 then
			if m_t1.text then m_sSpreeName = m_t1.text end
			if m_t1.sound then m_sSound = m_t1.sound end
		elseif m_t2 then
			if m_t2.text then m_sSpreeName = m_t2.text end
			if m_t2.sound then m_sSound = m_t2.sound end
		end
		if m_sSound != "" then
			surface.PlaySound("abdul/sprees/"..m_sSound)
		end
		m_iNextHint = CurTime() + 2
		m_bHintShow = true
	end)
	net.Receive( "abdulKS_Headshot", function( len )
		m_sSpreeName = "HEADSHOT"
		surface.PlaySound("abdul/sprees/headshot.wav")
		m_iNextHint = CurTime() + 2
		m_bHintShow = true
	end)
	
	local function KillingSpreesHUD()
		if m_bHintShow then
			if m_iNextHint > CurTime() then
				local x = ScrW()/2
				local y = ScrH()/4.5
				x = x + math.Rand(-8,8)
				y = y + math.Rand(-4,4)
				draw.DrawAbdulText( m_sSpreeName, "AFont_KillingSpree", "AFont_KillingSpree_blur",  x, y, Color(255,0,0,150), 1, 0, 0 )
				x = ScrW()/2
				y = ScrH()/4.5
				draw.DrawAbdulText( m_sSpreeName, "AFont_KillingSpree", "AFont_KillingSpree_blur",  x, y, Color(255,0,0,255), 1, 0, 0 )
			else
				m_bHintShow = false
				m_sSpreeName = ""
				m_sSound = ""
				m_iNextHint = 0
			end
		end
	end
	hook.Add("HUDPaint","KILLSPREES.LIB.HOOK",KillingSpreesHUD)
end