---@diagnostic disable: duplicate-set-field
local resourceName = "mono_carkeys"
if GetResourceState(resourceName) == 'missing' then return end

VehicleKey = VehicleKey or {}
VehicleKey.GiveKeys = function(vehicle, plate)
    if not plate then return false end
    TriggerServerEvent('mono_carkeys:CreateKey', plate)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    if not plate then return false end
    TriggerServerEvent('mono_carkeys:DeleteKey', 1, plate)
end

return VehicleKey