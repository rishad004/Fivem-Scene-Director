local currentCharacter = nil

RegisterCommand('createchar', function()
    TriggerEvent('illenium-appearance:client:openClothingShop', function(appearance)
        if appearance then
            currentCharacter = appearance
            TriggerServerEvent('scene-director:saveCharacter', appearance)
            print('Character saved!')
        end
    end)
end)

RegisterCommand('loadchars', function()
    TriggerServerEvent('scene-director:getCharacters')
end)

RegisterNetEvent('scene-director:sendCharacters', function(chars)
    print('Your saved characters:')
    for i, v in ipairs(chars) do
        print(i, v.id)
    end
end)

RegisterCommand('usechar', function(source, args)
    local id = tonumber(args[1])
    if not id then return end
    TriggerServerEvent('scene-director:loadCharacter', id)
end)

RegisterNetEvent('scene-director:applyCharacter', function(appearance)
    exports['illenium-appearance']:setPlayerAppearance(appearance)
end)
