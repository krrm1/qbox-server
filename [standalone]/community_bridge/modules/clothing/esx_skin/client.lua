---@diagnostic disable: duplicate-set-field
if GetResourceState('esx_skin') == 'missing' then return end
if GetResourceState('rcore_clothing') ~= 'missing' then return end
Clothing = Clothing or {}

function Clothing.OpenMenu()
    TriggerEvent('esx_skin:openMenu', function() end, function() end, true)
end
