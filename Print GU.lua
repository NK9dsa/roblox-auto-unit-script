local HttpService = game:GetService("HttpService")

local url = "https://discord.com/api/webhooks/1369517947772473355/hfXw_5A0X4u7ZXJapgBmJZTp94dDjNqgze39XExEgNPmriwGG2eoOwhXY7Ty5qS_fDFH"

local function createItemEmbed(playerName, itemValue, eggValue)
    return {{
        title = "Check Item ⌛ Easter Anime Rangers X",
        color = 13369344,
        fields = {
            {name = "**⭐ : ชื่อในเกม**", value = "**" .. playerName .. "**"},
            {name = "**👉🏻 : Cursed Finger**", value = "**" .. tostring(itemValue.CursedFinger or 0) .. "** ชิ้น"},
            {name = "**🧑🏻‍⚕️ : Dr. Megga Punk**", value = "**" .. tostring(itemValue.DrMeggaPunk or 0) .. "** ชิ้น"},
            {name = "**🔮 : Ranger Crystal**", value = "**" .. tostring(itemValue.RangerCrystal or 0) .. "** ชิ้น"},
            {name = "**📊 : Stats Key**", value = "**" .. tostring(itemValue.StatsKey or 0) .. "** ชิ้น"},
            {name = "**🎲 : Trait Reroll**", value = "**" .. tostring(itemValue.TraitReroll or 0) .. "** ชิ้น"},
            {name = "**🥚 : Egg**", value = "**" .. tostring(eggValue or 0) .. "** ชิ้น"}
        },
        footer = {
            text = "By Kantinan",
            icon_url = "https://scontent.fbkk17-1.fna.fbcdn.net/v/t39.30808-6/475981006_504564545992490_6167097446539934981_n.jpg"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        image = {
            url = "https://tr.rbxcdn.com/180DAY-55b32ceb45515e38d3b7d6650a0a2304/768/432/Image/Webp/noFilter"
        },
        thumbnail = {
            url = "https://static.wikitide.net/animerangerxwiki/2/26/ARXLogo.png"
        }
    }}
end

local function sendToDiscord(playerName, itemValue, eggValue)
    local payload = {
        content = nil,
        embeds = createItemEmbed(playerName, itemValue, eggValue),
        username = "Kantinan Hub",
        avatar_url = "https://scontent.fbkk17-1.fna.fbcdn.net/v/t39.30808-6/475981006_504564545992490_6167097446539934981_n.jpg"
    }

    local body = HttpService:JSONEncode(payload)
    local headers = {["Content-Type"] = "application/json"}

    local requestFunc = http_request or request or HttpPost or (syn and syn.request)

    if not requestFunc then
        warn("❌ ไม่มีฟังก์ชันส่ง HTTP Request ในสภาพแวดล้อมนี้")
        return
    end

    local success, response = pcall(function()
        return requestFunc({
            Url = url,
            Method = "POST",
            Headers = headers,
            Body = body
        })
    end)

    if not success then
        warn("❌ ส่งข้อมูลไป Discord ล้มเหลว: " .. tostring(response))
    else
        print("✅ ส่งข้อมูลไป Discord สำเร็จ")
    end
end

local function getPlayerItemData(playerName)
    local playerDataFolder = game:GetService("ReplicatedStorage"):WaitForChild("Player_Data"):FindFirstChild(playerName)
    if not playerDataFolder then return nil end
    local playerItemsFolder = playerDataFolder:FindFirstChild("Items")
    local playerEggValue = playerDataFolder:FindFirstChild("Data") and playerDataFolder.Data:FindFirstChild("Egg")

    if not playerItemsFolder or not playerEggValue then return nil end

    return {
        CursedFinger = playerItemsFolder:FindFirstChild("Cursed Finger") and playerItemsFolder["Cursed Finger"]:FindFirstChild("Amount") and playerItemsFolder["Cursed Finger"].Amount.Value or 0,
        DrMeggaPunk = playerItemsFolder:FindFirstChild("Dr. Megga Punk") and playerItemsFolder["Dr. Megga Punk"]:FindFirstChild("Amount") and playerItemsFolder["Dr. Megga Punk"].Amount.Value or 0,
        RangerCrystal = playerItemsFolder:FindFirstChild("Ranger Crystal") and playerItemsFolder["Ranger Crystal"]:FindFirstChild("Amount") and playerItemsFolder["Ranger Crystal"].Amount.Value or 0,
        StatsKey = playerItemsFolder:FindFirstChild("Stats Key") and playerItemsFolder["Stats Key"]:FindFirstChild("Amount") and playerItemsFolder["Stats Key"].Amount.Value or 0,
        TraitReroll = playerItemsFolder:FindFirstChild("Trait Reroll") and playerItemsFolder["Trait Reroll"]:FindFirstChild("Amount") and playerItemsFolder["Trait Reroll"].Amount.Value or 0,
        Egg = playerEggValue.Value or 0
    }
end

-- ฟังก์ชันตั้ง Listener ที่จะตรวจจับการเปลี่ยนแปลงไอเทมและส่ง Discord อัตโนมัติ
local function setupListeners(playerName)
    local playerDataFolder = game:GetService("ReplicatedStorage"):WaitForChild("Player_Data"):FindFirstChild(playerName)
    if not playerDataFolder then return end

    local playerItemsFolder = playerDataFolder:FindFirstChild("Items")
    local playerEggValue = playerDataFolder:FindFirstChild("Data") and playerDataFolder.Data:FindFirstChild("Egg")

    if not playerItemsFolder or not playerEggValue then return end

    -- สร้างฟังก์ชันส่งข้อมูลหลังจากมีการเปลี่ยนแปลง
    local function onValueChanged()
        local itemData = getPlayerItemData(playerName)
        if itemData then
            print("พบการเปลี่ยนแปลงไอเทมของผู้เล่น: " .. playerName)
            sendToDiscord(playerName, itemData, itemData.Egg)
        end
    end

    -- ตั้ง listener ให้แต่ละ Amount ใน Items
    for _, itemFolder in pairs(playerItemsFolder:GetChildren()) do
        local amountValue = itemFolder:FindFirstChild("Amount")
        if amountValue and amountValue:IsA("NumberValue") then
            amountValue.Changed:Connect(onValueChanged)
        end
    end

    -- ตั้ง listener ให้ Egg
    playerEggValue.Changed:Connect(onValueChanged)
end

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

if localPlayer then
    -- เรียกใช้ตั้ง Listener
    setupListeners(localPlayer.Name)

    -- ส่งข้อมูลเริ่มต้นตอนโหลด
    local initialData = getPlayerItemData(localPlayer.Name)
    if initialData then
        sendToDiscord(localPlayer.Name, initialData, initialData.Egg)
    end
else
    warn("❌ ไม่พบผู้เล่นในเกม")
end
