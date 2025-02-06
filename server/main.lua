local QBCore = exports['qb-core']:GetCoreObject()

-- Veritabanı tabloları oluşturma
CreateThread(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS weapon_dealers (
            citizenid VARCHAR(50) PRIMARY KEY,
            reputation INT DEFAULT 0,
            total_sales INT DEFAULT 0,
            active_orders TEXT,
            workshop_level INT DEFAULT 1,
            storage_level INT DEFAULT 1,
            heat_level INT DEFAULT 0,
            last_delivery TIMESTAMP,
            total_deliveries INT DEFAULT 0,
            successful_deliveries INT DEFAULT 0,
            failed_deliveries INT DEFAULT 0
        )
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS weapon_orders (
            id INT AUTO_INCREMENT PRIMARY KEY,
            dealer_id VARCHAR(50),
            customer_id VARCHAR(50),
            weapon_type VARCHAR(50),
            quantity INT,
            price INT,
            status VARCHAR(20),
            risk_level VARCHAR(20),
            delivery_type VARCHAR(20),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            delivery_date TIMESTAMP NULL DEFAULT NULL,
            completed_at TIMESTAMP NULL DEFAULT NULL,
            FOREIGN KEY (dealer_id) REFERENCES weapon_dealers(citizenid)
        )
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS weapon_inventory (
            id INT AUTO_INCREMENT PRIMARY KEY,
            dealer_id VARCHAR(50),
            item_type VARCHAR(50),
            quantity INT,
            quality FLOAT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (dealer_id) REFERENCES weapon_dealers(citizenid)
        )
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS weapon_deliveries (
            id INT AUTO_INCREMENT PRIMARY KEY,
            dealer_id VARCHAR(50),
            order_id INT,
            route_type VARCHAR(20),
            vehicle_type VARCHAR(20),
            start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            end_time TIMESTAMP NULL DEFAULT NULL,
            success BOOLEAN DEFAULT FALSE,
            heat_level INT DEFAULT 1,
            police_encounters INT DEFAULT 0,
            distance_traveled FLOAT DEFAULT 0,
            earnings INT DEFAULT 0,
            reputation_gained INT DEFAULT 0,
            FOREIGN KEY (dealer_id) REFERENCES weapon_dealers(citizenid),
            FOREIGN KEY (order_id) REFERENCES weapon_orders(id)
        )
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS weapon_police_reports (
            id INT AUTO_INCREMENT PRIMARY KEY,
            delivery_id INT,
            officer_id VARCHAR(50),
            report_type VARCHAR(20),
            description TEXT,
            location VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (delivery_id) REFERENCES weapon_deliveries(id)
        )
    ]])
end)

-- Oyuncu ilk girişte kontrol
RegisterNetEvent('QBCore:Server:PlayerLoaded', function(Player)
    local citizenid = Player.PlayerData.citizenid
    
    MySQL.query('SELECT * FROM weapon_dealers WHERE citizenid = ?', {citizenid}, function(result)
        if result[1] == nil then
            MySQL.insert('INSERT INTO weapon_dealers (citizenid) VALUES (?)', {citizenid})
        end
    end)
end)

-- İtibar puanı güncelleme
function UpdateReputation(citizenid, amount)
    MySQL.query('UPDATE weapon_dealers SET reputation = reputation + ? WHERE citizenid = ?', {amount, citizenid})
end

-- Envanter kontrolü
function CheckInventory(citizenid, itemType, quantity)
    local result = MySQL.query.await('SELECT quantity FROM weapon_inventory WHERE dealer_id = ? AND item_type = ?', {citizenid, itemType})
    if result[1] then
        return result[1].quantity >= quantity
    end
    return false
end

-- Yeni sipariş oluşturma
function CreateOrder(dealerId, customerId, weaponType, quantity, price)
    local success = MySQL.insert.await('INSERT INTO weapon_orders (dealer_id, customer_id, weapon_type, quantity, price, status) VALUES (?, ?, ?, ?, ?, ?)',
        {dealerId, customerId, weaponType, quantity, price, 'pending'})
    return success
