-- Copyright 2017 viral32111. https://github.com/viral32111/car-keys/blob/master/LICENCE

local addonVersion = "1.0.2"
versionchecked = false

if ( SERVER ) then
	print("[Car Keys] Loading Car Keys...")
	print("[Car Keys] Author: viral32111")
	print("[Car Keys] Version: " .. addonVersion )

	util.AddNetworkString("sendTextToClient")

	print("[Car Keys] Finished loading Car Keys!")
end

if ( CLIENT ) then
	print("[Car Keys] Loading Car Keys...")
	print("[Car Keys] Author: viral32111")
	print("[Car Keys] Version: " .. addonVersion )

	print("[Car Keys] Finished loading Car Keys!")
end

hook.Add( "PlayerConnect", "CarKeysVersionChecker", function( name, ip )
	if not ( versionchecked ) then
		versionchecked = true
		http.Fetch( "https://raw.githubusercontent.com/viral32111/car-keys/master/VERSION.md",
		function( body, len, headers, code )
			local formattedBody = string.gsub( body, "\n", "")
			if ( formattedBody == addonVersion ) then
				print("[Car Keys] You are running the most recent version of Car Keys!")
			elseif ( formattedBody == "404: Not Found" ) then
				Error("[Car Keys] Version page does not exist\n")
			else
				print("[Car Keys] You are using outdated version of Car Keys! (Latest: " .. formattedBody .. ", Yours: " .. addonVersion .. ")" )
			end
		end,
		function( error )
			Error("[Car Keys] Failed to get addon version\n")
		end
		)
	end
end )

validVehicles = {
	"prop_vehicle_jeep",
	"prop_vehicle_airboat"
}

hook.Add( "PhysgunPickup", "CarKeysVehiclePickingUp", function( ply, ent )
	if ( table.HasValue( validVehicles, ent:GetClass() ) ) then
		if ( ent:GetNWString( "vehicleOwner", "nil" ) == "nil" ) then
			ply:ChatPrint( "You cannot pick up this carm, You must acquire it first." )
			return false
		else
			if ( ent:GetNWString( "vehicleOwner", "nil" ) == ply:Nick() ) then
				return true
			else
				ply:ChatPrint("You cannot pick up this car, It is owned by " .. ent:GetNWString( "vehicleOwner", "nil" ) )
			end
		end
	end
end )