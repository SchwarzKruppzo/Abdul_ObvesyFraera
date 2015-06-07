local meta = FindMetaTable("Player")

function meta:GetPlace()
    for k,v in pairs( player.GetSortedPlayers() or {} ) do
        if v == self then return k end
    end
    return 0
end