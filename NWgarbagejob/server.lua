--[[
Created by Lama Development
Developed by TheStoicBear
]] --

-- Event handler for starting the Trash Collector job
RegisterNetEvent("TrashCollector:started", function(garbageTruck)
    local player = source -- Assuming source refers to the player who triggered the event

    if Config.UseND then
        if DoesEntityExist(garbageTruck) then
            local netId = NetworkGetNetworkIdFromEntity(garbageTruck)
            -- Assuming you have a way to handle vehicle access/keys
            
        else
            print("Invalid garbage truck entity!")
        end
    end
end)

-- Event handler for giving reward to the player
RegisterServerEvent('TrashCollector:GiveReward')
AddEventHandler('TrashCollector:GiveReward', function(randomPayment)
    local playerId = source
    -- Retrieve current account information
    local accountInfo = exports['money']:getaccount(playerId)

    if accountInfo then
        local newCash = (accountInfo.cash or 0) + randomPayment
        local updatedAccount = {
            cash = newCash,
            bank = accountInfo.bank or 0
        }
        local success = exports['money']:updateaccount(playerId, updatedAccount)
        print(success and "Reward processed successfully" or "Failed to process reward")
    else
        print("Failed to retrieve player account information")
    end
end)
