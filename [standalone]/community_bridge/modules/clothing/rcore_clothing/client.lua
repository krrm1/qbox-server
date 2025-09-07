---@diagnostic disable: duplicate-set-field
if GetResourceState('rcore_clothing') == 'missing' then return end
Clothing = Clothing or {}

function Clothing.OpenMenu()
    TriggerEvent('qb-clothing:client:openMenu')
end