end

-- Sipariş durumu güncelleme
function UpdateOrderStatus(orderId, status)
    MySQL.query('UPDATE weapon_orders SET status = ? WHERE id = ?', {status, orderId})
end

-- Envanter güncelleme
function UpdateInventory(dealerId, itemType, quantity, quality)
    MySQL.query('INSERT INTO weapon_inventory (dealer_id, item_type, quantity, quality) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE quantity = quantity + ?',
        {dealerId, itemType, quantity, quality, quantity})
end

-- Kalite Hesaplama Sistemi
function CalculateWeaponQuality(citizenid, weaponType)
    local playerData = MySQL.query.await('SELECT reputation, workshop_level FROM weapon_dealers WHERE citizenid = ?', {citizenid})
    if not playerData[1] then return 'poor' end

    local reputation = playerData[1].reputation
    local workshopLevel = playerData[1].workshop_level

    -- Temel şans hesaplama
    local qualityRoll = math.random(1, 100)
    local baseQualityChance = Config.QualitySystem.baseQualityChance

    -- Yetenek bonusları
    local reputationBonus = math.floor(reputation / 1000) * Config.QualitySystem.skillEffect.reputationBonus
    local workshopBonus = workshopLevel * Config.QualitySystem.skillEffect.workshopBonus
    
    -- Toplam bonus
    local totalBonus = reputationBonus + workshopBonus
    qualityRoll = qualityRoll + totalBonus

    -- Kalite seviyesi belirleme
    if qualityRoll >= 95 then
        return 'perfect'
    elseif qualityRoll >= 80 then
        return 'good'
    elseif qualityRoll >= 40 then
        return 'normal'
    else
        return 'poor'
    end
end

-- Silah fiyatı hesaplama
function CalculateWeaponPrice(weaponType, quality)
    local basePrice = Config.WeaponParts[weaponType].basePrice
    local multiplier = Config.QualitySystem.qualityMultipliers[quality]
    return math.floor(basePrice * multiplier)
end

