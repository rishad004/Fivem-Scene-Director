SceneStorage = {}

-- =====================
-- HELPERS
-- =====================
local function VecToTable(v)
    return { x = v.x, y = v.y, z = v.z }
end

local function TableToVec(t)
    return vector3(t.x, t.y, t.z)
end

-- =====================
-- EXPORT SCENE
-- =====================
function SceneStorage.ExportScene()
    local scene = {
        actors   = {},
        timeline = {}
    }

    -- Snapshot actors
    for i, ped in ipairs(Actors) do
        if DoesEntityExist(ped) then
            scene.actors[i] = {
                coords  = VecToTable(GetEntityCoords(ped)),
                heading = GetEntityHeading(ped),
                model   = GetEntityModel(ped)
            }
        end
    end

    -- Deep-copy timeline, converting vector3 values to plain tables
    for i, step in ipairs(Timeline) do
        local s = {
            duration   = step.duration,
            animations = step.animations or {},
            actors     = {},
            camera     = nil
        }

        for j, a in ipairs(step.actors) do
            s.actors[j] = {
                coords  = VecToTable(a.coords),
                heading = a.heading
            }
        end

        if step.camera then
            -- camera coords/rot are already plain tables (set that way in timeline.lua)
            s.camera = {
                coords = step.camera.coords,
                rot    = step.camera.rot
            }
        end

        scene.timeline[i] = s
    end

    return json.encode(scene)
end

-- =====================
-- IMPORT SCENE
-- =====================
function SceneStorage.ImportScene(jsonData)
    if not jsonData or jsonData == "" then return end

    local data = json.decode(jsonData)
    if not data then
        print('[Scene Director] Failed to decode scene JSON.')
        return
    end

    -- Restore timeline
    Timeline = {}
    for _, step in ipairs(data.timeline or {}) do
        local newStep = {
            duration   = step.duration,
            animations = step.animations or {},
            actors     = {},
            camera     = step.camera  -- already plain table with .coords/.rot
        }

        for i, a in ipairs(step.actors or {}) do
            newStep.actors[i] = {
                coords  = TableToVec(a.coords),
                heading = a.heading
            }
        end

        table.insert(Timeline, newStep)
    end

    -- Reposition existing actors (does not respawn — actors must already be in world)
    for i, a in ipairs(data.actors or {}) do
        if Actors[i] and DoesEntityExist(Actors[i]) then
            SetEntityCoordsNoOffset(Actors[i], a.coords.x, a.coords.y, a.coords.z, false, false, false)
            SetEntityHeading(Actors[i], a.heading)
        end
    end

    print('[Scene Director] Scene imported. Steps: ' .. #Timeline)
end
