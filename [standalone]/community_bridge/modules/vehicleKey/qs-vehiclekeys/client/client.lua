---@diagnostic disable: duplicate-set-field
local resourceName = "qs-vehiclekeys"
if GetResourceState(resourceName) == 'missing' then return end

VehicleKey = VehicleKey or {}

VehicleKey.GiveKeys = function(vehicle, plate)
    if not vehicle then return false end
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    local verifiedPlate = GetVehicleNumberPlateText(vehicle)
    return exports['qs-vehiclekeys']:GiveKeys(verifiedPlate, model, true)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    if not vehicle then return false end
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    local verifiedPlate = GetVehicleNumberPlateText(vehicle)
    return exports['qs-vehiclekeys']:RemoveKeys(verifiedPlate, model)
end

return VehicleKey