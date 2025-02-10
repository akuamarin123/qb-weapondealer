Config = {}

-- Genel Ayarlar
Config.Debug = false
Config.UseTarget = true -- false = 3D Text, true = qb-target

-- Kalite Sistemi Ayarları
Config.QualitySystem = {
    minQuality = 1,
    maxQuality = 100,
    baseQualityChance = {
        perfect = 5,  -- %5 mükemmel kalite şansı
        good = 15,    -- %15 iyi kalite şansı
        normal = 60,  -- %60 normal kalite şansı
        poor = 20     -- %20 kötü kalite şansı
    },
    qualityMultipliers = {
        perfect = 2.0,  -- Fiyat 2 katı
        good = 1.5,     -- Fiyat 1.5 katı
        normal = 1.0,   -- Normal fiyat
        poor = 0.7      -- Fiyat %30 düşük
    },
    skillEffect = {
        reputationBonus = 0.5,  -- Her itibar seviyesi için %0.5 kalite artışı
        workshopBonus = 1.0     -- Her atölye seviyesi için %1 kalite artışı
    }
}

-- Lokasyonlar
Config.Locations = {
    ["workshop"] = {
        [1] = {
            coords = vector4(1275.89, -1710.71, 54.77, 297.25),
            label = "Silah Atölyesi 1",
            isPrivate = true,
            blipSettings = {
                sprite = 150,
                color = 1,
                scale = 0.8,
                display = false -- Haritada gözükmemesi için
            }
        },
    },
    ["storage"] = {
        [1] = {
            coords = vector4(892.37, -2172.45, 32.28, 174.89),
            label = "Depo 1",
            isPrivate = true,
            blipSettings = {
                sprite = 473,
                color = 1,
                scale = 0.8,
                display = false
            }
        },
    }
}

-- Silah Parçaları ve Gereken Malzemeler
Config.WeaponParts = {
    ["pistol"] = {
        label = "Tabanca",
        craftTime = 120, -- saniye
        basePrice = 15000, -- Temel fiyat
        materials = {
            ["steel"] = 15,
            ["aluminum"] = 10,
            ["plastic"] = 5,
            ["metalscrap"] = 8
        },
        qualityCheck = {
            perfect = {
                durability = 100,
                accuracy = 95,
                recoil = 5
            },
            good = {
                durability = 85,
                accuracy = 80,
                recoil = 15
            },
            normal = {
                durability = 70,
                accuracy = 65,
                recoil = 30
            },
            poor = {
                durability = 50,
                accuracy = 45,
                recoil = 50
            }
        }
    },
    ["smg"] = {
        label = "Hafif Makineli",
        craftTime = 240,
        basePrice = 25000,
        materials = {
            ["steel"] = 25,
            ["aluminum"] = 15,
            ["plastic"] = 10,
            ["metalscrap"] = 12
        },
        qualityCheck = {
            perfect = {
                durability = 100,
                accuracy = 90,
                recoil = 10
            },
            good = {
                durability = 85,
                accuracy = 75,
                recoil = 20
            },
            normal = {
                durability = 70,
                accuracy = 60,
                recoil = 35
            },
            poor = {
                durability = 50,
                accuracy = 40,
                recoil = 55
            }
        }
    },
    ["pistol_ammo"] = {
        label = "Tabanca Mermisi",
        craftTime = 30,
        basePrice = 500,
        materials = {
            ["steel"] = 2,
            ["metalscrap"] = 1,
            ["gunpowder"] = 1
        },
        qualityCheck = {
            perfect = {
                durability = 100,
                accuracy = 95,
                damage = 100
            },
            good = {
                durability = 85,
                accuracy = 80,
                damage = 90
            },
            normal = {
                durability = 70,
                accuracy = 65,
                damage = 80
            },
            poor = {
                durability = 50,
                accuracy = 45,
                damage = 70
            }
        }
    },
    ["smg_ammo"] = {
        label = "Hafif Makineli Mermisi",
        craftTime = 45,
        basePrice = 750,
        materials = {
            ["steel"] = 3,
            ["metalscrap"] = 2,
            ["gunpowder"] = 2
        },
        qualityCheck = {
            perfect = {
                durability = 100,
                accuracy = 95,
                damage = 100
            },
            good = {
                durability = 85,
                accuracy = 80,
                damage = 90
            },
            normal = {
                durability = 70,
                accuracy = 65,
                damage = 80
            },
            poor = {
                durability = 50,
                accuracy = 45,
                damage = 70
            }
        }
    }
}

