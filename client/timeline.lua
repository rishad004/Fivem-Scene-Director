Timeline = {}

-- =========================
-- TIMELINE STEP CREATION
-- =========================

function AddTimelineStep(duration)
    duration = tonumber(duration) or 3000

    local step = {
        duration   = duration,
        actors     = {},
        animations = {},   -- indexed by actor array index (NOT ped handle)
        camera     = nil
    }

    -- Snapshot every actor's world position + heading
    for i, ped in ipairs(Actors) do
        if DoesEntityExist(ped) then
            local coords  = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            step.actors[i] = {
                coords  = coords,
                heading = heading
            }
        end
    end

    -- Snapshot selected actor's current animation (keyed by actor INDEX)
    if SelectedActor and CurrentAnimation then
        for i, ped in ipairs(Actors) do
            if ped == SelectedActor then
                step.animations[i] = CurrentAnimation
                break
            end
        end
    end

    -- Snapshot camera state
    local renderCam = GetRenderingCam()
    if renderCam ~= -1 then
        local coords = GetCamCoord(renderCam)
        local rot    = GetCamRot(renderCam, 2)
        step.camera  = {
            coords = { x = coords.x, y = coords.y, z = coords.z },
            rot    = { x = rot.x,    y = rot.y,    z = rot.z    }
        }
    end

    table.insert(Timeline, step)
    return Timeline
end

-- AddCameraKey: add a step using ONLY the current camera (no actor snapshot reset)
function AddCameraKey(duration)
    AddTimelineStep(duration or 3000)
end

function GetTimeline()
    return Timeline
end

function RemoveTimelineStep(index)
    table.remove(Timeline, index)
end

function UpdateStepDuration(index, duration)
    if Timeline[index] then
        Timeline[index].duration = tonumber(duration) or Timeline[index].duration
    end
end

-- =========================
-- LERP HELPERS
-- =========================

function Lerp(a, b, t)
    return a + (b - a) * t
end

function LerpVector(a, b, t)
    return vector3(
        Lerp(a.x, b.x, t),
        Lerp(a.y, b.y, t),
        Lerp(a.z, b.z, t)
    )
end

function EaseInOut(t)
    return t * t * (3.0 - 2.0 * t)
end

-- =========================
-- SMOOTH ANIMATION TRANSITION
-- (Canonical definition - used by playback + animation.lua)
-- =========================

function PlayAnimSmooth(ped, dict, anim)
    if not ped or not DoesEntityExist(ped) then return end
    if not dict or not anim then return end

    ClearPedTasks(ped)
    Wait(100)

    RequestAnimDict(dict)
    local timeout = 0
    while not HasAnimDictLoaded(dict) do
        Wait(0)
        timeout = timeout + 1
        if timeout > 200 then return end  -- safety: don't hang forever
    end

    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
end

-- =========================
-- TIMELINE PLAYBACK
-- =========================

function PlayTimeline()
    if #Timeline < 1 then
        print('[Scene Director] Timeline is empty.')
        return
    end

    -- Close NUI, hide player
    SetNuiFocus(false, false)
    SetEntityVisible(PlayerPedId(), false, false)

    -- Create a dedicated playback camera
    local playCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    RenderScriptCams(true, false, 0, true, true)

    -- Seed the camera at step 1 position immediately
    if Timeline[1].camera then
        local c = Timeline[1].camera
        SetCamCoord(playCam, c.coords.x, c.coords.y, c.coords.z)
        SetCamRot(playCam, c.rot.x, c.rot.y, c.rot.z, 2)
    end

    for i = 1, #Timeline do
        local step     = Timeline[i]
        local nextStep = Timeline[i + 1]

        -- Fire animations for this step at its START
        for actorIdx, animData in pairs(step.animations) do
            local ped = Actors[actorIdx]
            if ped and DoesEntityExist(ped) then
                Citizen.CreateThread(function()
                    PlayAnimSmooth(ped, animData.dict, animData.anim)
                end)
            end
        end

        local startTime = GetGameTimer()

        while GetGameTimer() - startTime < step.duration do
            local elapsed = GetGameTimer() - startTime
            local t       = EaseInOut(math.min(elapsed / step.duration, 1.0))

            -- Camera interpolation
            if step.camera and nextStep and nextStep.camera then
                local sc, nc = step.camera, nextStep.camera
                local pos = LerpVector(
                    vector3(sc.coords.x, sc.coords.y, sc.coords.z),
                    vector3(nc.coords.x, nc.coords.y, nc.coords.z),
                    t
                )
                local rot = LerpVector(
                    vector3(sc.rot.x, sc.rot.y, sc.rot.z),
                    vector3(nc.rot.x, nc.rot.y, nc.rot.z),
                    t
                )
                SetCamCoord(playCam, pos.x, pos.y, pos.z)
                SetCamRot(playCam, rot.x, rot.y, rot.z, 2)
            elseif step.camera and not nextStep then
                -- Hold last camera position
                local c = step.camera
                SetCamCoord(playCam, c.coords.x, c.coords.y, c.coords.z)
                SetCamRot(playCam, c.rot.x, c.rot.y, c.rot.z, 2)
            end

            -- Actor position interpolation
            if nextStep then
                for idx, data in ipairs(step.actors) do
                    local ped      = Actors[idx]
                    local nextData = nextStep.actors[idx]
                    if ped and DoesEntityExist(ped) and nextData then
                        local pos     = LerpVector(data.coords, nextData.coords, t)
                        local heading = Lerp(data.heading, nextData.heading, t)
                        SetEntityCoordsNoOffset(ped, pos.x, pos.y, pos.z, false, false, false)
                        SetEntityHeading(ped, heading)
                    end
                end
            end

            Wait(0)
        end

        -- Snap to exact final values at end of step (prevents drift)
        for idx, data in ipairs(step.actors) do
            local ped = Actors[idx]
            if ped and DoesEntityExist(ped) then
                SetEntityCoordsNoOffset(ped, data.coords.x, data.coords.y, data.coords.z, false, false, false)
                SetEntityHeading(ped, data.heading)
            end
        end
    end

    -- Teardown
    RenderScriptCams(false, true, 500, true, true)
    DestroyCam(playCam, false)
    SetEntityVisible(PlayerPedId(), true, false)
end
