local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local isLoggedIn = false

-- Temel Değişkenler
local currentWorkshop = nil
local currentStorage = nil
local isCrafting = false
local deliveryBlip = nil

-- NPC Müşteri Sistemi
local activeNPCs = {}
local currentNPC = nil
local deliveryPed = nil

-- Silah Kaçakçısı Başlatma
function InitializeWeaponDealer()
    if not isLoggedIn then return end
    
    -- Blipleri oluştur
    CreateLocationBlips()
    
    -- Target sistemini başlat
    if Config.UseTarget then
        InitializeTargetSystem()
    end
end

-- Target Sistemi Başlatma
function InitializeTargetSystem()
    for locationType, locations in pairs(Config.Locations) do
        for _, location in pairs(locations) do
            exports['qb-target']:AddBoxZone(
                "weapondealer_"..locationType.."_".._, 
                vector3(location.coords.x, location.coords.y, location.coords.z),
                2.0, 2.0, {
                    name = "weapondealer_"..locationType.."_".._, 
                    heading = location.coords.w,
                    debugPoly = Config.Debug,
                    minZ = location.coords.z - 1,
                    maxZ = location.coords.z + 1,
                }, {
                    options = {
                        {
                            type = "client",
                            event = locationType == "workshop" and "qb-weapondealer:client:OpenCraftingMenu" or "qb-weapondealer:client:OpenStorageMenu",
                            icon = locationType == "workshop" and "fas fa-tools" or "fas fa-box",
                            label = locationType == "workshop" and "Üretim Menüsü" or "Depo Menüsü",
                        },
                    },
                    distance = 2.5
                }
            )
        end
    end
end

-- Event Handlers
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    isLoggedIn = true
    InitializeWeaponDealer()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

-- Lokasyon Bliplerini Oluşturma
function CreateLocationBlips()
    for locationType, locations in pairs(Config.Locations) do
        for _, location in pairs(locations) do
            if location.blipSettings.display then
                local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
                SetBlipSprite(blip, location.blipSettings.sprite)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, location.blipSettings.scale)
                SetBlipColour(blip, location.blipSettings.color)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(location.label)
                EndTextCommandSetBlipName(blip)
            end
        end
    end
end

-- Silah Üretim Menüsü
function OpenCraftingMenu()
    local craftingMenu = {
        {
            header = "Silah Üretim Menüsü",
            isMenuHeader = true
        }
    }

    for weaponType, weaponData in pairs(Config.WeaponParts) do
        local materialText = "Gereken Malzemeler:\\n"
        for material, amount in pairs(weaponData.materials) do
            materialText = materialText .. "- " .. material .. ": " .. amount .. "\\n"
        end

        craftingMenu[#craftingMenu + 1] = {
            header = weaponData.label .. " (" .. weaponData.basePrice .. "$)",
            txt = materialText .. 
                  "\\nÜretim Süresi: " .. weaponData.craftTime .. " saniye" ..
                  "\\n\\nKalite Şansları:" ..
                  "\\nMükemmel: %" .. Config.QualitySystem.baseQualityChance.perfect ..
                  "\\nİyi: %" .. Config.QualitySystem.baseQualityChance.good ..
                  "\\nNormal: %" .. Config.QualitySystem.baseQualityChance.normal ..
                  "\\nKötü: %" .. Config.QualitySystem.baseQualityChance.poor,
            params = {
                event = "qb-weapondealer:client:StartCrafting",
                args = {
                    weaponType = weaponType,
                    craftTime = weaponData.craftTime
                }
            }
        }
    end

    -- İstatistik Menüsü
    craftingMenu[#craftingMenu + 1] = {
        header = "🏆 Üretim İstatistikleri",
        txt = "İtibar ve başarı istatistiklerinizi görüntüleyin",
        params = {
            event = "qb-weapondealer:client:ViewStats"
        }
    }

    exports['qb-menu']:openMenu(craftingMenu)
end

