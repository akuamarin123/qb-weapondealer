local QBCore = exports['qb-core']:GetCoreObject()

-- Aktif teslimatları takip etme
local activeDeliveries = {}

-- Polis bildirimi
RegisterNetEvent('qb-weapondealer:server:PoliceAlert', function(heatLevel)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local heatData = Config.DeliverySystem.heatSystem.levels[heatLevel]
    if not heatData then return end
    
    -- Polis sayısı kontrolü
    local policeCount = 0
    local players = QBCore.Functions.GetPlayers()
    for _, player in ipairs(players) do
        local targetPlayer = QBCore.Functions.GetPlayer(player)
        if targetPlayer.PlayerData.job.name == "police" then
            policeCount = policeCount + 1
        end
    end
    
    if policeCount >= heatData.policeResponse then
        -- Polis bildirimini gönderme
        local coords = GetEntityCoords(GetPlayerPed(src))
        local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
        
        for _, player in ipairs(players) do
            local targetPlayer = QBCore.Functions.GetPlayer(player)
            if targetPlayer.PlayerData.job.name == "police" then
                TriggerClientEvent('police:client:PoliceAlert', player, {
                    title = 'Şüpheli Araç Aktivitesi',
                    coords = {x = coords.x, y = coords.y, z = coords.z},
                    description = string.format('Şüpheli araç aktivitesi tespit edildi. Bölge: %s', streetName)
                })
            end
        end
        
        -- Helikopter desteği
        if heatData.helicopter then
            -- Helikopter spawn etme kodu buraya gelecek
        end
    end
end)

-- Teslimat tamamlama
RegisterNetEvent('qb-weapondealer:server:FinishDelivery', function(success)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local deliveryData = activeDeliveries[src]
    if not deliveryData then return end
    
    if success then
        -- Ödeme ve itibar puanı verme
        local payment = deliveryData.price * (1 + (deliveryData.heatLevel * 0.2))
        Player.Functions.AddMoney('cash', payment)
        
        -- İtibar puanı ekleme
        local repBonus = deliveryData.heatLevel * 20
        exports['qb-weapondealer']:UpdateReputation(Player.PlayerData.citizenid, repBonus)
        
        TriggerClientEvent('QBCore:Notify', src, string.format('Teslimat tamamlandı! Kazanç: $%d + %d İtibar', payment, repBonus), 'success')
    end
    
    -- Aktif teslimat listesinden kaldırma
    activeDeliveries[src] = nil
end)

-- Teslimat başlatma
RegisterNetEvent('qb-weapondealer:server:StartDelivery', function(orderId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Sipariş kontrolü
    local orderData = MySQL.query.await('SELECT * FROM weapon_orders WHERE id = ? AND dealer_id = ? AND status = ?', 
        {orderId, Player.PlayerData.citizenid, 'pending'})
    
    if not orderData[1] then
        TriggerClientEvent('QBCore:Notify', src, 'Geçersiz sipariş!', 'error')
        return
    end
    
    -- Risk seviyesi belirleme
    local riskLevel = math.random(100)
    local routeType = riskLevel > 70 and "risky" or "safe"
    local vehicleType = riskLevel > 70 and "fast" or "stealth"
    
    -- Aktif teslimat listesine ekleme
    activeDeliveries[src] = {
        orderId = orderId,
        price = orderData[1].price,
        heatLevel = 1,
        startTime = os.time()
    }
    
    -- Client'a teslimat başlatma
    TriggerClientEvent('qb-weapondealer:client:StartDelivery', src, routeType, vehicleType)
end)

-- Polis yakalama
RegisterNetEvent('qb-weapondealer:server:CaughtByPolice', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(targetId)
    
    if not Player or not Target then return end
    if Player.PlayerData.job.name ~= "police" then return end
    
    local deliveryData = activeDeliveries[targetId]
    if not deliveryData then return end
    
    -- Teslimatı iptal etme
    TriggerClientEvent('qb-weapondealer:client:DeliveryFailed', targetId)
    activeDeliveries[targetId] = nil
    
    -- Polis ödülü
    local policeReward = deliveryData.price * 0.1
    Player.Functions.AddMoney('bank', policeReward)
    TriggerClientEvent('QBCore:Notify', src, string.format('Kaçakçıyı yakaladın! Ödül: $%d', policeReward), 'success')
    
    -- Kaçakçı cezası
    local dealerPenalty = deliveryData.price * 0.2
    Target.Functions.RemoveMoney('bank', dealerPenalty)
    exports['qb-weapondealer']:UpdateReputation(Target.PlayerData.citizenid, -50)
    TriggerClientEvent('QBCore:Notify', targetId, string.format('Yakalandın! Ceza: $%d ve -50 İtibar', dealerPenalty), 'error')
end)

-- Teslimat zamanlayıcısı
CreateThread(function()
    while true do
        for src, data in pairs(activeDeliveries) do
            if os.time() - data.startTime > 3600 then -- 1 saat zaman limiti
                TriggerClientEvent('qb-weapondealer:client:DeliveryFailed', src)
                activeDeliveries[src] = nil
            end
        end
        Wait(60000) -- Her dakika kontrol
    end
end) 