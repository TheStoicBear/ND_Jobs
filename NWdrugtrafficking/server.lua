-- variables, do not touch
local deliveries = {}
local playersOnJob = {}

RegisterNetEvent("DrugTrafficking:StartedCollecting", function(drugVan)
    local src = source
    playersOnJob[src] = true
    -- No exploit check for starting the job
end)

RegisterNetEvent("DrugTrafficking:DrugsDelivered", function(location)
    local src = source
    -- keep track of amount of deliveries made
    if not deliveries[src] then
        deliveries[src] = 0
    end
    deliveries[src] = deliveries[src] + 1
end)

RegisterNetEvent("DrugTrafficking:NeedsPayment", function()
    local src = source
    if not deliveries[src] or deliveries[src] == 0 then
        print(string.format("^1Warning: Player %s requested payment without completing the job", GetPlayerName(src)))
        return
    end

    -- calculate amount of money to give to the player
    local amount = Config.DrugPay * deliveries[src]

    -- Retrieve current account information
    local accountInfo = exports['money']:getaccount(src)

    if accountInfo then
        local newCash = (accountInfo.cash or 0) + amount
        local updatedAccount = {
            cash = newCash,
            bank = accountInfo.bank or 0
        }
        local success = exports['money']:updateaccount(src, updatedAccount)
        print(success and "Payment processed successfully" or "Failed to process payment")
    else
        print("Failed to retrieve player account information")
    end

    -- Reset delivery tracking
    deliveries[src] = 0
    playersOnJob[src] = false
end)
