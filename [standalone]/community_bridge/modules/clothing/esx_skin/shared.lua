---@diagnostic disable: duplicate-set-field
if GetResourceState('esx_skin') == 'missing' then return end
if GetResourceState('rcore_clothing') ~= 'missing' then return end

Clothing = Clothing or {}

-- {"glasses_2":0,"shoes_1":70,"dad":0,"shoes_2":2,"pants_1":28,"eye_squint":0,"ears_1":-1,"hair_color_1":61,"eyebrows_6":0,"bodyb_3":-1,"beard_1":11,"complexion_2":0,"arms_2":0,"hair_1":76,"nose_1":0,"blush_2":0,"bracelets_2":0,"blush_1":0,"jaw_2":0,"helmet_1":-1,"eyebrows_3":0,"watches_1":-1,"eyebrows_4":0,"jaw_1":0,"lipstick_1":0,"eyebrows_1":0,"nose_4":0,"age_2":0,"torso_1":23,"hair_2":0,"chin_2":0,"arms":1,"chain_1":22,"nose_2":0,"cheeks_1":2,"tshirt_1":4,"glasses_1":0,"pants_2":3,"lipstick_4":0,"chin_13":0,"beard_4":0,"beard_3":0,"chain_2":2,"cheeks_3":6,"sex":0,"lipstick_3":0,"makeup_1":0,"hair_color_2":29,"mask_2":0,"chin_1":0,"eyebrows_5":0,"bodyb_2":0,"sun_2":0,"watches_2":0,"sun_1":0,"chin_4":0,"nose_3":0,"helmet_2":0,"bags_2":0,"moles_2":0,"mask_1":0,"blemishes_2":0,"chest_1":0,"cheeks_2":-10,"age_1":0,"chest_2":0,"beard_2":10,"torso_2":2,"blush_3":0,"bproof_1":0,"moles_1":0,"chin_3":0,"lip_thickness":-2,"lipstick_2":0,"chest_3":0,"complexion_1":0,"bodyb_4":0,"neck_thickness":0,"bproof_2":0,"makeup_3":0,"tshirt_2":2,"makeup_2":0,"makeup_4":0,"bracelets_1":-1,"decals_2":0,"nose_6":0,"bodyb_1":-1,"bags_1":0,"blemishes_1":0,"decals_1":0,"mom":21,"eyebrows_2":0,"eye_color":0,"skin_md_weight":50,"face_md_weight":50,"nose_5":10,"ears_2":0}

Components = {}
Components.Map = {
    [1] = 'mask', -- componentId
    [2] = 'ears',
    [3] = 'arms',
    [4] = 'pants',
    [5] = 'bags',
    [6] = 'shoes',
    [7] = 'chain',
    [8] = 'tshirt',
    [9] = 'bproof',
    [10] = 'decals',
    [11] = 'torso'
}

Components.InverseMap = {
    mask = 1, -- componentId
    arms = 3,
    pants = 4,
    bags = 5,
    shoes = 6,
    chain = 7,
    tshirt = 8,
    bproof = 9,
    decals = 10,
    torso = 11,
}

Props = {}
Props.Map = {
    [0] = 'helmet', -- propId
    [1] = 'glasses',
    [2] = 'ears',
    [6] = 'watches',
    [7] = 'bracelets'
}

Props.InverseMap = {
    helmet_1 = 0,
    helmet_2 = 0,
    glasses_1 = 1,
    glasses_2 = 1,
    ears_1 = 2,
    ears_2 = 2,
    watches_1 = 6,
    watches_2 = 6,
    bracelets_1 = 7,
    bracelets_2 = 7,
}

-- Converts from illinium format to esx format
function Components.ConvertFromDefault(defaultComponents)
    local returnComponents = {}
    for index, componentData in pairs(defaultComponents or {}) do
        local componentId = Components.Map[componentData.component_id]
        if componentId then
            returnComponents[componentId .. '_1'] = componentData.drawable
            returnComponents[componentId .. '_2'] = componentData.texture
        end
    end
    return returnComponents
end

function Components.ConvertToDefault(esxComponents)
    local returnComponents = {}
    for componentIndex, componentData in pairs(esxComponents or {}) do
        local isTexture = componentIndex:find('_2')
        componentIndex = componentIndex:gsub('_1', ''):gsub('_2', '')
        local componentId = Components.InverseMap[componentIndex]
        if componentId then
            if isTexture then
                returnComponents[componentId] = returnComponents[componentId] or {}
                returnComponents[componentId].texture = componentData
            else
                returnComponents[componentId] = returnComponents[componentId] or {}
                returnComponents[componentId].component_id = componentId
                returnComponents[componentId].drawable = componentData
                returnComponents[componentId].texture = returnComponents[componentId].texture or 0
            end
        end
    end
    return returnComponents
end

function Props.ConvertFromDefault(defaultProps)
    local returnProps = {}
    for index, propData in pairs(defaultProps or {}) do
        local propId = Props.Map[propData.prop_id]
        if propId then
            returnProps[propId .. '_1'] = propData.drawable
            returnProps[propId .. '_2'] = propData.texture
        end
    end
    return returnProps
end

function Props.ConvertToDefault(esxProps)
    local returnProps = {}
    for propIndex, propData in pairs(esxProps or {}) do
        local isTexture = propIndex:find('_2')
        propIndex = propIndex:gsub('_1', ''):gsub('_2', '')
        local propId = Props.InverseMap[propIndex]
        if propId then
            if isTexture then
                returnProps[propId] = returnProps[propId] or {}
                returnProps[propId].texture = propData
            else
                returnProps[propId] = returnProps[propId] or {}
                returnProps[propId].prop_id = propId
                returnProps[propId].drawable = propData
                returnProps[propId].texture = returnProps[propId].texture or 0
            end
        end
        table.sort(returnProps, function(a, b)
            return a.prop_id < b.prop_id
        end)
    end
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

function Clothing.ConvertToDefault(esxClothing)
    local components = Components.ConvertToDefault(esxClothing)
    local props = Props.ConvertToDefault(esxClothing)
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
--     TriggerEvent('esx-clothing:client:loadOutfit', repackedTable)
-- end
