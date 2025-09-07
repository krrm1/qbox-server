---@diagnostic disable: duplicate-set-field
local resourceName = "wasabi_carlock"
if GetResourceState(resourceName) == 'missing' then return end

VehicleKey = VehicleKey or {}

VehicleKey.GiveKeys = function(vehicle, plate)
    if not plate and vehicle then plate = GetVehicleNumberPlateText(vehicle) end
    exports.wasabi_carlock:GiveKey(plate)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    if not plate and vehicle then plate = GetVehicleNumberPlateText(vehicle) end
    exports.wasabi_carlock:RemoveKey(plate)
end

return VehicleKey