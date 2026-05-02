local cam = nil
FreecamActive = false   -- global so actors.lua can read it
local speed = 0.3

function ToggleFreecam()
    FreecamActive = not FreecamActive

    if FreecamActive then
        local coords = GetEntityCoords(PlayerPedId())
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(cam, coords.x, coords.y, coords.z + 1.5)
        SetCamRot(cam, 0.0, 0.0, GetEntityHeading(PlayerPedId()), 2)
        RenderScriptCams(true, true, 500, true, true)
        SetEntityVisible(PlayerPedId(), false, false)
        -- Release NUI mouse so freecam mouse look works
        SetNuiFocus(false, false)
    else
        RenderScriptCams(false, true, 500, true, true)
        DestroyCam(cam, false)
        cam = nil
        SetEntityVisible(PlayerPedId(), true, false)
        -- Restore NUI focus if UI was open
        SetNuiFocus(true, true)
    end

    -- Notify UI of new state
    SendNUIMessage({ action = "freecamToggled", active = FreecamActive })
end

-- F6 key mapping still works as a shortcut
RegisterKeyMapping('freecam', 'Toggle Free Camera', 'keyboard', 'F6')
RegisterCommand('freecam', function()
    ToggleFreecam()
end, false)

CreateThread(function()
    while true do
        Wait(0)

        if FreecamActive and cam then
            local rot = GetCamRot(cam, 2)

            -- Mouse look (hold RMB = control 25)
            if IsControlPressed(0, 25) then
                local dx = GetControlNormal(0, 1)
                local dy = GetControlNormal(0, 2)
                local newX = math.max(-89.0, math.min(89.0, rot.x - dy * 5.0))
                SetCamRot(cam, newX, 0.0, rot.z - dx * 5.0, 2)
            end

            -- Recalculate rot after potential update
            rot = GetCamRot(cam, 2)
            local radZ   = math.rad(rot.z)
            local radX   = math.rad(rot.x)
            local forward = vector3(
                -math.sin(radZ) * math.abs(math.cos(radX)),
                 math.cos(radZ) * math.abs(math.cos(radX)),
                 math.sin(radX)
            )
            local right = vector3(math.cos(radZ), math.sin(radZ), 0.0)

            local move = vector3(0.0, 0.0, 0.0)
            if IsControlPressed(0, 32) then move = move + forward end
            if IsControlPressed(0, 33) then move = move - forward end
            if IsControlPressed(0, 34) then move = move - right end
            if IsControlPressed(0, 35) then move = move + right end

            -- Vertical (Q/E)
            if IsControlPressed(0, 44) then move = move + vector3(0.0, 0.0, 1.0) end
            if IsControlPressed(0, 38) then move = move + vector3(0.0, 0.0, -1.0) end

            local coords = GetCamCoord(cam)
            local newPos = coords + move * speed
            SetCamCoord(cam, newPos.x, newPos.y, newPos.z)

            -- Speed: scroll wheel up/down
            if IsControlJustPressed(0, 241) then speed = math.min(2.0, speed + 0.1) end
            if IsControlJustPressed(0, 242) then speed = math.max(0.05, speed - 0.1) end
        end
    end
end)
