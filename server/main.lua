-- =========================
-- DATABASE MIGRATIONS
-- =========================
local function runMigrations()
    print('[Scene Director] Running database migrations...')

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS scene_characters (
            id         INT AUTO_INCREMENT PRIMARY KEY,
            appearance LONGTEXT NOT NULL
        );
    ]])

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS scene_scenes (
            id         INT AUTO_INCREMENT PRIMARY KEY,
            name       VARCHAR(255) NOT NULL DEFAULT 'Untitled',
            data       LONGTEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
    ]])

    print('[Scene Director] Database ready.')
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(500)
        runMigrations()
    end
end)

-- =========================
-- CHARACTER SYSTEM
-- =========================

RegisterNetEvent('scene:saveCharacter', function(appearance)
    local src = source

    if type(appearance) ~= "table" then
        print('[Scene Director] Invalid appearance from player ' .. src)
        return
    end

    local id = MySQL.insert.await(
        'INSERT INTO scene_characters (appearance) VALUES (?)',
        { json.encode(appearance) }
    )

    if id then
        TriggerClientEvent('chat:addMessage', src, {
            args = { '^2[Scene Director]', 'Character saved! ID: ' .. id }
        })
        -- Also notify NUI so UI can show the ID
        TriggerClientEvent('scene:charSaved', src, id)
    end
end)

RegisterNetEvent('scene:getChar', function(id)
    local src = source

    if not id or tonumber(id) == nil then
        print('[Scene Director] Invalid character ID from player ' .. src)
        return
    end

    local result = MySQL.single.await(
        'SELECT appearance FROM scene_characters WHERE id = ?',
        { tonumber(id) }
    )

    if not result then
        print('[Scene Director] Character ID ' .. id .. ' not found.')
        TriggerClientEvent('chat:addMessage', src, {
            args = { '^1[Scene Director]', 'Character ID ' .. id .. ' not found.' }
        })
        return
    end

    TriggerClientEvent('scene:spawnChar', src, json.decode(result.appearance))
end)

-- =========================
-- SCENE SYSTEM
-- =========================

-- SAVE SCENE
RegisterNetEvent('scene:saveScene', function(name, data)
    local src = source

    if type(name) ~= "string" or name == "" then
        name = "Untitled"
    end

    if type(data) ~= "string" or data == "" then
        print('[Scene Director] Empty scene data from player ' .. src)
        return
    end

    local id = MySQL.insert.await(
        'INSERT INTO scene_scenes (name, data) VALUES (?, ?)',
        { name, data }
    )

    if id then
        TriggerClientEvent('chat:addMessage', src, {
            args = { '^3[Scene Director]', 'Scene "' .. name .. '" saved! ID: ' .. id }
        })
        -- Refresh scene list on the client that saved
        local scenes = MySQL.query.await('SELECT id, name FROM scene_scenes ORDER BY id DESC')
        TriggerClientEvent('scene:sendScenes', src, scenes or {})
    end
end)

-- GET ALL SCENES
RegisterNetEvent('scene:getScenes', function()
    local src = source

    local result = MySQL.query.await(
        'SELECT id, name FROM scene_scenes ORDER BY id DESC'
    )

    TriggerClientEvent('scene:sendScenes', src, result or {})
end)

-- LOAD SCENE BY ID
RegisterNetEvent('scene:loadScene', function(id)
    local src = source

    if not id or tonumber(id) == nil then return end

    local result = MySQL.single.await(
        'SELECT data FROM scene_scenes WHERE id = ?',
        { tonumber(id) }
    )

    if not result then
        print('[Scene Director] Scene ID ' .. id .. ' not found.')
        TriggerClientEvent('chat:addMessage', src, {
            args = { '^1[Scene Director]', 'Scene ID ' .. id .. ' not found.' }
        })
        return
    end

    TriggerClientEvent('scene:loadData', src, result.data)
end)

-- DELETE SCENE
RegisterNetEvent('scene:deleteScene', function(id)
    local src = source

    if not id or tonumber(id) == nil then return end

    MySQL.query.await(
        'DELETE FROM scene_scenes WHERE id = ?',
        { tonumber(id) }
    )

    TriggerClientEvent('chat:addMessage', src, {
        args = { '^1[Scene Director]', 'Scene ' .. id .. ' deleted.' }
    })

    -- Refresh the scene list
    local scenes = MySQL.query.await('SELECT id, name FROM scene_scenes ORDER BY id DESC')
    TriggerClientEvent('scene:sendScenes', src, scenes or {})
end)
