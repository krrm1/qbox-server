---@diagnostic disable: duplicate-set-field
if GetResourceState('qbx_management') ~= 'started' then return end

BossMenu = BossMenu or {}

---This will get the name of the module being used.
---@return string
BossMenu.GetResourceName = function()
    return "qbx_management"
end

BossMenu.OpenBossMenu = function(src, jobName, jobType)
    TriggerClientEvent("community_bridge:client:OpenBossMenu", src, jobName, jobType)
end

return BossMenu