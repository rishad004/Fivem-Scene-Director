Actors = {}
SelectedActor = nil

function SpawnActor(id)
    TriggerServerEvent('scene:getChar', id)
end

RegisterNetEvent('scene:spawnChar', function(appearance)
    local coords = GetEntityCoords(PlayerPedId())
    local model = appearance.model or `mp_m_freemode_01`

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = CreatePed(0, model, coords.x + 1, coords.y, coords.z, 0.0, true, false)
    exports['illenium-appearance']:setPedAppearance(ped, appearance)

    table.insert(Actors, ped)
end)

RegisterCommand('select', function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local closest, dist = nil, 2.0

    for _, ped in ipairs(Actors) do
        local d = #(GetEntityCoords(ped) - playerCoords)
        if d < dist then
            closest = ped
            dist = d
        end
    end

    SelectedActor = closest
end)

CreateThread(function()
    while true do
        if SelectedActor then
            local coords = GetEntityCoords(SelectedActor)

            if IsControlPressed(0, 32) then coords = coords + vector3(0,0.02,0) end
            if IsControlPressed(0, 33) then coords = coords - vector3(0,0.02,0) end

            SetEntityCoordsNoOffset(SelectedActor, coords)
        end
        Wait(0)
    end
end)