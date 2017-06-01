-- Copyright 2017 viral32111. https://github.com/viral32111/car-keys/blob/master/LICENCE

local CarKeysVersion = "1.1.4"
local CarKeysVersionChecked = false

if ( SERVER ) then
	print("[Car Keys] Loaded! (Author: viral32111) (Version: " .. CarKeysVersion .. ")")

	include("autorun/server/sv_carkeys.lua")

	AddCSLuaFile("sh_carkeys_config.lua")
	include("sh_carkeys_config.lua")

	resource.AddSingleFile("materials/sentry/key/key.vmt")
	resource.AddSingleFile("materials/sentry/key/key.vtf")
	resource.AddSingleFile("models/sentry/pgkey.dx80.vtx")
	resource.AddSingleFile("models/sentry/pgkey.dx90.vtx")
	resource.AddSingleFile("models/sentry/pgkey.mdl")
	resource.AddSingleFile("models/sentry/pgkey.phy")
	resource.AddSingleFile("models/sentry/pgkey.sw.vtx")
	resource.AddSingleFile("models/sentry/pgkey.vvd")
end

if ( CLIENT ) then
	print("This server is running Car Keys, Created by viral32111! (www.github.com/viral32111)")
end

hook.Add( "PlayerConnect", "CarKeysVersionCheck", function( name, ip )
	if not ( CarKeysVersionChecked ) then
		CarKeysVersionChecked = true
		http.Fetch( "https://raw.githubusercontent.com/viral32111/car-keys/master/VERSION.md",
		function( body, len, headers, code )
			local formattedBody = string.gsub( body, "\n", "")
			if ( formattedBody == CarKeysVersion ) then
				MsgC( Color( 0, 255, 0 ), "[Car Keys] You are running the most recent version of Car Keys!\n")
			elseif ( formattedBody == "404: Not Found" ) then
				MsgC( Color( 255, 0, 0 ), "[Car Keys] Version page does not exist\n")
			else
				MsgC( Color( 255, 255, 0 ), "[Car Keys] You are using outdated version of Car Keys! (Latest: " .. formattedBody .. ", Yours: " .. CarKeysVersion .. ")\n" )
			end
		end,
		function( error )
			MsgC( Color( 255, 0, 0 ), "[Car Keys] Failed to get addon version\n")
		end
		)
	end
end )