function PlayAnim(dict, anim)
    if not SelectedActor then return end

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end

    TaskPlayAnim(SelectedActor, dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
end