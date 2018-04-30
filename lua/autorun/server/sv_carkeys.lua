--[[-------------------------------------------------------------------------
Copyright 2017-2018 viral32111

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
---------------------------------------------------------------------------]]

if ( CLIENT ) then return end
include("carkeys_config.lua")

--[[-------------------------------------------------------------------------
Vehicle Locking
---------------------------------------------------------------------------]]
hook.Add( "PlayerUse", "CarKeysUseVehicle", function( ply, ent )
	if ( ent:GetClass() == "gmod_sent_vehicle_fphysics_wheel" ) then return false end
	
	if ( table.HasValue( CarKeysVehicles, ent:GetClass() ) ) then
		if ( ply:GetPos():Distance( ply:GetEyeTrace().Entity:GetPos() ) >= 150 ) then return false end

		if ( ent:GetNWBool("CarKeysVehicleLocked") ) then
			return false
		else
			return true
		end
	end
end )

hook.Add( "KeyPress", "CarKeysVehicleMessage", function( ply, key )
	if ( key == IN_USE ) then	
		if ( ply:GetEyeTrace().Entity:GetClass() == "gmod_sent_vehicle_fphysics_wheel" ) then return false end
		if ( ply:GetPos():Distance( ply:GetEyeTrace().Entity:GetPos() ) >= 150 ) then return false end
		
		if ( table.HasValue( CarKeysVehicles, ply:GetEyeTrace().Entity:GetClass() ) ) and ( ply:GetEyeTrace().Entity:GetNWBool("CarKeysVehicleLocked") ) then
			ply:SendLua([[ chat.AddText( Color( 26, 198, 255 ), "(Car Keys) ", Color( 255, 255, 255 ), "This vehicle is locked, You cannot enter it." ) ]])
			ply:EmitSound("doors/handle_pushbar_locked1.wav")
		end
	end
end )

--[[-------------------------------------------------------------------------
Set Vehicle Price on Spawn
---------------------------------------------------------------------------]]
hook.Add( "PlayerSpawnedVehicle", "CarKeysSetVehiclePrice", function( ply, vehicle )
	if ( vehicle:GetClass() == "gmod_sent_vehicle_fphysics_wheel" ) then return end

	if ( table.HasValue( CarKeysVehicles, vehicle:GetClass() ) ) then
		vehicle:SetNWEntity("CarKeysVehicleOwner", ply)
		if ( engine.ActiveGamemode() == "darkrp" ) then
			if ( file.Exists( "carkeys/" .. vehicle:GetClass() .. ".txt", "DATA" ) ) then
				local price = tonumber( file.Read("carkeys/" .. vehicle:GetClass() .. ".txt", "DATA") )
				vehicle:SetNWInt("CarKeysVehiclePrice", price)
			else
				vehicle:SetNWInt("CarKeysVehiclePrice", 0)
			end
		end
	end
end )

--[[-------------------------------------------------------------------------
Vehicle Pickup
---------------------------------------------------------------------------]]
hook.Add("PhysgunPickup", "CarKeysVehiclePickingUp", function( ply, ent )
	if ( table.HasValue( CarKeysVehicles, ent:GetClass() ) ) then
		if ( ply:IsAdmin() or ply:IsSuperAdmin() ) then
			return true
		else
			if ( ent:GetNWEntity("CarKeysVehicleOwner") == NULL ) then
				return false
			else
				if ( ent:GetNWEntity("CarKeysVehicleOwner"):Nick() == ply:Nick() ) then
					return true
				end
			end
		end
	end
end )

--[[-------------------------------------------------------------------------
Set Vehicle Price
---------------------------------------------------------------------------]]
if ( engine.ActiveGamemode() == "darkrp" ) then
	hook.Add("PlayerSay", "CarKeysSetVehiclePrice", function( ply, text, public )
		local text = string.lower( text )

		if ( string.sub( text, 1, 9 ) == "!setprice" ) then
			if ( ply:GetEyeTrace().Entity:GetClass() == "gmod_sent_vehicle_fphysics_wheel" ) then return end

			if ( ply:GetEyeTrace().Entity:IsVehicle() ) then
				if ( string.sub( text, 11 ) != "" ) then
					if ( table.HasValue( CarKeysVehicles, ply:GetEyeTrace().Entity:GetClass() ) ) then
						vehicle = ply:GetEyeTrace().Entity
						price = string.sub( text, 11 )
						vehicle:SetNWInt("CarKeysVehiclePrice", tonumber( price ) )
						file.Write("carkeys/" .. vehicle:GetClass() .. ".txt", price )
						ply:SendLua([[ chat.AddText( Color( 26, 198, 255 ), "(Car Keys) ", Color( 255, 255, 255 ), "You have successfully set the price of this vehicle!" ) ]])
					else
						ply:SendLua([[ chat.AddText( Color( 26, 198, 255 ), "(Car Keys) ", Color( 255, 255, 255 ), "This vehicle is not compatible with Car Keys, Please contact the creator to fix this issue." ) ]])
					end
				else
					ply:SendLua([[ chat.AddText( Color( 26, 198, 255 ), "(Car Keys) ", Color( 255, 255, 255 ), "Please supply a price argument, e.g. !setprice 1000" ) ]])
				end
			else
				ply:SendLua([[ chat.AddText( Color( 26, 198, 255 ), "(Car Keys) ", Color( 255, 255, 255 ), "You must be looking at a vehicle to set it's price." ) ]])
			end
			return ""
		end
	end )
