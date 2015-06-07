CreateConVar( "abdul_gamemode", "ffa", FCVAR_NOTIFY )
abdulmode = {}
abdulmode.dir = GM.FolderName.."/gamemode/modes/"
abdulmode.curdir = ""

function abdulmode.GetCurrent()
	return GetConVarString( "abdul_gamemode" )
end
function abdulmode.GetCurrentDirectory()
	return abdulmode.curdir
end

local function loadGamemode( dir )
	local files, folders = file.Find( dir .. "*", "LUA" )
	MODE.FolderName = dir
	for k,v in pairs(files) do
		if v == "init.lua" then
			if SERVER then include( dir .. v ) end
		elseif v == "cl_init.lua" then
			if SERVER then AddCSLuaFile( dir .. v ) end
			if CLIENT then include( dir .. v ) end
		end
	end
	for z,x in pairs( MODE ) do
		if type(x) == "function" then
			print( "Loading " .. MODE.Name .. " gamemode hook: " .. z )
			hook.Add( z, abdulmode.GetCurrent()..".hook."..z, function(...)  x( MODE, unpack({...}) ) end )
		end
	end
	MsgC( Color( 0, 255, 0 ), MODE.Name .. " gamemode successful loaded.\n" )
end

function abdulmode.Include( path )
	include( MODE.FolderName .. path )
end

if SERVER then
	function abdulmode.AddCSLuaFile( path )
		AddCSLuaFile( MODE.FolderName .. path )
	end
end

function abdulmode.Load( id )
	print( "Trying to load " .. id .. " gamemode..." )
	local files, folders = file.Find(abdulmode.dir .. "*", "LUA")
	for k,v in pairs( folders ) do
		if v == id then
			loadGamemode( abdulmode.dir .. v .. "/" )
			return
		end
	end
	MsgC( Color( 255, 0, 0 ), "No gamemode such found.\n" )
	return
end

abdulmode.Load( abdulmode.GetCurrent() )