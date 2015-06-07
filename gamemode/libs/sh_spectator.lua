spectator = {}
local meta = FindMetaTable("Player")


function meta:IsSpectator()
	return (self:Team() == 0 or self:Team() == 2)
end


function spectator.KeyPress( ply, key )
	if not IsValid(ply) then return end
	if ply:IsSpectator() then
	if key == IN_ATTACK then
		ply:Spectate(OBS_MODE_ROAMING)
		ply:SetEyeAngles(Angle())
		ply:SpectateEntity(nil)
		
		local alive = player.GetAlivePlayers()
		if #alive < 1 then return end
			local target = table.Random(alive)
			if IsValid(target) then
				ply:SetPos(target:EyePos())
				ply:SetEyeAngles(target:EyeAngles())
			end
		elseif key == IN_ATTACK2 then
			local target = player.GetNextPlayerAlive(ply:GetObserverTarget())

			if IsValid(target) then
				ply:Spectate(ply.specmode or OBS_MODE_CHASE)
				ply:SpectateEntity(target)
			end
		elseif key == IN_DUCK then
			local pos = ply:GetPos()
			local ang = ply:EyeAngles()
			local target = ply:GetObserverTarget()
			if IsValid(target) and target:IsPlayer() then
				pos = target:EyePos()
				ang = target:EyeAngles()
			end
			ply:Spectate(OBS_MODE_ROAMING)
			ply:SpectateEntity(nil)
			ply:SetPos(pos)
			ply:SetEyeAngles(ang)
			return true
		elseif key == IN_JUMP then
			if not (ply:GetMoveType() == MOVETYPE_NOCLIP) then
				ply:SetMoveType(MOVETYPE_NOCLIP)
			end
		elseif key == IN_RELOAD then
			local tgt = ply:GetObserverTarget()
			if not IsValid(tgt) or not tgt:IsPlayer() then return end
			if not ply.specmode or ply.specmode == OBS_MODE_CHASE then
				ply.specmode = OBS_MODE_IN_EYE
			elseif ply.specmode == OBS_MODE_IN_EYE then
				ply.specmode = OBS_MODE_CHASE
			end
			ply:Spectate(ply.specmode)
		end
	end
end


if SERVER then hook.Add( "KeyPress", "LIB.HOOK.Spectator", spectator.KeyPress ) end
