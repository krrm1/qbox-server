---@diagnostic disable: duplicate-set-field

if GetResourceState('qb-clothing') == 'missing' then return end
if GetResourceState('rcore_clothing') ~= 'missing' then return end

Clothing = Clothing or {}

Components = {}
Components.Map = {
    [1] = "mask",
    [2] = "hair",
    [3] = "arms",
    [4] = "pants",
    [5] = "bag",
    [6] = "shoes",
    [7] = "accessory",
    [8] = "t-shirt",
    [9] = "vest",
    [10] = "decals",
    [11] = "torso2"
}
Components.InverseMap = {
    mask = 1,
    hair = 2,
    arms = 3,
    pants = 4,
    bag = 5,
    shoes = 6,
    accessory = 7,
    ['t-shirt'] = 8, --<--I HATE THAT
    vest = 9,
    decals = 10,
    torso2 = 11
}

Props = {}
Props.Map = {
    [0] = "hat",
    [1] = "glass",
    [2] = "ear",
    [6] = "watch",
    [7] = "bracelet"
}
Props.InverseMap = {
    hat = 0,
    glass = 1,
    ear = 2,
    watch = 6,
    bracelet = 7
}

function Components.ConvertFromDefault(defaultComponents)
    local returnComponents = {}
    for index, componentData in pairs(defaultComponents or {}) do
        local componentId = Components.Map[componentData.component_id]
        if componentId then
            returnComponents[componentId] = {
                item = componentData.drawable,
                texture = componentData.texture
            }
        end
    end
    return returnComponents
end

function Components.ConvertToDefault(qbComponents)
    local returnComponents = {}
    for componentIndex, componentData in pairs(qbComponents or {}) do
        local componentId = Components.InverseMap[componentIndex]
        if componentId then
            returnComponents[componentId] = {
                component_id = componentId,
                drawable = componentData.item,
                texture = componentData.texture
            }
        end
    end
    return returnComponents
end

function Props.ConvertFromDefault(defaultProps)
    local returnProps = {}
    for index, propData in pairs(defaultProps or {}) do
        local propId = Props.Map[propData.prop_id]
        if propId then
            returnProps[propId] = {
                item = propData.drawable,
                texture = propData.texture
            }
        end
    end
    return returnProps
end

function Props.ConvertToDefault(qbProps)
    local returnProps = {}
    for propIndex, propData in pairs(qbProps or {}) do
        local propId = Props.InverseMap[propIndex]
        if propId then
            table.insert(returnProps, {
                prop_id = propId,
                drawable = propData.item,
                texture = propData.texture
            })
        end
    end
    table.sort(returnProps, function(a, b)
        return a.prop_id < b.prop_id
    end)
    return returnProps
end

function Clothing.ConvertFromDefault(defaultClothing)
    local components = Components.ConvertFromDefault(defaultClothing.components)
    local props = Props.ConvertFromDefault(defaultClothing.props)

    for propsIndex, propData in pairs(props) do
        components[propsIndex] = propData
    end

    return components --skin
end

function Clothing.ConvertToDefault(qbClothing)
    local components = Components.ConvertToDefault(qbClothing)
    local props = Props.ConvertToDefault(qbClothing)
    return { components = components, props = props }
end

-- Clothing = {}

-- StoredOldClothing = {}

-- Clothing.SetAppearance = function(clothingData)
--     if GetEntityModel(cache.ped) == `mp_m_freemode_01` then
--         clothingData = clothingData.male
--     else
--         clothingData = clothingData.female
--     end
--     local repackedTable = {}
--     local componentMap = {
--         [1] = "mask",
--         [3] = "arms",
--         [4] = "pants",
--         [5] = "bag",
--         [6] = "shoes",
--         [7] = "accessory",
--         [8] = "t-shirt",
--         [9] = "vest",
--         [10] = "decals",
--         [11] = "torso2"
--     }

--     local propMap = {
--         [0] = "hat",
--         [1] = "glass",
--         [2] = "ear",
--         [6] = "watch",
--         [7] = "bracelet"
--     }

--     local specialMap = {
--         eye_color_id = "eye_color",
--         moles_id = "moles",
--         ageing_id = "ageing",
--         hair_id = "hair",
--         face_id = "face"
--     }

--     for _, data in pairs(clothingData) do
--         if componentMap[data.component_id] then
--             repackedTable[componentMap[data.component_id]] = {drawable = data.drawable, texture = data.texture}
--         elseif propMap[data.prop_id] then
--             repackedTable[propMap[data.prop_id]] = {drawable = data.drawable, texture = data.texture}
--         elseif specialMap[data.eye_color_id] then
--             repackedTable[specialMap[data.eye_color_id]] = {drawable = data.drawable, texture = data.texture}
--         elseif specialMap[data.moles_id] then
--             repackedTable[specialMap[data.moles_id]] = {drawable = data.drawable, texture = data.texture}
--         elseif specialMap[data.ageing_id] then
--             repackedTable[specialMap[data.ageing_id]] = {drawable = data.drawable, texture = data.texture}
--         elseif specialMap[data.hair_id] then
--             repackedTable[specialMap[data.hair_id]] = {drawable = data.drawable, texture = data.texture}
--         elseif specialMap[data.face_id] then
--             repackedTable[specialMap[data.face_id]] = {drawable = data.drawable, texture = data.texture}
--         end
--     end
--     TriggerEvent('qb-clothing:client:loadOutfit', repackedTable)
-- end
