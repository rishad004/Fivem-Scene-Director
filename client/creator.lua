local creating = false

function OpenCharacterCreator()
    if creating then
        print('[Scene Director] Character creator already open.')
        return
    end
    creating = true

    local player = PlayerPedId()
    local coords = GetEntityCoords(player)

    local model = `mp_m_freemode_01`
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    -- Spawn a preview ped slightly offset from the player
    local previewPed = CreatePed(0, model, coords.x + 2.0, coords.y, coords.z, 0.0, false, false)
    SetEntityInvincible(previewPed, true)
    SetPedCanRagdoll(previewPed, false)
    FreezeEntityPosition(previewPed, true)

    -- Freeze player and hide them during customization
    FreezeEntityPosition(player, true)
    SetEntityVisible(player, false, false)

    exports['illenium-appearance']:startPlayerCustomization(function(appearance)
        if appearance then
            -- Save to server DB — event name matches server/main.lua handler
            TriggerServerEvent('scene:saveCharacter', appearance)
        end

        -- Cleanup
        if DoesEntityExist(previewPed) then DeleteEntity(previewPed) end
        SetEntityVisible(player, true, false)
        FreezeEntityPosition(player, false)
        creating = false
    end, {
        ped = previewPed
    })
end
