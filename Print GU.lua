local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local url = "https://discord.com/api/webhooks/1369517947772473355/hfXw_5A0X4u7ZXJapgBmJZTp94dDjNqgze39XExEgNPmriwGG2eoOwhXY7Ty5qS_fDFH"
local placeId = game.PlaceId
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 📦 ฟังก์ชันจัดรูปแบบ Embed สำหรับ Discord
local function createItemEmbed(playerName, itemValue, eggValue)
    return { {
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
    } }
end

-- 📤 ฟังก์ชันส่งข้อมูลไปยัง Discord
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

-- 📊 ดึงข้อมูลไอเทมของผู้เล่น
local function getPlayerItemData(playerName)
    local playerDataFolder = ReplicatedStorage:WaitForChild("Player_Data"):FindFirstChild(playerName)
    if not playerDataFolder then return nil end

    local items = playerDataFolder:FindFirstChild("Items")
    local egg = playerDataFolder:FindFirstChild("Data") and playerDataFolder.Data:FindFirstChild("Egg")
    if not items or not egg then return nil end

    return {
        CursedFinger = items:FindFirstChild("Cursed Finger") and items["Cursed Finger"]:FindFirstChild("Amount") and items["Cursed Finger"].Amount.Value or 0,
        DrMeggaPunk = items:FindFirstChild("Dr. Megga Punk") and items["Dr. Megga Punk"]:FindFirstChild("Amount") and items["Dr. Megga Punk"].Amount.Value or 0,
        RangerCrystal = items:FindFirstChild("Ranger Crystal") and items["Ranger Crystal"]:FindFirstChild("Amount") and items["Ranger Crystal"].Amount.Value or 0,
        StatsKey = items:FindFirstChild("Stats Key") and items["Stats Key"]:FindFirstChild("Amount") and items["Stats Key"].Amount.Value or 0,
        TraitReroll = items:FindFirstChild("Trait Reroll") and items["Trait Reroll"]:FindFirstChild("Amount") and items["Trait Reroll"].Amount.Value or 0,
        Egg = egg.Value or 0
    }
end

-- 🎧 ตั้งค่า Listener เปลี่ยนแปลงไอเทม -> ส่งไป Discord
local function setupListeners(playerName)
    local playerDataFolder = ReplicatedStorage:WaitForChild("Player_Data"):FindFirstChild(playerName)
    if not playerDataFolder then return end

    local items = playerDataFolder:FindFirstChild("Items")
    local egg = playerDataFolder:FindFirstChild("Data") and playerDataFolder.Data:FindFirstChild("Egg")
    if not items or not egg then return end

    local function onValueChanged()
        local data = getPlayerItemData(playerName)
        if data then
            print("📦 พบการเปลี่ยนแปลงของ " .. playerName)
            sendToDiscord(playerName, data, data.Egg)
        end
    end

    for _, itemFolder in pairs(items:GetChildren()) do
        local amt = itemFolder:FindFirstChild("Amount")
        if amt and amt:IsA("NumberValue") then
            amt.Changed:Connect(onValueChanged)
        end
    end

    egg.Changed:Connect(onValueChanged)
end

-- ⛑️ ตรวจจับ Error GUI และรีจอยเซิร์ฟเวอร์
GuiService.ErrorMessageChanged:Connect(function(err)
    if err and err ~= "" then
        print("🚨 ตรวจพบ Error: " .. err)
        task.wait(2)
        print("🔄 กำลังพยายามรีจอยเซิร์เวอร์...")
        TeleportService:Teleport(placeId, player)
    else
        print("✅ ไม่มี Error, ทุกอย่างปกติ")
    end
end)

-- 🚀 เริ่มระบบ
if player then
    setupListeners(player.Name)
    local initialData = getPlayerItemData(player.Name)
    if initialData then
        sendToDiscord(player.Name, initialData, initialData.Egg)
    end
else
    warn("❌ ไม่พบผู้เล่นในเกม")
end
