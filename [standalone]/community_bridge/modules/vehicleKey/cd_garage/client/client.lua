---@diagnostic disable: duplicate-set-field
local resourceName = "cd_garage"
if GetResourceState(resourceName) == 'missing' then return end

VehicleKey = VehicleKey or {}

VehicleKey.GiveKeys = function(vehicle, plate)
    if not plate then return false end
    TriggerEvent('cd_garage:AddKeys', plate)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    return true
end

return VehicleKey