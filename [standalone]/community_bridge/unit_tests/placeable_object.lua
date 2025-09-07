local  isPlacing = false
RegisterCommand('startplacer', function(source, args, rawCommand)
    if Bridge.PlaceableObject.IsPlacing() then
        print("Already placing an object.")
        return
    end

    local model = args[1] or 'prop_barrel_01a' -- Default model if none provided
    local position = GetEntityCoords(PlayerPedId())
    local result = Bridge.PlaceableObject.Create(model, {
        allowMovement = true,   -- Enable movement mode
        allowNormal = true,     -- Enable normal mode
        allowVertical = false,   -- Allow vertical movement in normal mode
        startMode = 'normal',   -- Start in normal mode
        depthMin = 2.0,
        depthMax = 15.0,
        heightStep = 0.2,       -- Height adjustment step
        boundary = {min = vector3(position.x - 5, position.y - 5, position.z - 1.5), max = vector3(position.x + 5, position.y + 5, position.z + 10)},
        showInstructionalButtons = true, -- Show instructional buttons
    })

    if result then
        print("Object placed!")
        print("Position:", result.position)
        print("Heading:", result.heading)
    else
        print("Placement cancelled")
    end
end)


RegisterCommand("startplacerold", function(source, args, rawCommand)
    local model = args[1] or 'prop_barrel_01a' -- Default model if none provided
    local distance = tonumber(args[2]) or 5.0 -- Default distance if not provided
    local snapToGround = true
    local offset = vector3(0.0, 0.0, 0.0) -- No offset
    local obj = Bridge.Placeable.PlaceObject(model, distance, snapToGround, {}, offset)
end)