local random = math.randomMODE["MLG.fx.OnFight"] = function()	if random(1,3) == 1 then		LocalPlayer():EmitSound("abdul/mlg/horn.mp3", 75)	end	timer.Simple( random(1,4), function()		if random(1,2) == 1 then			LocalPlayer():EmitSound("abdul/mlg/wow.mp3", 75)		end	end)end