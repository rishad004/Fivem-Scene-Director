local uiOpen = false

-- =====================
-- OPEN / CLOSE UI
-- =====================
RegisterCommand('director', function()
    uiOpen = not uiOpen
    SetNuiFocus(uiOpen, uiOpen)   -- capture keyboard AND mouse when open
    SendNUIMessage({ action = "toggle", state = uiOpen })
end, false)

RegisterKeyMapping('director', 'Open Scene Director', 'keyboard', 'F9')

-- Close UI with Escape
RegisterNUICallback('closeUI', function(_, cb)
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "toggle", state = false })
    cb('ok')
end)

-- =====================
-- GENERAL ACTIONS
-- =====================
RegisterNUICallback('action', function(data, cb)
    if data.type == "spawnActor" then
        SpawnActor(data.id)

    elseif data.type == "playTimeline" then
        Citizen.CreateThread(function() PlayTimeline() end)

    elseif data.type == "addCamKey" then
        AddCameraKey(data.duration)

    elseif data.type == "createCharacter" then
        OpenCharacterCreator()

    elseif data.type == "selectNearest" then
        -- Select nearest actor and notify the UI
        SelectNearestActor()

    elseif data.type == "toggleFreecam" then
        ToggleFreecam()
        -- Notify UI of new freecam state
        SendNUIMessage({ action = "freecamToggled", active = FreecamActive })
    end
    cb('ok')
end)

-- =====================
-- ANIMATIONS
-- =====================
RegisterNUICallback('getAnimations', function(_, cb)
    cb(Animations)
end)

RegisterNUICallback('playAnim', function(data, cb)
    PlayAnim(data.dict, data.anim)
    cb('ok')
end)

-- =====================
-- TIMELINE
-- =====================
RegisterNUICallback('addStep', function(data, cb)
    cb(AddTimelineStep(data.duration))
end)

RegisterNUICallback('getTimeline', function(_, cb)
    cb(GetTimeline())
end)

RegisterNUICallback('removeStep', function(data, cb)
    RemoveTimelineStep(data.index)
    cb(GetTimeline())
end)

RegisterNUICallback('updateStep', function(data, cb)
    UpdateStepDuration(data.index, data.duration)
    cb(GetTimeline())
end)

-- =====================
-- SCENE SAVE / LOAD
-- =====================

-- Save scene locally (JSON export) AND persist to server DB
RegisterNUICallback('saveScene', function(data, cb)
    local json = SceneStorage.ExportScene()

    -- Persist to server DB with given name
    if data.name and data.name ~= "" then
        TriggerServerEvent('scene:saveScene', data.name, json)
    end

    cb(json)
end)

-- Load scene from raw JSON (clipboard / file import)
RegisterNUICallback('loadSceneLocal', function(data, cb)
    SceneStorage.ImportScene(data.scene)
    cb("ok")
end)

-- Load scene by database ID
RegisterNUICallback('loadSceneFromDB', function(data, cb)
    TriggerServerEvent('scene:loadScene', data.id)
    cb("ok")
end)

-- Get scene list from DB
RegisterNUICallback('getScenes', function(_, cb)
    TriggerServerEvent('scene:getScenes')
    cb("ok")
end)

-- Delete scene from DB
RegisterNUICallback('deleteScene', function(data, cb)
    TriggerServerEvent('scene:deleteScene', data.id)
    cb("ok")
end)

-- =====================
-- SERVER -> CLIENT EVENTS
-- =====================

-- Server sends scene data after loadScene request
RegisterNetEvent("scene:loadData", function(jsonData)
    SceneStorage.ImportScene(jsonData)
end)

-- Server sends scene list
RegisterNetEvent("scene:sendScenes", function(scenes)
    SendNUIMessage({
        action = "sceneList",
        scenes = scenes or {}
    })
end)

-- Server confirms character saved, notify UI
RegisterNetEvent("scene:charSaved", function(id)
    SendNUIMessage({ action = "charSaved", id = id })
end)
