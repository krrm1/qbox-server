---@diagnostic disable: duplicate-set-field
Clothing = Clothing or {}

ClothingBackup = {}
Callback = Callback or Require("lib/utility/shared/callbacks.lua")
Ultility = Utility or Require('lib/utility/client/utility.lua')
Cache = Cache or Require('lib/cache/shared/cache.lua')


function Clothing.IsMale()
    local ped = PlayerPedId()
    if not ped then return end
    if GetEntityModel(ped) == `mp_m_freemode_01` then
        return true
    end
    return false
end

---Get the skin data of a ped
---@param entity number
---@return table
function Clothing.GetAppearance(entity)
    if not entity and not DoesEntityExist(entity) then return end
    local model = GetEntityModel(entity)
    local skinData = { model = model, components = {}, props = {} }
    for i = 0, 11 do
        table.insert(skinData.components,
            { component_id = i, drawable = GetPedDrawableVariation(entity, i), texture = GetPedTextureVariation(entity, i) })
    end
    for i = 0, 13 do
        table.insert(skinData.props,
            { prop_id = i, drawable = GetPedPropIndex(entity, i), texture = GetPedPropTextureIndex(entity, i) })
    end
    return skinData
end

function Clothing.CopyAppearanceToClipboard()
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then return end
    local skinData = Clothing.GetAppearance(ped)
    if not skinData then return end
    Ultility.CopyToClipboard(skinData)
end

Callback.Register('community_bridge:cb:GetAppearance', function()
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then return end
    local skinData = Clothing.GetAppearance(ped)
    return skinData
end)

---Apply skin data to a ped
---@param entity number
---@param skinData table
---@return boolean
function Clothing.SetAppearance(entity, skinData)
    for k, v in pairs(skinData.components or {}) do
        if v.component_id then
            SetPedComponentVariation(entity, v.component_id, v.drawable, v.texture, 0)
        end
    end
    for k, v in pairs(skinData.props or {}) do
        if v.prop_id then
            SetPedPropIndex(entity, v.prop_id, v.drawable, v.texture, 0)
        end
    end
    return true
end

---This will return the peds components to the previously stored components
---@return boolean
Clothing.RestoreAppearance = function(entity)
    Clothing.SetAppearance(entity, ClothingBackup)
    return true
end

Clothing.UpdateAppearanceBackup = function(data)
    ClothingBackup = data
end

Clothing.RunningDebug = false
Clothing.Cache = nil -- maybe change this to the actual cache system???!? For future not lazy me

Cache.Create('Clothing', function()
    local ped = Cache.Get('Ped')
    local appearance = Clothing.GetAppearance(ped)
    if Table.Compare(Clothing.Cache, appearance) then
        return false
    end
    return appearance
end, 1000)

local onChange = nil
Clothing.ToggleDebugging = function()
    if Clothing.RunningDebug then
        Clothing.RunningDebug = false
        print("Clothing Debugging Disabled")
        return Cache.RemoveOnChange('Clothing', onChange)
    end
    Clothing.RunningDebug = true
    print("Clothing Debugging Enabled")

    if Clothing.OpenMenu then
        Clothing.OpenMenu()
    end

    onChange = Cache.OnChange('Clothing', function(new, old)
        print("Clothing Debugging", new)
        for k, v in pairs(old.components) do
            if v.component_id then
                if new.components[k].drawable ~= v.drawable or new.components[k].texture ~= v.texture then
                    print("Component ID: " ..
                    v.component_id ..
                    " Drawable: " .. new.components[k].drawable .. " Texture: " .. new.components[k].texture)
                end
            end
        end
        for k, v in pairs(old.props) do
            if v.prop_id then
                if new.props[k].drawable ~= v.drawable or new.props[k].texture ~= v.texture then
                    print("Prop ID: " ..
                    v.prop_id .. " Drawable: " .. new.props[k].drawable .. " Texture: " .. new.props[k].texture)
                end
            end
        end
    end)
end

RegisterNetEvent('community_bridge:client:SetAppearance', function(data)
    Clothing.SetAppearance(PlayerPedId(), data)
end)

RegisterNetEvent('community_bridge:client:GetAppearance', function()
    Clothing.GetAppearance(PlayerPedId())
end)

RegisterNetEvent('community_bridge:client:RestoreAppearance', function()
    Clothing.RestoreAppearance(PlayerPedId())
end)

-- RegisterCommand("clothing:enabledebug", function(source, args, rawCommand)
--     Clothing.ToggleDebugging()
-- end)

-- RegisterCommand("clothing:copy", function(source, args, rawCommand)
--     Clothing.CopyAppearanceToClipboard()
-- end)


return Clothing