-- İstatistik Görüntüleme
RegisterNetEvent('qb-weapondealer:client:ViewStats', function()
    QBCore.Functions.TriggerCallback('qb-weapondealer:server:GetPlayerStats', function(stats)
        if stats then
            local statsMenu = {
                {
                    header = "Üretim İstatistikleri",
                    isMenuHeader = true
                },
                {
                    header = "İtibar Seviyesi",
                    txt = "Seviye: " .. stats.reputation .. "\n" ..
                          "Toplam Satış: " .. stats.total_sales .. "\n" ..
                          "Atölye Seviyesi: " .. stats.workshop_level
                },
                {
                    header = "⬅️ Geri",
                    params = {
                        event = "qb-weapondealer:client:OpenCraftingMenu"
                    }
                }
            }
            exports['qb-menu']:openMenu(statsMenu)
        end
    end)
end)

-- Silah Üretim Başlatma
RegisterNetEvent('qb-weapondealer:client:StartCrafting', function(data)
    if isCrafting then
        QBCore.Functions.Notify("Zaten üretim yapıyorsunuz!", "error")
        return
    end

    local weaponType = data.weaponType
    local craftTime = data.craftTime

    -- Malzeme kontrolü
    QBCore.Functions.TriggerCallback('qb-weapondealer:server:CheckMaterials', function(hasRequired, missingMaterials)
        if hasRequired then
            -- Üretimi başlat
            isCrafting = true
            
            -- Malzemeleri kullan
            TriggerServerEvent('qb-weapondealer:server:UseMaterials', weaponType)
            
            -- Progress bar
            QBCore.Functions.Progressbar("crafting_weapon", "Silah üretiliyor...", craftTime * 1000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = "mini@repair",
                anim = "fixing_a_ped",
                flags = 16,
            }, {}, {}, function() -- Done
                isCrafting = false
                TriggerServerEvent('qb-weapondealer:server:FinishCrafting', weaponType)
                QBCore.Functions.Notify("Silah üretimi tamamlandı!", "success")
            end, function() -- Cancel
                isCrafting = false
                QBCore.Functions.Notify("Üretim iptal edildi!", "error")
            end)
        else
            -- Eksik malzemeleri göster
            local missingText = "Eksik Malzemeler:\\n"
            for material, data in pairs(missingMaterials) do
                missingText = missingText .. material .. ": " .. data.has .. "/" .. data.required .. "\\n"
            end
            QBCore.Functions.Notify(missingText, "error", 5000)
        end
    end, weaponType)
end)

-- Depo Menüsü
function OpenStorageMenu()
    local storageMenu = {
        {
            header = "Silah Deposu",
            isMenuHeader = true
        }
    }

    -- Envanter menüsü
    storageMenu[#storageMenu + 1] = {
        header = "📦 Envanter",
        txt = "Mevcut silahları görüntüle",
        params = {
            event = "qb-weapondealer:client:ViewInventory"
        }
    }

    -- Siparişler menüsü
    storageMenu[#storageMenu + 1] = {
        header = "📋 Siparişler",
        txt = "Aktif siparişleri görüntüle",
        params = {
            event = "qb-weapondealer:client:ViewOrders"
        }
    }

    -- Menüyü kapat
    storageMenu[#storageMenu + 1] = {
        header = "❌ Kapat",
        txt = "",
        params = {
            event = "qb-menu:client:closeMenu"
        }
    }

    exports['qb-menu']:openMenu(storageMenu)
end

-- Envanter Görüntüleme
RegisterNetEvent('qb-weapondealer:client:ViewInventory', function()
    QBCore.Functions.TriggerCallback('qb-weapondealer:server:GetInventory', function(inventory)
        if not inventory then 
            QBCore.Functions.Notify('Envanter yüklenemedi!', 'error')
            return 
        end

        local inventoryMenu = {
            {
                header = "Silah Envanteri",
                isMenuHeader = true
            }
        }

        if #inventory == 0 then
            inventoryMenu[#inventoryMenu + 1] = {
                header = "Boş Envanter",
                txt = "Envanterinizde hiç silah yok",
                params = {
                    event = "qb-weapondealer:client:OpenStorageMenu"
                }
            }
        else
            for _, item in pairs(inventory) do
                inventoryMenu[#inventoryMenu + 1] = {
                    header = QBCore.Shared.Items[item.item_type].label,
                    txt = string.format("Miktar: %d | Kalite: %s | Üretim: %s", 
                        item.quantity, 
                        item.quality,
                        item.created_at
                    ),
                    params = {
                        event = "qb-weapondealer:client:ViewItemDetails",
                        args = item
                    }
                }
            end
        end

        -- Geri dön butonu
        inventoryMenu[#inventoryMenu + 1] = {
            header = "⬅️ Geri",
            txt = "",
            params = {
                event = "qb-weapondealer:client:OpenStorageMenu"
            }
        }

        exports['qb-menu']:openMenu(inventoryMenu)
    end)
end)

