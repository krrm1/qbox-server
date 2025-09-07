Particles = {}
Particle = {}
---@diagnostic disable: duplicate-set-field
local Ids = Ids or Require("lib/utility/shared/ids.lua")
local point =  Require("lib/points/client/points.lua")

---Loads a ptfx asset into memory.
---@param dict string
---@return boolean
function LoadPtfxAsset(dict)
    local failed = 100
    while not HasNamedPtfxAssetLoaded(dict) and failed >= 0 do
        RequestNamedPtfxAsset(dict)
        failed = failed - 1
        Wait(100)
    end
    assert(failed > 0, "Failed to load dict asset: " .. dict)
    return HasNamedPtfxAssetLoaded(dict)
end

--- Create a particle effect at the specified position and rotation.
--- @param dict string
--- @param ptfx string
--- @param pos vector3
--- @param rot vector3
--- @param scale number
--- @param color vector3
--- @param looped boolean
--- @param loopLength number|nil
--- @return number|nil ptfxHandle -- The handle of the particle effect, or nil if it failed to create.
function Particle.Play(dict, ptfx, pos, rot, scale, color, looped, loopLength)
    LoadPtfxAsset(dict)
    UseParticleFxAssetNextCall(dict)
    SetParticleFxNonLoopedColour(color.x, color.y, color.z)
    local particle = nil
    if looped then
        particle = StartParticleFxLoopedAtCoord(ptfx, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, scale, false, false, false, false)
        CreateThread(function()
            if loopLength then 
                Wait(loopLength)
                Particle.Remove(particle)
            end
        end)
    else
        particle = StartParticleFxNonLoopedAtCoord(ptfx, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, scale, false, false, false, false)
    end

    return particle
end

function Particle.Stop(particle)
    if not particle then return end
    StopParticleFxLooped(particle, false)
    RemoveParticleFx(particle, false)
    RemoveNamedPtfxAsset(particle)
end

function Particle.Create(data)
    assert(data, "Particle data is nil")
    assert(data.dict, "Invalid particle data. Must contain string dict.")
    assert(data.ptfx, "Invalid particle data. Must contain string ptfx.")

    local _id = data.id or Ids.CreateUniqueId(Particles)
    data = {
        id = _id,
        dict = data.dict,
        ptfx = data.ptfx,
        position = data.position or vector3(0.0, 0.0, 0.0),
        rotation = data.rotation or vector3(0, 0, 0),
        size = data.size or 1.0,
        color = data.color or vector3(255, 255, 255),
        looped = data.looped or false,
        loopLength = data.loopLength or nil,
        spawned = false,
    }
    Particles[_id] = data

    point.Register( -- checking if players in range
        _id, 
        data.position, 
        data.drawDistance or 50.0, 
        data,
        function(_)     
            if not Particles[_id] then return point.Remove(_id) end
            local particleData = Particles[_id]
            if particleData.spawned then return end
            particleData.spawned = Particle.Play(
                particleData.dict, 
                particleData.ptfx, 
                particleData.position, 
                particleData.rotation, 
                particleData.size, 
                particleData.color, 
                particleData.looped, 
                particleData.loopLength
            )
        end,
        function(markerData)  
            if not Particles[_id] then return end
            local particleData = Particles[_id]
            if not particleData.spawned then return end
            Particle.Stop(particleData.spawned)
            particleData.spawned = nil
        end
    )
    return _id
end

function Particle.Remove(id)
    if not id then return end
    local particle = Particles[id]
    if not particle then return end
    Particle.Stop(particle.spawned)
    Particles[id] = nil
    point.Remove(id)
end



RegisterNetEvent("community_bridge:Client:Particle", function(data)
    if not data then return end
    Particle.Create(data)
end)

RegisterNetEvent("community_bridge:Client:ParticleBulk", function(datas)
    if not datas then return end
    for _, data in pairs(datas) do
        Particle.Create(data)
    end
end)

RegisterNetEvent("community_bridge:Client:ParticleRemove", function(id)
    local particle = Particles[id]
    if not particle then return end
    Particle.Remove(Drawing[id])
end)

RegisterNetEvent("community_bridge:Client:ParticleRemoveBulk", function(ids)
    for _, id in pairs(ids) do
        Particle.Remove(id)
    end
end)



function Particle.CreateOnEntity(dict, ptfx, entity, offset, rot, scale, color, looped, loopLength)
    LoadPtfxAsset(dict)
    UseParticleFxAssetNextCall(dict)
    SetParticleFxNonLoopedColour(color.x, color.y, color.z)
    local particle = nil
    if looped then
        particle = StartNetworkedParticleFxLoopedOnEntity(ptfx, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, scale, false, false, false)
        if loopLength then
            Wait(loopLength)
            RemoveParticleFxFromEntity(entity)
        end
    else
        particle = StartNetworkedParticleFxLoopedOnEntity(ptfx, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, scale, false, false, false)
    end
    RemoveNamedPtfxAsset(ptfx)
    return particle
end

function Particle.CreateOnEntityBone(dict, ptfx, entity, bone,  offset, rot, scale, color, looped, loopLength)
    LoadPtfxAsset(dict)
    UseParticleFxAssetNextCall(dict)
    SetParticleFxNonLoopedColour(color.x, color.y, color.z)
    local particle = nil
    if looped then
        particle = StartNetworkedParticleFxLoopedOnEntityBone(ptfx, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, bone, scale, false, false, false)
        if loopLength then
            Wait(loopLength)
            RemoveParticleFxFromEntity(entity)
        end
    else
        particle = StartNetworkedParticleFxNonLoopedOnEntityBone(ptfx, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, bone, scale, false, false, false)
    end
    RemoveNamedPtfxAsset(ptfx)
    return particle
end

return Particle