CurrentAnimation = nil

-- Play animation on the currently selected actor
function PlayAnim(dict, anim)
    if not SelectedActor or not DoesEntityExist(SelectedActor) then
        print('[Scene Director] No actor selected for animation.')
        return
    end

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end

    TaskPlayAnim(SelectedActor, dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)

    CurrentAnimation = { dict = dict, anim = anim }
end

-- Hard stop: clear all tasks on a ped
function StopAnim(ped)
    if not ped or not DoesEntityExist(ped) then return end
    ClearPedTasks(ped)
    ClearPedSecondaryTask(ped)
end

-- NOTE: PlayAnimSmooth is defined in timeline.lua and used by both
-- the timeline playback system and anywhere else that needs smooth transitions.