-- Silah üretimi tamamlandığında
RegisterNetEvent('qb-weapondealer:server:FinishCrafting', function(weaponType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Kalite hesaplama
    local quality = CalculateWeaponQuality(Player.PlayerData.citizenid, weaponType)
    
    -- Silah özellikleri
    local weaponStats = Config.WeaponParts[weaponType].qualityCheck[quality]
    
    -- Fiyat hesaplama
    local price = CalculateWeaponPrice(weaponType, quality)
    
    -- Silahı oyuncunun envanterine ekleme
    local weaponName = "weapon_" .. weaponType
    Player.Functions.AddItem(weaponName, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBShared.Items[weaponName], "add")
    
    -- Envantere ekleme
    UpdateInventory(Player.PlayerData.citizenid, weaponType, 1, quality)
    
    -- İtibar puanı ekleme (kaliteye göre)
    local repBonus = quality == 'perfect' and 50 or quality == 'good' and 30 or quality == 'normal' and 15 or 5
    UpdateReputation(Player.PlayerData.citizenid, repBonus)
    
    -- Oyuncuya bilgi verme
    TriggerClientEvent('QBCore:Notify', src, string.format('Silah üretimi tamamlandı! Kalite: %s', quality), 'success')
    TriggerClientEvent('QBCore:Notify', src, string.format('Tahmini değer: $%s', price), 'info')
end)

-- NPC Müşteri Yönetimi
local activeNPCOrders = {}
local activeNPCs = {}

-- NPC Müşteri oluşturma
function CreateNPCCustomer()
    -- Aktif sipariş kontrolü
    if #activeNPCOrders >= Config.NPCCustomers.maxActiveOrders then return end

    -- Müşteri tipi seçimi
    local customerTypes = {}
    for type, data in pairs(Config.NPCCustomers.customerTypes) do
        table.insert(customerTypes, {type = type, data = data})
    end

    local selectedCustomer = customerTypes[math.random(#customerTypes)]
    local customerType = selectedCustomer.type
    local customerData = selectedCustomer.data

    -- Sipariş verme şansı kontrolü
    if math.random(100) > customerData.orderChance then return end

    -- Sipariş tipi seçimi
    local orderTypes = {}
    for type, data in pairs(Config.NPCCustomers.orderTypes) do
        table.insert(orderTypes, {type = type, data = data})
    end
    local selectedOrder = orderTypes[math.random(#orderTypes)]

    -- Silah tipi seçimi
    local weaponType = customerData.preferredWeapons[math.random(#customerData.preferredWeapons)]
    
    -- Miktar belirleme
    local quantity = math.random(selectedOrder.data.minQuantity, selectedOrder.data.maxQuantity)
    
    -- Buluşma noktası seçimi
    local meetingPoints = Config.NPCCustomers.meetingPoints
    local meetingType = math.random() > 0.5 and "safe" or (math.random() > 0.5 and "moderate" or "dangerous")
    local meetingPoint = meetingPoints[meetingType].locations[math.random(#meetingPoints[meetingType].locations)]

    -- NPC verilerini oluşturma
    local npcData = {
        id = #activeNPCs + 1,
        type = customerType,
        model = customerData.models[math.random(#customerData.models)],
        weaponType = weaponType,
        quantity = quantity,
        meetingPoint = meetingPoint,
        risk = meetingPoints[meetingType].risk,
        priceMultiplier = customerData.priceMultiplier * selectedOrder.data.priceMultiplier
    }

    -- Aktif NPC listesine ekleme
    table.insert(activeNPCs, npcData)

    -- Tüm oyunculara yeni müşteri bilgisi gönderme
    TriggerClientEvent('qb-weapondealer:client:NewCustomerAvailable', -1, npcData)
end

-- Düzenli NPC oluşturma
CreateThread(function()
    while true do
        CreateNPCCustomer()
        Wait(Config.NPCCustomers.spawnInterval * 60 * 1000)
    end
end)

-- NPC Siparişi kabul etme
RegisterNetEvent('qb-weapondealer:server:AcceptNPCOrder', function(npcId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- NPC kontrolü
    local npc = nil
    for i, npcData in ipairs(activeNPCs) do
        if npcData.id == npcId then
            npc = npcData
            table.remove(activeNPCs, i)
            break
        end
    end

    if not npc then
        TriggerClientEvent('QBCore:Notify', src, 'Bu müşteri artık mevcut değil!', 'error')
        return
    end

    -- İtibar kontrolü
    local playerData = MySQL.query.await('SELECT reputation FROM weapon_dealers WHERE citizenid = ?', {Player.PlayerData.citizenid})
    if not playerData[1] or playerData[1].reputation < Config.NPCCustomers.customerTypes[npc.type].reputationRequirement then
        TriggerClientEvent('QBCore:Notify', src, 'Bu müşteriyle iş yapmak için yeterli itibarınız yok!', 'error')
        return
    end

    -- Sipariş oluşturma
    local basePrice = Config.WeaponParts[npc.weaponType].basePrice
    local totalPrice = math.floor(basePrice * npc.quantity * npc.priceMultiplier)
    
    local orderId = CreateOrder(Player.PlayerData.citizenid, 'npc_'..npc.id, npc.weaponType, npc.quantity, totalPrice)
    if orderId then
        -- Siparişi aktif NPC siparişlerine ekleme
        activeNPCOrders[orderId] = npc
        
        -- Client'a bilgi gönderme
        TriggerClientEvent('qb-weapondealer:client:NPCOrderAccepted', src, {
            orderId = orderId,
            npcData = npc,
            totalPrice = totalPrice
        })
    end
end)

-- NPC Siparişi tamamlama
RegisterNetEvent('qb-weapondealer:server:CompleteNPCOrder', function(orderId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local npcOrder = activeNPCOrders[orderId]
    if not npcOrder then
        TriggerClientEvent('QBCore:Notify', src, 'Bu sipariş artık mevcut değil!', 'error')
        return
    end

    -- Envanter kontrolü
    if not CheckInventory(Player.PlayerData.citizenid, npcOrder.weaponType, npcOrder.quantity) then
        TriggerClientEvent('QBCore:Notify', src, 'Yeterli silah yok!', 'error')
        return
    end

    -- Ödeme ve envanter güncelleme
    local totalPrice = math.floor(Config.WeaponParts[npcOrder.weaponType].basePrice * npcOrder.quantity * npcOrder.priceMultiplier)
    Player.Functions.AddMoney('cash', totalPrice)
    
    -- Envanter güncelleme
    UpdateInventory(Player.PlayerData.citizenid, npcOrder.weaponType, -npcOrder.quantity, 0)
    
    -- Sipariş durumu güncelleme
    UpdateOrderStatus(orderId, 'completed')
    activeNPCOrders[orderId] = nil

    -- İtibar puanı ekleme
    local repBonus = npcOrder.risk == 'high' and 50 or npcOrder.risk == 'medium' and 30 or 15
    UpdateReputation(Player.PlayerData.citizenid, repBonus)

    -- Client'a bilgi gönderme
    TriggerClientEvent('QBCore:Notify', src, string.format('Sipariş tamamlandı! Kazanç: $%s', totalPrice), 'success')
    TriggerClientEvent('qb-weapondealer:client:NPCOrderCompleted', src, orderId)
end)

-- Malzeme kontrolü için callback
QBCore.Functions.CreateCallback('qb-weapondealer:server:CheckMaterials', function(source, cb, weaponType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return cb(false) end

    local weaponData = Config.WeaponParts[weaponType]
    local hasAllMaterials = true
    local missingMaterials = {}

    -- Her malzemeyi kontrol et
    for material, amount in pairs(weaponData.materials) do
        local item = Player.Functions.GetItemByName(material)
        if not item or item.amount < amount then
            hasAllMaterials = false
            missingMaterials[material] = {
                required = amount,
                has = item and item.amount or 0
            }
        end
    end

    cb(hasAllMaterials, missingMaterials)
end)

-- Malzemeleri kullanma
RegisterNetEvent('qb-weapondealer:server:UseMaterials', function(weaponType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local weaponData = Config.WeaponParts[weaponType]
    
    -- Üretim maliyeti kontrolü
    local productionCost = weaponData.basePrice
    if Player.Functions.GetMoney('cash') < productionCost then
        TriggerClientEvent('QBCore:Notify', src, string.format('Üretim için yeterli paranız yok! Gereken: $%s', productionCost), 'error')
        return
    end
    
    -- Parayı al
    Player.Functions.RemoveMoney('cash', productionCost, "weapon-production-cost")
    TriggerClientEvent('QBCore:Notify', src, string.format('Üretim maliyeti: $%s', productionCost), 'info')
    
    -- Malzemeleri kullan
    for material, amount in pairs(weaponData.materials) do
        Player.Functions.RemoveItem(material, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[material], "remove")
    end
end)

-- Export fonksiyonları
exports('UpdateReputation', UpdateReputation)
exports('CheckInventory', CheckInventory)
exports('CreateOrder', CreateOrder)
exports('UpdateOrderStatus', UpdateOrderStatus)
exports('UpdateInventory', UpdateInventory)

-- Envanter callback'i
QBCore.Functions.CreateCallback('qb-weapondealer:server:GetInventory', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(false) end

    MySQL.query('SELECT * FROM weapon_inventory WHERE dealer_id = ?', {Player.PlayerData.citizenid}, function(result)
        if result then
            cb(result)
        else
            cb(false)
        end
    end)
end)

-- Siparişler callback'i
QBCore.Functions.CreateCallback('qb-weapondealer:server:GetOrders', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(false) end

    MySQL.query('SELECT * FROM weapon_orders WHERE dealer_id = ? AND status != ?', 
        {Player.PlayerData.citizenid, 'completed'}, function(result)
        if result then
            cb(result)
        else
            cb(false)
        end
    end)
end) 