else
	print("[Car Keys] Set vehicle price chat command has been disabled.")
end

--[[-------------------------------------------------------------------------
When damage is taken
---------------------------------------------------------------------------]]
hook.Add("EntityTakeDamage", "CarKeysOnVehicleDamaged", function( target, dmg )
	if ( target:GetClass() == "gmod_sent_vehicle_fphysics_wheel" ) then return false end

	if ( table.HasValue( CarKeysVehicles, target:GetClass() ) and target:GetNWBool("CarKeysVehicleLocked") and target:GetNWEntity("CarKeysVehicleOwner") != NULL ) then
		if ( timer.Exists(target:EntIndex() .. "CarKeysDamageTimer") ) then
			return
		else
			timer.Create(target:EntIndex() .. "CarKeysDamageTimer", 8*12, 1, function() end)
		end

		target:SetNWBool("CarKeysVehicleAlarm", true)
		target:EmitSound("carkeys_alarm")

		target:GetNWEntity("CarKeysVehicleOwner"):SendLua([[ chat.AddText( Color( 0, 180, 255 ), "(Car Keys) ", Color( 255, 255, 255 ), "Your car has been damaged!" ) ]])

		if ( target:GetClass() == "gmod_sent_vehicle_fphysics_base" ) then
			timer.Create( target:EntIndex() .. "CarKeysAlarmLights", 2, 4, function()
				if ( target:IsValid() ) then
					target:SetLightsEnabled(true)
				end
				timer.Simple( 1, function()
					if ( target:IsValid() ) then
						target:SetLightsEnabled(false)
					end
				end )
			end )
		end

		timer.Create( target:EntIndex() .. "CarKeysLoopAlarm", 8, 12, function()
			if ( target:IsValid() ) then
				if ( target:GetClass() == "gmod_sent_vehicle_fphysics_base" ) then
					timer.Create( target:EntIndex() .. "CarKeysAlarmLights", 2, (8*12)/2, function()
						if ( target:IsValid() ) then
							target:SetLightsEnabled(true)
						end
						timer.Simple( 1, function()
							if ( target:IsValid() ) then
								target:SetLightsEnabled(false)
							end
						end )
					end )
				end
				target:EmitSound("carkeys_alarm")
			else
				target:SetNWBool("CarKeysVehicleAlarm", false)
				timer.Remove(target:EntIndex() .. "CarKeysLoopAlarm")
				timer.Remove(target:EntIndex() .. "CarKeysAlarmLights")
			end
		end )
	end
end )

--[[-------------------------------------------------------------------------
Stop alarm when removed
---------------------------------------------------------------------------]]
hook.Add("EntityRemoved", "CarKeysVehicleRemoved", function( ent )
	if ( table.HasValue( CarKeysVehicles, ent:GetClass() ) and ent:GetNWBool("CarKeysVehicleAlarm") ) then
		timer.Remove("CarKeysLoopAlarm")
		timer.Remove("CarKeysAlarmLights")
		ent:SetNWBool("CarKeysVehicleAlarm", false)
		ent:StopSound("carkeys_alarm")
	end
end )

--[[-------------------------------------------------------------------------
Alarm when moved
---------------------------------------------------------------------------]]
-- Fix for the next update, don't work atm :/ (Probs sometime this week)
--[[hook.Add("Think", "CarKeysVehicleMoved", function()
	for _, ent in pairs( ents.GetAll() ) do
		if not ( ent:IsValid() ) then return end

		if ( ent:IsVehicle() and table.HasValue( CarKeysVehicles, ent:GetClass() ) and ent:GetNWBool("CarKeysVehicleLocked") and ent:GetVelocity():Length() > 0 ) then
			print(tostring(ent) .. " moved!")
		end
	end
end )]]