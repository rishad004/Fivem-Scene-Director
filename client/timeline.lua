Timeline = {}
CameraKeys = {}

function AddCameraKey(duration)
    local cam = GetRenderingCam()
    if cam == -1 then return end

    table.insert(CameraKeys, {
        coords = GetCamCoord(cam),
        rot = GetCamRot(cam, 2),
        duration = duration or 3000
    })
end

function PlayTimeline()
    if #CameraKeys < 2 then return end

    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    RenderScriptCams(true, false, 0, true, true)

    for i = 1, #CameraKeys - 1 do
        local a = CameraKeys[i]
        local b = CameraKeys[i+1]

        local start = GetGameTimer()

        while GetGameTimer() - start < a.duration do
            local t = (GetGameTimer() - start) / a.duration
            t = t * t * (3 - 2 * t)

            local pos = a.coords + (b.coords - a.coords) * t
            local rot = a.rot + (b.rot - a.rot) * t

            SetCamCoord(cam, pos)
            SetCamRot(cam, rot, 2)

            Wait(0)
        end
    end

    RenderScriptCams(false, false, 0, true, true)
    DestroyCam(cam)
end