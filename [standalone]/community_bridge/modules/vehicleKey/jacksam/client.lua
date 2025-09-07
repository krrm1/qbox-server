---@diagnostic disable: duplicate-set-field
local resourceName = "jaksams_VehiclesKeys"
if GetResourceState(resourceName) == 'missing' then return end

VehicleKey = VehicleKey or {}

VehicleKey.GiveKeys = function(vehicle, plate)
    if not plate then return false end
    return TriggerServerEvent("vehicles_keys:selfGiveVehicleKeys", plate)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    if not plate then return false end
    return TriggerServerEvent("vehicles_keys:selfRemoveKeys", plate)
end

return VehicleKey