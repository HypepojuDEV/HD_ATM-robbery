ESX = exports['es_extended']:getSharedObject()

local isATMRobberyActive = false

ESX.RegisterServerCallback('HD_atmrobbery:canRob', function(source, cb)
    local xPlayers = ESX.GetPlayers()
    local policeCount = 0

    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == 'police' then
            policeCount = policeCount + 1
        end
    end

    if policeCount >= Config.RequiredCops and not isATMRobberyActive then
        cb(true)
        isATMRobberyActive = true
    else
        cb(false)
    end
end)

RegisterServerEvent('HD_atmrobbery:notifyPolice')
AddEventHandler('HD_atmrobbery:notifyPolice', function(atm)
    local xPlayers = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == 'police' then
            if Config.UseCDDispatch then
                -- cd_dispatch ilmoitus
                TriggerEvent('cd_dispatch:AddNotification', {
                    job_table = {'police'},
                    coords = {x = atm.x, y = atm.y, z = atm.z},
                    title = '023A - Automaattiryöstö',
                    message = 'ATM ryöstö käynnissä sijainnissa: [' .. atm.x .. ', ' .. atm.y .. ']',
                    flash = 0,
                    unique_id = tostring(math.random(0000000, 9999999)),
                    blip = {
                        sprite = 161,
                        scale = 1.2,
                        colour = 1,
                        flashes = false,
                        text = '023A - Automaattiryöstö',
                        time = (5*60*1000),
                        sound = 1,
                    }
                })
            else
                -- ESX ilmoitus
                TriggerClientEvent('esx:showNotification', xPlayer.source, "ATM ryöstö käynnissä sijainnissa: [" .. atm.x .. ", " .. atm.y .. ", " .. atm.z .. "]")
            end
        end
    end
end)

ESX.RegisterServerCallback('HD_atmrobbery:reward', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local reward = math.random(Config.MinReward, Config.MaxReward)
    xPlayer.addMoney(reward)
    cb(reward)
    isATMRobberyActive = false
end)