-- İtibar Seviyeleri
Config.ReputationLevels = {
    [1] = {
        label = "Acemi Kaçakçı",
        minRep = 0,
        maxRep = 1000,
        benefits = {
            priceMultiplier = 1.0,
            maxOrder = 2
        }
    },
    [2] = {
        label = "Tecrübeli Kaçakçı",
        minRep = 1001,
        maxRep = 3000,
        benefits = {
            priceMultiplier = 1.2,
            maxOrder = 4
        }
    },
    [3] = {
        label = "Usta Kaçakçı",
        minRep = 3001,
        maxRep = 6000,
        benefits = {
            priceMultiplier = 1.4,
            maxOrder = 6
        }
    }
}

-- Risk Seviyeleri
Config.RiskLevels = {
    low = {
        policeAlertChance = 10,
        minPoliceCount = 0,
        payment = 1.0
    },
    medium = {
        policeAlertChance = 35,
        minPoliceCount = 2,
        payment = 1.5
    },
    high = {
        policeAlertChance = 65,
        minPoliceCount = 4,
        payment = 2.0
    }
}

-- NPC Müşteri Sistemi
Config.NPCCustomers = {
    spawnInterval = 30, -- Yeni müşteri gelme süresi (dakika)
    maxActiveOrders = 5, -- Aynı anda maksimum aktif sipariş
    customerTypes = {
        ["gang"] = {
            label = "Çete Üyesi",
            models = {"g_m_y_ballasout_01", "g_m_y_famca_01", "g_m_y_mexgoon_01"},
            orderChance = 70, -- Sipariş verme şansı
            priceMultiplier = 1.2, -- Ödeme çarpanı
            preferredWeapons = {"pistol", "smg"},
            reputationRequirement = 0,
            locations = {
                vector4(1212.34, -1234.56, 45.67, 180.0),
                vector4(1432.12, -2345.67, 34.56, 90.0),
                vector4(2345.67, -1234.56, 23.45, 270.0)
            }
        },
        ["professional"] = {
            label = "Profesyonel Müşteri",
            models = {"cs_bankman", "cs_barry", "cs_brad"},
            orderChance = 40,
            priceMultiplier = 1.5,
            preferredWeapons = {"pistol"},
            reputationRequirement = 1000,
            locations = {
                vector4(2345.67, -3456.78, 56.78, 0.0),
                vector4(3456.78, -2345.67, 45.67, 180.0)
            }
        },
        ["kingpin"] = {
            label = "Mafya Babası",
            models = {"cs_solomon", "cs_tom", "cs_vincent"},
            orderChance = 20,
            priceMultiplier = 2.0,
            preferredWeapons = {"pistol", "smg"},
            reputationRequirement = 3000,
            locations = {
                vector4(4567.89, -5678.90, 67.89, 90.0),
                vector4(5678.90, -4567.89, 78.90, 270.0)
            }
        }
    },
    meetingPoints = {
        ["safe"] = {
            label = "Güvenli Bölge",
            risk = "low",
            locations = {
                vector4(1234.56, -2345.67, 34.56, 0.0),
                vector4(2345.67, -3456.78, 45.67, 90.0)
            }
        },
        ["moderate"] = {
            label = "Orta Riskli Bölge",
            risk = "medium",
            locations = {
                vector4(3456.78, -4567.89, 56.78, 180.0),
                vector4(4567.89, -5678.90, 67.89, 270.0)
            }
        },
        ["dangerous"] = {
            label = "Tehlikeli Bölge",
            risk = "high",
            locations = {
                vector4(5678.90, -6789.01, 78.90, 0.0),
                vector4(6789.01, -7890.12, 89.01, 90.0)
            }
        }
    },
    orderTypes = {
        ["small"] = {
            label = "Küçük Sipariş",
            minQuantity = 1,
            maxQuantity = 2,
            priceMultiplier = 1.0
        },
        ["medium"] = {
            label = "Orta Sipariş",
            minQuantity = 3,
            maxQuantity = 5,
            priceMultiplier = 1.3
        },
        ["large"] = {
            label = "Büyük Sipariş",
            minQuantity = 6,
            maxQuantity = 10,
            priceMultiplier = 1.5
        }
    }
}

