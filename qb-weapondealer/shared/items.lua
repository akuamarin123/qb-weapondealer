QBShared = QBShared or {}
QBShared.Items = QBShared.Items or {}

-- Silah Üretim Malzemeleri
QBShared.Items["steel"] = {
    name = "steel",
    label = "Çelik",
    weight = 1000,
    type = "item",
    image = "steel.png",
    unique = false,
    useable = false,
    shouldClose = false,
    combinable = nil,
    description = "Silah üretimi için kullanılan çelik"
}

QBShared.Items["aluminum"] = {
    name = "aluminum",
    label = "Alüminyum",
    weight = 500,
    type = "item",
    image = "aluminum.png",
    unique = false,
    useable = false,
    shouldClose = false,
    combinable = nil,
    description = "Silah üretimi için kullanılan alüminyum"
}

QBShared.Items["plastic"] = {
    name = "plastic",
    label = "Plastik",
    weight = 100,
    type = "item",
    image = "plastic.png",
    unique = false,
    useable = false,
    shouldClose = false,
    combinable = nil,
    description = "Silah üretimi için kullanılan plastik"
}

QBShared.Items["gunpowder"] = {
    name = "gunpowder",
    label = "Barut",
    weight = 100,
    type = "item",
    image = "gunpowder.png",
    unique = false,
    useable = false,
    shouldClose = false,
    combinable = nil,
    description = "Mermi üretimi için kullanılan barut"
}

-- Üretilen Silahlar ve Mermiler
QBShared.Items["weapon_pistol"] = {
    name = "weapon_pistol",
    label = "Tabanca",
    weight = 1000,
    type = "weapon",
    ammotype = "pistol_ammo",
    image = "weapon_pistol.png",
    unique = true,
    useable = false,
    description = "El yapımı tabanca"
}

QBShared.Items["weapon_smg"] = {
    name = "weapon_smg",
    label = "Hafif Makineli",
    weight = 2500,
    type = "weapon",
    ammotype = "smg_ammo",
    image = "weapon_smg.png",
    unique = true,
    useable = false,
    description = "El yapımı hafif makineli"
}

QBShared.Items["pistol_ammo"] = {
    name = "pistol_ammo",
    label = "Tabanca Mermisi",
    weight = 50,
    type = "item",
    image = "pistol_ammo.png",
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = "El yapımı tabanca mermisi"
}

QBShared.Items["smg_ammo"] = {
    name = "smg_ammo",
    label = "Hafif Makineli Mermisi",
    weight = 75,
    type = "item",
    image = "smg_ammo.png",
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = "El yapımı hafif makineli mermisi"
} 