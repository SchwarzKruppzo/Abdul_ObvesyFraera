function player.GetAlivePlayers()
	local tbl = {}
	for k,v in pairs(player.GetAll()) do
		if v:IsSpectator() then continue end
		table.insert(tbl,v)
	end
	return tbl
end
function player.GetSpectatorPlayers()
	local tbl = {}
	for k,v in pairs(player.GetAll()) do
		if !v:IsSpectator() then continue end
		table.insert(tbl,v)
	end
	return tbl
end

function player.GetSortedPlayers( spectators )
	local tbl = table.Copy( player.GetAlivePlayers() )
	local TblLen = #tbl
	if TblLen >= 1 then
		for i = TblLen, 1, -1 do
			for j = 1, i-1 do
				if tbl[j]:Frags() < tbl[j + 1]:Frags() then
					local temp = tbl[j]
					tbl[j] = tbl[j + 1]
					tbl[j + 1] = temp
				end
				if tbl[j]:Deaths() > tbl[j + 1]:Deaths() and tbl[j]:Frags() < tbl[j + 1]:Frags() then
					local temp = tbl[j]
					tbl[j] = tbl[j + 1]
					tbl[j + 1] = temp
				end
			end
		end
		if spectators then
			for k,v in pairs(player.GetAll()) do
				if !v:IsSpectator() then continue end
				table.insert( tbl, v )
			end
		end
		return tbl
	end
	return {}
end

function player.GetNextPlayerAlive( ply )
	local alive = player.GetAlivePlayers()
	if #alive < 1 then return nil end
	local prev = nil
	local choice = nil
	if IsValid(ply) then
		for k,p in pairs(alive) do
			if prev == ply then
				choice = p
			end
			prev = p
		end
	end
	if not IsValid(choice) then
		choice = alive[1]
	end
	return choice
end


function table.Compare( t1, t2 )
	if table.Count(t1) ~= table.Count(t2) then return false end
	for k1,v1 in pairs(t1) do
		for k2,v2 in pairs(t2) do
			if k1==k2 and v1 ~= v2 then
				return false
			end
		end
	end
	return true
end