-- Teslimat Sistemi
Config.DeliverySystem = {
    policeAlert = {
        -- Polis bildirimi için minimum mesafe
        minDistance = 50.0,
        -- Polis bildirimi için maksimum mesafe
        maxDistance = 150.0,
        -- Bildirimin gönderileceği meslekler
        jobs = {'police', 'sheriff'}
    },
    
    escapePoints = {
        -- Kaçış noktaları (tehlike durumunda)
        ["sewers"] = {
            label = "Kanalizasyon",
            coords = {
                vector4(123.45, -567.89, 30.12, 180.0),
                vector4(234.56, -678.90, 29.54, 90.0)
            }
        },
        ["tunnels"] = {
            label = "Tüneller",
            coords = {
                vector4(345.67, -789.01, 28.98, 270.0),
                vector4(456.78, -890.12, 27.65, 0.0)
            }
        }
    },
    
    vehicleTypes = {
        ["stealth"] = {
            label = "Gizli Araç",
            models = {"sultan", "primo", "oracle"},
            detection = 0.5 -- Polis tespit şansı çarpanı
        },
        ["fast"] = {
            label = "Hızlı Araç",
            models = {"kuruma", "sultan2", "buffalo"},
            detection = 0.8
        },
        ["cargo"] = {
            label = "Kargo Aracı",
            models = {"speedo", "burrito", "boxville"},
            detection = 1.2
        }
    },

    disguises = {
        ["civilian"] = {
            label = "Sivil Kıyafet",
            detection = 0.7,
            models = {
                male = {
                    ["components"] = {
                        [1] = {drawable = 0, texture = 0}, -- Maske
                        [3] = {drawable = 0, texture = 0}, -- Üst
                        [4] = {drawable = 0, texture = 0}, -- Alt
                        [6] = {drawable = 0, texture = 0}, -- Ayakkabı
                        [11] = {drawable = 0, texture = 0} -- Üst Giysi
                    }
                },
                female = {
                    ["components"] = {
                        [1] = {drawable = 0, texture = 0},
                        [3] = {drawable = 0, texture = 0},
                        [4] = {drawable = 0, texture = 0},
                        [6] = {drawable = 0, texture = 0},
                        [11] = {drawable = 0, texture = 0}
                    }
                }
            }
        },
        ["worker"] = {
            label = "İşçi Kıyafeti",
            detection = 0.6,
            models = {
                male = {
                    ["components"] = {
                        [1] = {drawable = 0, texture = 0},
                        [3] = {drawable = 0, texture = 0},
                        [4] = {drawable = 0, texture = 0},
                        [6] = {drawable = 0, texture = 0},
                        [11] = {drawable = 0, texture = 0}
                    }
                },
                female = {
                    ["components"] = {
                        [1] = {drawable = 0, texture = 0},
                        [3] = {drawable = 0, texture = 0},
                        [4] = {drawable = 0, texture = 0},
                        [6] = {drawable = 0, texture = 0},
                        [11] = {drawable = 0, texture = 0}
                    }
                }
            }
        }
    },

    routes = {
        ["safe"] = {
            label = "Güvenli Rota",
            checkpoints = {
                {type = "drive", coords = vector3(123.45, -567.89, 30.12)},
                {type = "wait", coords = vector3(234.56, -678.90, 29.54), time = 30},
                {type = "drive", coords = vector3(345.67, -789.01, 28.98)}
            },
            detection = 0.7
        },
        ["risky"] = {
            label = "Riskli Rota",
            checkpoints = {
                {type = "drive", coords = vector3(456.78, -890.12, 27.65)},
                {type = "swap", coords = vector3(567.89, -901.23, 26.43)},
                {type = "drive", coords = vector3(678.90, -012.34, 25.32)}
            },
            detection = 1.2
        }
    },

    heatSystem = {
        -- Isı seviyesi sistemi (polis takibi yoğunluğu)
        levels = {
            [1] = {
                label = "Düşük Risk",
                policeResponse = 1, -- Minimum polis sayısı
                responseTime = 60, -- Saniye
                backup = false
            },
            [2] = {
                label = "Orta Risk",
                policeResponse = 2,
                responseTime = 45,
                backup = true
            },
            [3] = {
                label = "Yüksek Risk",
                policeResponse = 3,
                responseTime = 30,
                backup = true,
                helicopter = true
            }
        },
        cooldown = 300, -- Isı seviyesinin düşmesi için gereken süre (saniye)
        increment = 1, -- Her yakalanma şüphesinde artış
        maxLevel = 3
    }
} 