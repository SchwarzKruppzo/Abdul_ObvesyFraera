MODE.Name = "Free For All"
MODE.Tag = "FFA"

abdulmode.Include( "sh_deathnotices.lua" )
abdulmode.Include( "sh_fraghint.lua" )
abdulmode.Include( "sh_roundmusic.lua" )

function MODE:Initialize()

end

GS_WAITING_PLAYERS = 0
GS_ROUND_PREPARE = 1
GS_ROUND_PLAYING = 3
GS_ROUND_END = 4
GS_GAME_OVER = 5

function GetWinner()
	return GetGlobalEntity("CURRENT_WINNER")
end
function GetFragsRemaining()
	return GetGlobalInt("CURRENT_FRAGREMAINING")
end
function GetRoundTime()
	return GetGlobalInt("CURRENT_ROUNDTIME")
end
function GetRound()
	return GetGlobalInt("CURRENT_ROUND")
end
function GetGameState()
	return GetGlobalInt("CURRENT_GAME_STATE")
end