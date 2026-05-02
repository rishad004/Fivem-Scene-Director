local Scenes = {}

-- SAVE SCENE
RegisterNetEvent("scene:save", function(name, data)
    local src = source

    MySQL.insert('INSERT INTO scene_scenes (name, data) VALUES (?, ?)', {
        name,
        data
    })
end)

-- GET ALL SCENES
RegisterNetEvent("scene:getAll", function()
    local src = source

    local result = MySQL.query.await('SELECT * FROM scene_scenes')

    TriggerClientEvent("scene:sendAll", src, result)
end)

-- LOAD SCENE
RegisterNetEvent("scene:load", function(id)
    local src = source

    local result = MySQL.single.await(
        'SELECT data FROM scene_scenes WHERE id = ?',
        { id }
    )

    if result then
        TriggerClientEvent("scene:loadData", src, result.data)
    end
end)

-- DELETE SCENE
RegisterNetEvent("scene:delete", function(id)
    MySQL.query('DELETE FROM scene_scenes WHERE id = ?', { id })
end)