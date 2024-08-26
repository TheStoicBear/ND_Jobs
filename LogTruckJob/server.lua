-- variables, do not touch
local deliveries = {}
local playersOnJob = {}

-- function to check if the client is actually at the job ending location before giving them the money
function isClientTooFar(location)
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    local locationVector = vector3(location.x, location.y, location.z)
    local distance = #(playerCoords - locationVector)
    -- checking from a distance of 25 because it might not be 100% correct
    return distance > 25
end

RegisterNetEvent("lama_jobs:started", function()
    local src = source
    local Framework = exports[Config.FrameworkName].getServerFunctions()
    local player = Framework.getPlayer(src)
    playersOnJob[src] = true
end)

RegisterNetEvent("lama_jobs:delivered", function(location)
    local src = source
    local Framework = exports[Config.FrameworkName].getServerFunctions()
    local player = Framework.getPlayer(src)
    
    if playersOnJob[src] and not isClientTooFar(location) then
        -- keep track of amount of deliveries made
        if not deliveries[src] then
            deliveries[src] = 0
        end
        deliveries[src] = deliveries[src] + 1
    else
        -- Log a potential exploit
        local playerName = GetPlayerName(src)
        local playerId = GetPlayerIdentifier(src, 0)
        print(string.format("^1Possible exploiter detected\nName: ^0%s\n^1Identifier: ^0%s\n^1Reason: ^0has delivered from too far away", playerName, playerId))
    end
end)

RegisterNetEvent("lama_jobs:finished", function()
    local src = source
    local Framework = exports[Config.FrameworkName].getServerFunctions()
    local player = Framework.getPlayer(src)
    
    if not deliveries[src] or deliveries[src] == 0 then
        -- Log a potential exploit
        local playerName = GetPlayerName(src)
        local playerId = GetPlayerIdentifier(src, 0)
        print(string.format("^1Possible exploiter detected\nName: ^0%s\n^1Identifier: ^0%s\n^1Reason: ^0has requested payment without making deliveries", playerName, playerId))
    else
        -- calculate amount of money to give to the player
        local amount = Config.PayPerDelivery * deliveries[src]
        -- only give the money to the client if they are on the job and near the ending location
        if playersOnJob[src] and not isClientTooFar(Config.DepotLocation) then
            -- get current account information
            local accountInfo = exports['money']:getaccount(src)
            if accountInfo then
                -- Update the player's account with the new amount
                local newCash = (accountInfo.cash or 0) + amount
                local updatedAccount = {
                    cash = newCash,
                    bank = accountInfo.bank or 0
                }
                exports['money']:updateaccount(src, updatedAccount)
                
                -- Reset delivery count and job status
                deliveries[src] = 0
                playersOnJob[src] = false
            end
        else
            -- Log a potential exploit
            local playerName = GetPlayerName(src)
            local playerId = GetPlayerIdentifier(src, 0)
            print(string.format("^1Possible exploiter detected\nName: ^0%s\n^1Identifier: ^0%s\n^1Reason: ^0has requested payment without being near the job ending location", playerName, playerId))
        end
    end
end)

RegisterNetEvent("lama_jobs:forcequit", function()
    local src = source
    local penalty = Config.Penalty
    local Framework = exports[Config.FrameworkName].getServerFunctions()
    local player = Framework.getPlayer(src)
    local accountInfo = exports['money']:getaccount(src)
    
    if accountInfo then
        -- Deduct the penalty amount
        local newCash = (accountInfo.cash or 0) - penalty
        local updatedAccount = {
            cash = newCash,
            bank = accountInfo.bank or 0
        }
        exports['money']:updateaccount(src, updatedAccount)
    end
end)

-- version checker
Citizen.CreateThread(function()
    local updatePath = "/lama-development/TruckJob"
    local resourceName = "TruckJob by Lama"

    function checkVersion(err, responseText, headers)
        -- Returns the version set in the file
        local curVersion = GetResourceMetadata(GetCurrentResourceName(), "version")

        if responseText == nil or curVersion == nil then
            print("^1There was an error retrieving the version of " .. resourceName .. ": the version checker will be skipped.")
        else
            if tonumber(curVersion) == tonumber(responseText) then
                print("^2" .. resourceName .. " is up to date. Enjoy.")
            else
                print("^1" .. resourceName .. " is outdated.\nLatest version: " .. responseText .. "\nCurrent version: " .. curVersion .. "\nPlease update it from: https://github.com" .. updatePath)
            end
        end
    end

    PerformHttpRequest("https://raw.githubusercontent.com" .. updatePath .. "/main/version", checkVersion, "GET")
end)
