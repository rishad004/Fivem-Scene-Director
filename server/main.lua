local function runMigrations()
    print('[Scene Director] Running database migrations...')

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS scene_characters (
            id INT AUTO_INCREMENT PRIMARY KEY,
            appearance LONGTEXT
        );
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS scene_scenes (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100),
            data LONGTEXT
        );
    ]])

    print('[Scene Director] Database ready.')
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(500) -- give oxmysql time to init
        runMigrations()
    end
end)

-- Existing logic
RegisterNetEvent('scene:getChar', function(id)
    local src = source
    local result = MySQL.single.await(
        'SELECT * FROM scene_characters WHERE id = ?', 
        {id}
    )

    if result then
        TriggerClientEvent('scene:spawnChar', src, json.decode(result.appearance))
    end
end)