ItemsBuilder = ItemsBuilder or {}

ItemsBuilder = {}

---This will generate the items in the formats of qb_core, qb_core_old and ox_inventory. It will then build a lua file in the generateditems folder of the community_bridge.
---@param invoking string
---@param itemsTable table
ItemsBuilder.Generate = function(invoking, outputPrefix, itemsTable, useQB)
    if not itemsTable then return end
    invoking = invoking or GetInvokingResource() or GetCurrentResourceName() or "community_bridge"

    local resourcePath = string.format("%s/%s/", GetResourcePath(invoking), outputPrefix or "generated_items")

    -- remove any doubles slashes after initial double slash 
    -- resourcePath = resourcePath:gsub("//", "/")
    -- check if directory exists 
    local folder = io.open(resourcePath, "r")
    if not folder then
        local createDirectoryCMD = string.format("if not exist \"%s\" mkdir \"%s\"", resourcePath, resourcePath)
        local returned, err = io.popen(createDirectoryCMD)
        if not returned then
            print("🌮 Failed to create directory: ", err)
            return
        end
        returned:close()
        print("🌮 Created Directory: ", resourcePath)
    else
        folder:close()
    end

    local qbOld = {}
    local qbNew = {}
    local oxInventory = {}
    if useQB then 
        for key, item in pairs(itemsTable) do
            qbOld[key] = string.format(
                "['%s'] = {name = '%s', label = '%s', weight = %s, type = 'item', image = '%s', unique = %s, useable = %s, shouldClose = %s, description = '%s'},",
                key, key, item.label, item.weight, item.image or key .. 'png', item.unique, item.useable, item.shouldClose, item.description
            )
            qbNew[key] = string.format(
                "['%s'] = {['name'] = '%s', ['label'] = '%s', ['weight'] = %s, ['type'] = 'item',['image'] = '%s', ['unique'] = %s, ['useable'] = %s, ['shouldClose'] = %s, ['description'] = '%s'},",
                key, key, item.label, item.weight, item.image or key .. 'png', item.unique, item.useable, item.shouldClose, item.description
            )
            imagewithoutpng = item?.image and item.image:gsub(".png", "")
            shouldRenderImage = imagewithoutpng and imagewithoutpng ~= key
            oxInventory[key] = string.format(
                [[
                ["%s"] = {
                    label = "%s",
                    description = "%s",
                    weight = %s, 
                    stack = %s,
                    close = %s,
                    %s
                }, ]], 
                key, item.label, item.description, item.weight, not item.unique, item.shouldClose,
                shouldRenderImage and item.image and string.format([[client = {
                        image = '%s'
                    }]], item.image) or ""
            )
        end

    else             
        for key, item in pairs(itemsTable) do
            --  ['peanut_butter'] = {['name'] = 'peanut_butter',['label'] = 'Peanut Butter',['weight'] = 1000,['type'] = 'item',['image'] = 'peanut_butter.png',['unique'] = false,['useable'] = false,['shouldClose'] = true,['combinable'] = nil,['description'] = 'A cooking ingredient'},
            
            qbOld[key] = string.format(
                "['%s'] = {name = '%s', label = '%s', weight = %s, type = 'item', image = '%s', unique = %s, useable = %s, shouldClose = %s, description = '%s'},",
                key, key, item.label, item.weight, item?.client?.image or key .. 'png', not item.stack, true, item.close, item.description
            )
            qbNew[key] = string.format(
                "['%s'] = {['name'] = '%s', ['label'] = '%s', ['weight'] = %s, ['type'] = 'item', ['image'] = '%s', ['unique'] = %s, ['useable'] = %s, ['shouldClose'] = %s, ['description'] = '%s'},",
                key, key, item.label, item.weight, item?.client?.image or key .. 'png', not item.stack, true, item.close, item.description
            )
            imagewithoutpng = item?.client?.image and item.client.image:gsub(".png", "")
            shouldRenderImage = imagewithoutpng and imagewithoutpng ~= key
            oxInventory[key] = string.format(
                [[ 
                ["%s"] = {
                    label = "%s", 
                    description = "%s",
                    weight = %s, 
                    stack = %s, 
                    close = %s,
                    %s
                }, ]],
                key, item.label, item.description, item.weight, item.stack, item.close,
                shouldRenderImage and item?.client?.image and string.format( [[client = {
                        image = '%s'
                    }]], item.client.image) or ""
            )
        end
    end

    local function write(fileName, content)
        local filePath = resourcePath .. fileName
        local file = io.open(filePath, "w")
        if file then
            for key, value in pairs(content) do
                file:write(string.format("%s\n", value))
            end
            file:close()
            print("🌮 Items File Created: " .. filePath)
        else
            print("🌮 Something Broke for: " .. filePath)
        end
    end

   

    write(invoking.."(".."qb_core_old).lua", qbOld)
    write(invoking.."(".."qb_core_new).lua", qbNew)
    write(invoking.."(".."ox_inventory).lua", oxInventory)
end

exports('ItemsBuilder', ItemsBuilder)
return ItemsBuilder