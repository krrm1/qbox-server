---@diagnostic disable: duplicate-set-field
local resourceName = "qb-vehiclekeys"
if GetResourceState(resourceName) == 'missing' then return end

VehicleKey = VehicleKey or {}

VehicleKey.GiveKeys = function(vehicle, plate)
    if not plate then return false end
    TriggerServerEvent("qb-vehiclekeys:server:AcquireVehicleKeys", plate)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    if not plate then return false end
    TriggerEvent("qb-vehiclekeys:client:RemoveKeys", plate)
end

return VehicleKey