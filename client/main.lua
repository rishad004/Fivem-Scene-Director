local uiOpen = false

RegisterCommand('director', function()
    uiOpen = not uiOpen
    SetNuiFocus(uiOpen, uiOpen)
    SendNUIMessage({ action = "toggle", state = uiOpen })
end)

RegisterKeyMapping('director', 'Open Scene Director', 'keyboard', 'F5')

RegisterNUICallback('action', function(data, cb)
    if data.type == "spawnActor" then
        SpawnActor(data.id)
    elseif data.type == "playTimeline" then
        PlayTimeline()
    elseif data.type == "addCamKey" then
        AddCameraKey(data.duration)
    end
    cb('ok')
end)