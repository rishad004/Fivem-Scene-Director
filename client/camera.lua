local cam = nil
local active = false
local speed = 0.3

function ToggleFreecam()
    active = not active

    if active then
        local coords = GetEntityCoords(PlayerPedId())
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(cam, coords.x, coords.y, coords.z + 1)
        RenderScriptCams(true, false, 0, true, true)
        SetEntityVisible(PlayerPedId(), false)
    else
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cam)
        SetEntityVisible(PlayerPedId(), true)
    end
end

RegisterCommand('freecam', ToggleFreecam)

CreateThread(function()
    while true do
        if active then
            local rot = GetCamRot(cam, 2)

            if IsControlPressed(0, 25) then
                local dx = GetControlNormal(0, 1)
                local dy = GetControlNormal(0, 2)

                SetCamRot(cam, rot.x - dy * 3.0, 0.0, rot.z - dx * 3.0, 2)
            end

            local forward = GetCamForwardVector(cam)
            local right = vector3(forward.y, -forward.x, 0)

            local move = vector3(0,0,0)

            if IsControlPressed(0, 32) then move = move + forward end
            if IsControlPressed(0, 33) then move = move - forward end
            if IsControlPressed(0, 34) then move = move - right end
            if IsControlPressed(0, 35) then move = move + right end

            local coords = GetCamCoord(cam)
            SetCamCoord(cam, coords + move * speed)

            if IsControlJustPressed(0, 241) then speed = speed + 0.1 end
            if IsControlJustPressed(0, 242) then speed = math.max(0.1, speed - 0.1) end
        end
        Wait(0)
    end
end)