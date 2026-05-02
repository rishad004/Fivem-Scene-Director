Actors = {}
SelectedActor = nil

-- =====================
-- SPAWN ACTOR FROM DB
-- =====================
function SpawnActor(id)
    TriggerServerEvent('scene:getChar', id)
end

RegisterNetEvent('scene:spawnChar', function(appearance)
    local coords = GetEntityCoords(PlayerPedId())
    local model = appearance.model or `mp_m_freemode_01`

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = CreatePed(0, model, coords.x + 1.5, coords.y, coords.z, 0.0, true, false)

    SetPedCanRagdoll(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskSetBlockingOfNonTemporaryEvents(ped, true)

    exports['illenium-appearance']:setPedAppearance(ped, appearance)

    table.insert(Actors, ped)
    SendNUIMessage({ action = "actorSpawned", count = #Actors })
end)

-- =====================
-- SELECT NEAREST ACTOR (UI-driven, no command)
-- =====================
function SelectNearestActor()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local closest, dist, closestIndex = nil, 5.0, nil

    for i, ped in ipairs(Actors) do
        if DoesEntityExist(ped) then
            local d = #(GetEntityCoords(ped) - playerCoords)
            if d < dist then
                closest = ped
                dist = d
                closestIndex = i
            end
        end
    end

    -- Clear outline on previous selection
    if SelectedActor and DoesEntityExist(SelectedActor) then
        SetEntityDrawOutline(SelectedActor, false)
    end

    SelectedActor = closest

    if SelectedActor then
        SetEntityDrawOutline(SelectedActor, true)
        -- Notify UI of selected actor index (0-based for JS)
        SendNUIMessage({ action = "actorSelected", index = closestIndex - 1 })
        Citizen.SetTimeout(3000, function()
            if DoesEntityExist(SelectedActor) then
                SetEntityDrawOutline(SelectedActor, false)
            end
        end)
    else
        SendNUIMessage({ action = "actorSelected", index = nil })
    end
end

-- =====================
-- ACTOR MANIPULATION THREAD
-- Guard: only active when freecam is OFF
-- =====================
CreateThread(function()
    while true do
        Wait(0)

        if SelectedActor and DoesEntityExist(SelectedActor) and not FreecamActive then
            local coords  = GetEntityCoords(SelectedActor)
            local heading = GetEntityHeading(SelectedActor)
            local rad     = math.rad(heading)
            local step    = 0.03

            -- W/S: move forward/backward along facing direction
            if IsControlPressed(0, 32) then
                coords = coords + vector3(-math.sin(rad) * step, math.cos(rad) * step, 0.0)
            end
            if IsControlPressed(0, 33) then
                coords = coords - vector3(-math.sin(rad) * step, math.cos(rad) * step, 0.0)
            end

            -- A/D: rotate heading
            if IsControlPressed(0, 34) then
                SetEntityHeading(SelectedActor, (heading + 2.0) % 360.0)
            end
            if IsControlPressed(0, 35) then
                SetEntityHeading(SelectedActor, (heading - 2.0) % 360.0)
            end

            -- Q/E: up/down (slopes, stairs)
            if IsControlPressed(0, 44) then
                coords = coords + vector3(0.0, 0.0, step)
            end
            if IsControlPressed(0, 38) then
                coords = coords + vector3(0.0, 0.0, -step)
            end

            SetEntityCoordsNoOffset(SelectedActor, coords.x, coords.y, coords.z, false, false, false)
        end
    end
end)