-- Siparişleri Görüntüleme
RegisterNetEvent('qb-weapondealer:client:ViewOrders', function()
    QBCore.Functions.TriggerCallback('qb-weapondealer:server:GetOrders', function(orders)
        if not orders then 
            QBCore.Functions.Notify('Siparişler yüklenemedi!', 'error')
            return 
        end

        local ordersMenu = {
            {
                header = "Aktif Siparişler",
                isMenuHeader = true
            }
        }

        if #orders == 0 then
            ordersMenu[#ordersMenu + 1] = {
                header = "Sipariş Yok",
                txt = "Aktif siparişiniz bulunmuyor",
                params = {
                    event = "qb-weapondealer:client:OpenStorageMenu"
                }
            }
        else
            for _, order in pairs(orders) do
                ordersMenu[#ordersMenu + 1] = {
                    header = string.format("Sipariş #%d", order.id),
                    txt = string.format("Silah: %s | Miktar: %d | Fiyat: $%d | Durum: %s", 
                        QBCore.Shared.Items[order.weapon_type].label,
                        order.quantity,
                        order.price,
                        order.status
                    ),
                    params = {
                        event = "qb-weapondealer:client:ViewOrderDetails",
                        args = order
                    }
                }
            end
        end

        -- Geri dön butonu
        ordersMenu[#ordersMenu + 1] = {
            header = "⬅️ Geri",
            txt = "",
            params = {
                event = "qb-weapondealer:client:OpenStorageMenu"
            }
        }

        exports['qb-menu']:openMenu(ordersMenu)
    end)
end)

-- Depo menüsünü açma eventi
RegisterNetEvent('qb-weapondealer:client:OpenStorageMenu', function()
    OpenStorageMenu()
end)

