---@diagnostic disable: duplicate-set-field
local resourceName = "MrNewbVehicleKeys"
if GetResourceState(resourceName) == 'missing' then return end

VehicleKey = VehicleKey or {}

VehicleKey.GiveKeys = function(vehicle, plate)
    if not plate then return false end
    return exports.MrNewbVehicleKeys:GiveKeysByPlate(plate)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    if not plate then return false end
    return exports.MrNewbVehicleKeys:RemoveKeysByPlate(plate)
end

return VehicleKey