---@diagnostic disable: duplicate-set-field
Clothing = Clothing or {}
Clothing.LastAppearance = Clothing.LastAppearance or {}
Callback = Callback or Require("lib/utility/shared/callbacks.lua")

function Clothing.IsMale(src)
    local ped = GetPlayerPed(src)
    if not ped or not DoesEntityExist(ped) then return end
    return GetEntityModel(ped) == `mp_m_freemode_01`
end

function Clothing.GetAppearance(src)
    return Callback.Trigger('community_bridge:cb:GetAppearance', src)
end

Clothing.SetAppearance = function(src, data)
    local strSrc = tostring(src)
    Clothing.LastAppearance[strSrc] = Clothing.GetAppearance(src)
    TriggerClientEvent('community_bridge:client:SetAppearance', src, data)
end

--- Sets a player's appearance based on gender-specific data
---@param src number The server ID of the player
---@param data table Table containing separate appearance data for male and female characters
---@return table|nil Appearance updated player appearance data or nil if failed
function Clothing.SetAppearanceExt(src, data)
    local tbl = Clothing.IsMale(src) and data.male or data.female
    Clothing.SetAppearance(src, tbl)
end

Clothing.RestoreAppearance = function(src)
    TriggerClientEvent('community_bridge:client:RestoreAppearance', src)
end


-- RegisterNetEvent('community_bridge:client:SetAppearance', function(data)
--     local src = source
--     Clothing.SetAppearance(src, data)
-- end)

-- RegisterNetEvent('community_bridge:client:GetAppearance', function()
--     local src = source
--     Clothing.GetAppearance(src)
-- end)

-- RegisterNetEvent('community_bridge:client:RestoreAppearance', function()
--     local src = source
--     Clothing.RestoreAppearance(src)
-- end)

-- RegisterNetEvent('community_bridge:client:ReloadSkin', function()
--     local src = source
--     Clothing.ReloadSkin(src)
-- end)

return Clothing
