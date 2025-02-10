local QBCore = exports['qb-core']:GetCoreObject()

-- Teslimat Değişkenleri
local isOnDelivery = false
local currentRoute = nil
local currentCheckpoint = 1
local deliveryVehicle = nil
local currentHeatLevel = 1
local isBeingFollowed = false
local escapeBlip = nil
local checkpointBlip = nil

-- Teslimat başlatma
RegisterNetEvent('qb-weapondealer:client:StartDelivery', function(routeType, vehicleType)
    if isOnDelivery then return end
    
    -- Rota seçimi
    currentRoute = Config.DeliverySystem.routes[routeType]
    if not currentRoute then return end
    
    -- Araç spawn etme
    local vehicleData = Config.DeliverySystem.vehicleTypes[vehicleType]
    local model = vehicleData.models[math.random(#vehicleData.models)]
    local coords = GetEntityCoords(PlayerPedId())
    
    QBCore.Functions.SpawnVehicle(model, function(vehicle)
        SetEntityHeading(vehicle, coords.w)
        exports['LegacyFuel']:SetFuel(vehicle, 100.0)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(vehicle))
        SetVehicleEngineOn(vehicle, true, true)
        deliveryVehicle = vehicle
        
        -- İlk checkpoint'i ayarlama
        SetupCheckpoint()
    end, coords, true)
    
    isOnDelivery = true
    currentHeatLevel = 1
    StartDeliveryThread()
end)

-- Checkpoint ayarlama
function SetupCheckpoint()
    if checkpointBlip then RemoveBlip(checkpointBlip) end
    
    local checkpoint = currentRoute.checkpoints[currentCheckpoint]
    checkpointBlip = AddBlipForCoord(checkpoint.coords.x, checkpoint.coords.y, checkpoint.coords.z)
    SetBlipSprite(checkpointBlip, 1)
    SetBlipDisplay(checkpointBlip, 4)
    SetBlipScale(checkpointBlip, 1.0)
    SetBlipColour(checkpointBlip, 5)
    SetBlipRoute(checkpointBlip, true)
    
    -- Checkpoint tipine göre bildirim
    if checkpoint.type == "wait" then
        QBCore.Functions.Notify('Bekleme noktasına ulaştın. ' .. checkpoint.time .. ' saniye bekle.', 'info')
    elseif checkpoint.type == "swap" then
        QBCore.Functions.Notify('Araç değiştirme noktasına ulaştın.', 'info')
    end
end

-- Teslimat thread'i
function StartDeliveryThread()
    CreateThread(function()
        while isOnDelivery do
            local sleep = 1000
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            
            -- Checkpoint kontrol
            if currentRoute and currentCheckpoint <= #currentRoute.checkpoints then
                local checkpoint = currentRoute.checkpoints[currentCheckpoint]
                local distance = #(coords - checkpoint.coords)
                
                if distance < 5.0 then
                    sleep = 0
                    if checkpoint.type == "wait" then
                        HandleWaitCheckpoint(checkpoint)
                    elseif checkpoint.type == "swap" then
                        HandleSwapCheckpoint()
                    else
                        HandleDriveCheckpoint()
                    end
                end
            end
            
            -- Polis takip kontrolü
            if not isBeingFollowed then
                local policeNearby = IsPoliceNearby()
                if policeNearby then
                    TriggerPoliceAlert()
                end
            end
            
            Wait(sleep)
        end
    end)
end

-- Polis yakınlık kontrolü
function IsPoliceNearby()
    local players = QBCore.Functions.GetPlayers()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    for _, player in ipairs(players) do
        local targetPed = GetPlayerPed(player)
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(coords - targetCoords)
        
        if distance < Config.DeliverySystem.policeAlert.maxDistance then
            local targetJob = QBCore.Functions.GetPlayerData(player).job.name
            if Config.DeliverySystem.policeAlert.jobs[targetJob] then
                return true
            end
        end
    end
    return false
end

-- Polis alarmı tetikleme
function TriggerPoliceAlert()
    isBeingFollowed = true
    currentHeatLevel = math.min(currentHeatLevel + Config.DeliverySystem.heatSystem.increment, Config.DeliverySystem.heatSystem.maxLevel)
    
    -- Kaçış noktası gösterme
    local escapePoint = GetNearestEscapePoint()
    if escapePoint then
        if escapeBlip then RemoveBlip(escapeBlip) end
        escapeBlip = AddBlipForCoord(escapePoint.x, escapePoint.y, escapePoint.z)
        SetBlipSprite(escapeBlip, 358)
        SetBlipColour(escapeBlip, 1)
        SetBlipRoute(escapeBlip, true)
        QBCore.Functions.Notify('Polis seni fark etti! En yakın kaçış noktasına git!', 'error')
    end
    
    -- Server'a bildirim gönderme
    TriggerServerEvent('qb-weapondealer:server:PoliceAlert', currentHeatLevel)
end

-- En yakın kaçış noktasını bulma
function GetNearestEscapePoint()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearestDist = 999999.9
    local nearestPoint = nil
    
    for _, escapeType in pairs(Config.DeliverySystem.escapePoints) do
        for _, point in ipairs(escapeType.coords) do
            local dist = #(playerCoords - vector3(point.x, point.y, point.z))
            if dist < nearestDist then
                nearestDist = dist
                nearestPoint = point
            end
        end
    end
    
    return nearestPoint
end

-- Checkpoint işleyicileri
function HandleWaitCheckpoint(checkpoint)
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        QBCore.Functions.Progressbar("delivery_wait", "Bekleniyor...", checkpoint.time * 1000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done
            currentCheckpoint = currentCheckpoint + 1
            if currentCheckpoint <= #currentRoute.checkpoints then
                SetupCheckpoint()
            else
                FinishDelivery(true)
            end
        end)
    end
end

function HandleSwapCheckpoint()
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        local oldVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        QBCore.Functions.DeleteVehicle(oldVehicle)
        
        -- Yeni araç spawn etme
        local vehicleType = currentHeatLevel > 1 and "fast" or "stealth"
        local vehicleData = Config.DeliverySystem.vehicleTypes[vehicleType]
        local model = vehicleData.models[math.random(#vehicleData.models)]
        local coords = GetEntityCoords(PlayerPedId())
        
        QBCore.Functions.SpawnVehicle(model, function(vehicle)
            SetEntityHeading(vehicle, coords.w)
            exports['LegacyFuel']:SetFuel(vehicle, 100.0)
            TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(vehicle))
            SetVehicleEngineOn(vehicle, true, true)
            deliveryVehicle = vehicle
            
            currentCheckpoint = currentCheckpoint + 1
            if currentCheckpoint <= #currentRoute.checkpoints then
                SetupCheckpoint()
            else
                FinishDelivery(true)
            end
        end, coords, true)
    end
end

function HandleDriveCheckpoint()
    currentCheckpoint = currentCheckpoint + 1
    if currentCheckpoint <= #currentRoute.checkpoints then
        SetupCheckpoint()
    else
        FinishDelivery(true)
    end
end

-- Teslimat bitirme
function FinishDelivery(success)
    if success then
        QBCore.Functions.Notify('Teslimat başarıyla tamamlandı!', 'success')
    else
        QBCore.Functions.Notify('Teslimat başarısız oldu!', 'error')
    end
    
    -- Temizlik
    if deliveryVehicle then
        QBCore.Functions.DeleteVehicle(deliveryVehicle)
    end
    
    if checkpointBlip then RemoveBlip(checkpointBlip) end
    if escapeBlip then RemoveBlip(escapeBlip) end
    
    isOnDelivery = false
    currentRoute = nil
    currentCheckpoint = 1
    deliveryVehicle = nil
    isBeingFollowed = false
    
    TriggerServerEvent('qb-weapondealer:server:FinishDelivery', success)
end

-- Event handler'lar
RegisterNetEvent('qb-weapondealer:client:DeliveryFailed', function()
    FinishDelivery(false)
end)

-- Araç hasar kontrolü
CreateThread(function()
    while true do
        Wait(1000)
        if isOnDelivery and deliveryVehicle then
            if GetVehicleEngineHealth(deliveryVehicle) < 200.0 then
                QBCore.Functions.Notify('Araç çok hasar aldı! Teslimat başarısız!', 'error')
                FinishDelivery(false)
            end
        end
    end
end) 