
RegisterCommand("test_particle", function(source, args, rawCommand)
    local playerPed = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.0, 0.0)
    local heading = GetEntityHeading(playerPed)
    Particle.Create("core", "ent_dst_concrete_large", coords, vector3(0.0, 0.0, heading), 1.0, vector3(1.0, 1.0, 1.0), false)
end)