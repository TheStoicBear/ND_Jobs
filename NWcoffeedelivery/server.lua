--[[
Created by Lama Development
Developed by 5M-CodeX
]] --

-- Event handler for starting the Food Delivery job
RegisterNetEvent("FoodDelivery:started", function(spawned_car)
    local player = source -- Assuming source refers to the player who triggered the event

    if Config.UseND then
        -- Check if the entity exists before proceeding
        if DoesEntityExist(spawned_car) then
            local netId = NetworkGetNetworkIdFromEntity(spawned_car)
            -- Assuming Where you can set accces / keys
        else
            print("Invalid vehicle entity!")
        end
    end
end)

-- Event handler for successful Food Delivery
RegisterServerEvent('FoodDelivery:success')
AddEventHandler('FoodDelivery:success', function(pay)
    local playerId = source
    local accountInfo = exports['money']:getaccount(playerId)

    if accountInfo then
        local newCash = (accountInfo.cash or 0) + pay
        local updatedAccount = {
            cash = newCash,
            bank = accountInfo.bank or 0
        }
        local success = exports['money']:updateaccount(playerId, updatedAccount)
        print(success and "Money updated successfully" or "Failed to update money")
    else
        print("Failed to retrieve player account information")
    end
end)

-- Event handler for penalty in Food Delivery
RegisterServerEvent("FoodDelivery:penalty")
AddEventHandler("FoodDelivery:penalty", function(money)
    local playerId = source
    local accountInfo = exports['money']:getaccount(playerId)

    if accountInfo then
        local newCash = (accountInfo.cash or 0) - money
        -- Ensure the new cash balance does not go below zero
        newCash = math.max(newCash, 0)
        local updatedAccount = {
            cash = newCash,
            bank = accountInfo.bank or 0
        }
        local success = exports['money']:updateaccount(playerId, updatedAccount)
        print(success and "Penalty applied successfully" or "Failed to apply penalty")
    else
        print("Failed to retrieve player account information")
    end
end)
