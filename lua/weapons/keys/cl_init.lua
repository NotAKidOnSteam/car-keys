include("shared.lua")

SWEP.PrintName = "Keys"			
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

hook.Add( "HUDPaint", "KeysHUD", function()
	local ply = LocalPlayer()

	if not ( ply:InVehicle() ) then
		if ( ply:GetActiveWeapon():GetClass() == "keys" ) then
			if ( table.HasValue( validVehicles, ply:GetEyeTrace().Entity:GetClass() ) ) then
				if ( ply:GetEyeTrace().Entity:GetNWBool( "vehicleLocked", false ) ) then
					draw.DrawText( "Vehicle is locked", "TargetID", ScrW()/2, ScrH()/2, Color(255, 255, 255), TEXT_ALIGN_CENTER)
				else
					draw.DrawText( "Vehicle is unlocked", "TargetID", ScrW()/2, ScrH()/2, Color(255, 255, 255), TEXT_ALIGN_CENTER)
				end
				
			end
		end
	end
end )