---@diagnostic disable: duplicate-set-field
local resourceName = "Renewed-Vehiclekeys"
if GetResourceState(resourceName) == 'missing' then return end

VehicleKey = VehicleKey or {}

VehicleKey.GiveKeys = function(vehicle, plate)
    if not plate then return false end
    return exports['Renewed-Vehiclekeys']:addKey(plate)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    if not plate then return false end
    return exports['Renewed-Vehiclekeys']:removeKey(plate)
end

return VehicleKey