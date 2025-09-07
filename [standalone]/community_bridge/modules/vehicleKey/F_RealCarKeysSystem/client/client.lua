---@diagnostic disable: duplicate-set-field
local resourceName = "F_RealCarKeysSystem"
if GetResourceState(resourceName) == 'missing' then return end
VehicleKey = VehicleKey or {}

VehicleKey.GiveKeys = function(vehicle, plate)
    if not plate then return false end
    TriggerServerEvent('F_RealCarKeysSystem:generateVehicleKeys', plate)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    return true
end

return VehicleKey