-- Yeni NPC Müşteri geldiğinde
RegisterNetEvent('qb-weapondealer:client:NewCustomerAvailable', function(npcData)
    -- NPC'yi aktif listeye ekleme
    activeNPCs[npcData.id] = npcData
    
    -- Bildirim gönderme
    QBCore.Functions.Notify('Yeni bir müşteri mevcut! GPS\'te işaretlendi.', 'info')
    
    -- NPC'yi haritada gösterme
    local customerBlip = AddBlipForCoord(npcData.meetingPoint.x, npcData.meetingPoint.y, npcData.meetingPoint.z)
    SetBlipSprite(customerBlip, 280)
    SetBlipDisplay(customerBlip, 4)
    SetBlipScale(customerBlip, 0.8)
    SetBlipColour(customerBlip, npcData.risk == 'high' and 1 or npcData.risk == 'medium' and 5 or 2)
    SetBlipAsShortRange(customerBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Potansiyel Müşteri")
    EndTextCommandSetBlipName(customerBlip)
    
    -- Blip referansını kaydetme
    npcData.blip = customerBlip
end)

-- NPC ile etkileşim
function InteractWithNPC(npcId)
    local npcData = activeNPCs[npcId]
    if not npcData then return end

    local customerType = Config.NPCCustomers.customerTypes[npcData.type]
    
    local interactionMenu = {
        {
            header = customerType.label,
            isMenuHeader = true
        },
        {
            header = "📋 Sipariş Detayları",
            txt = string.format("Silah: %s\nMiktar: %d\nRisk: %s",
                Config.WeaponParts[npcData.weaponType].label,
                npcData.quantity,
                npcData.risk == 'high' and 'Yüksek' or npcData.risk == 'medium' and 'Orta' or 'Düşük'
            )
        },
        {
            header = "💰 Teklif",
            txt = string.format("Birim Fiyat: $%d\nToplam: $%d",
                math.floor(Config.WeaponParts[npcData.weaponType].basePrice * npcData.priceMultiplier),
                math.floor(Config.WeaponParts[npcData.weaponType].basePrice * npcData.quantity * npcData.priceMultiplier)
            )
        },
        {
            header = "✅ Siparişi Kabul Et",
            params = {
                event = "qb-weapondealer:client:AcceptNPCOrder",
                args = npcId
            }
        },
        {
            header = "❌ Reddet",
            params = {
                event = "qb-weapondealer:client:RejectNPCOrder",
                args = npcId
            }
        }
    }
    
    exports['qb-menu']:openMenu(interactionMenu)
end

-- NPC Sipariş kabul etme
RegisterNetEvent('qb-weapondealer:client:AcceptNPCOrder', function(npcId)
    TriggerServerEvent('qb-weapondealer:server:AcceptNPCOrder', npcId)
end)

-- NPC Sipariş reddetme
RegisterNetEvent('qb-weapondealer:client:RejectNPCOrder', function(npcId)
    local npcData = activeNPCs[npcId]
    if not npcData then return end
    
    -- Blip'i kaldırma
    if npcData.blip then
        RemoveBlip(npcData.blip)
    end
    
    -- NPC'yi listeden kaldırma
    activeNPCs[npcId] = nil
    
    QBCore.Functions.Notify('Sipariş reddedildi.', 'info')
end)

-- NPC Sipariş kabul edildiğinde
RegisterNetEvent('qb-weapondealer:client:NPCOrderAccepted', function(orderData)
    local npcData = orderData.npcData
    currentNPC = npcData
    
    -- Eski blip'i kaldırma
    if npcData.blip then
        RemoveBlip(npcData.blip)
    end
    
    -- Teslimat noktası blip'i oluşturma
    deliveryBlip = AddBlipForCoord(npcData.meetingPoint.x, npcData.meetingPoint.y, npcData.meetingPoint.z)
    SetBlipSprite(deliveryBlip, 501)
    SetBlipDisplay(deliveryBlip, 4)
    SetBlipScale(deliveryBlip, 1.0)
    SetBlipColour(deliveryBlip, 5)
    SetBlipAsShortRange(deliveryBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Teslimat Noktası")
    EndTextCommandSetBlipName(deliveryBlip)
    
    -- NPC oluşturma
    local model = GetHashKey(npcData.model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
    
    deliveryPed = CreatePed(4, model, npcData.meetingPoint.x, npcData.meetingPoint.y, npcData.meetingPoint.z - 1.0, npcData.meetingPoint.w, false, true)
    SetEntityAsMissionEntity(deliveryPed, true, true)
    SetBlockingOfNonTemporaryEvents(deliveryPed, true)
    SetPedDiesWhenInjured(deliveryPed, false)
    SetPedCanPlayAmbientAnims(deliveryPed, true)
    SetPedCanRagdollFromPlayerImpact(deliveryPed, false)
    SetEntityInvincible(deliveryPed, true)
    FreezeEntityPosition(deliveryPed, true)
    
    -- Target ekleme
    exports['qb-target']:AddTargetEntity(deliveryPed, {
        options = {
            {
                type = "client",
                event = "qb-weapondealer:client:DeliverToNPC",
                icon = "fas fa-handshake",
                label = "Teslimatı Yap",
                orderId = orderData.orderId
            }
        },
        distance = 2.0
    })
    
    QBCore.Functions.Notify('Teslimat noktası GPS\'te işaretlendi.', 'success')
end)

-- NPC'ye teslimat yapma
RegisterNetEvent('qb-weapondealer:client:DeliverToNPC', function(data)
    local orderId = data.orderId
    TriggerServerEvent('qb-weapondealer:server:CompleteNPCOrder', orderId)
end)

-- Teslimat tamamlandığında
RegisterNetEvent('qb-weapondealer:client:NPCOrderCompleted', function(orderId)
    -- Blip'i kaldırma
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
        deliveryBlip = nil
    end
    
    -- NPC'yi kaldırma
    if deliveryPed then
        DeleteEntity(deliveryPed)
        deliveryPed = nil
    end
    
    currentNPC = nil
end) 