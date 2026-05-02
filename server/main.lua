local characters = {}

RegisterNetEvent('scene-director:saveCharacter', function(appearance)
    local src = source
    MySQL.insert('INSERT INTO scene_characters (appearance) VALUES (?)', {json.encode(appearance)})
end)

RegisterNetEvent('scene-director:getCharacters', function()
    local src = source
    local result = MySQL.query.await('SELECT * FROM scene_characters', {})
    TriggerClientEvent('scene-director:sendCharacters', src, result)
end)

RegisterNetEvent('scene-director:loadCharacter', function(id)
    local src = source
    local result = MySQL.single.await('SELECT * FROM scene_characters WHERE id = ?', {id})
    if result then
        TriggerClientEvent('scene-director:applyCharacter', src, json.decode(result.appearance))
    end
end)
