if GetResourceState('qb-houses') == 'missing' then return end

Housing = Housing or {}

RegisterNetEvent('qb-houses:server:SetInsideMeta', function(insideId, bool)
    local src = source
    insideId = bool and insideId or nil
    TriggerEvent('community_bridge:Server:_OnPlayerInside', src, insideId)
end)

return Housing