local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local placeId = game.PlaceId

-- URL ของ Webhook
local url = "https://discord.com/api/webhooks/1369517947772473355/hfXw_5A0X4u7ZXJapgBmJZTp94dDjNqgze39XExEgNPmriwGG2eoOwhXY7Ty5qS_fDFH"

-- ฟังก์ชันสร้าง Embed
local function createItemEmbed(playerName, itemValue, eggValue)
    return {{
        title = "Check Item ⌛ Easter Anime Rangers X",
        color = 13369344,
        fields = {
            {name = "**⭐ : ชื่อในเกม**", value = "||" .. playerName .. "||"},
            {name = "**👉🏻 : Cursed Finger**", value = "**" .. tostring(itemValue.CursedFinger or 0) .. "** ชิ้น"},
            {name = "**🧑🏻‍⚕️ : Dr. Megga Punk**", value = "**" .. tostring(itemValue.DrMeggaPunk or 0) .. "** ชิ้น"},
            {name = "**🔮 : Ranger Crystal**", value = "**" .. tostring(itemValue.RangerCrystal or 0) .. "** ชิ้น"},
            {name = "**📊 : Stats Key**", value = "**" .. tostring(itemValue.StatsKey or 0) .. "** ชิ้น"},
            {name = "**🎲 : Trait Reroll**", value = "**" .. tostring(itemValue.TraitReroll or 0) .. "** ชิ้น"},
            {name = "**🥚 : Egg**", value = "**" .. tostring(eggValue or 0) .. "** ชิ้น"}
        },
        footer = {
            text = "By Kantinan",
            icon_url = "https://img2.pic.in.th/pic/475981006_504564545992490_6167097446539934981_n.md.jpg"
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

-- ฟังก์ชันส่งข้อมูลไป Discord
local function sendToDiscord(playerName, itemValue, eggValue)
    local payload = {
        content = nil,
        embeds = createItemEmbed(playerName, itemValue, eggValue),
        username = "Kantinan Hub",
        avatar_url = "https://img2.pic.in.th/pic/475981006_504564545992490_6167097446539934981_n.md.jpg"
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

-- ฟังก์ชันเช็คข้อมูลไอเทมจาก ReplicatedStorage ของผู้เล่นที่ส่งมา
local function checkItemsForPlayer(playerName)
    local playerDataFolder = game:GetService("ReplicatedStorage"):WaitForChild("Player_Data"):FindFirstChild(playerName)
    if not playerDataFolder then
        warn("❌ ไม่พบ Player_Data สำหรับผู้เล่น: " .. playerName)
        return
    end

    local playerItemsFolder = playerDataFolder:FindFirstChild("Items")
    local playerEggValue = playerDataFolder:FindFirstChild("Data") and playerDataFolder.Data:FindFirstChild("Egg")

    if not playerItemsFolder then
        warn("❌ ไม่พบ Items folder สำหรับผู้เล่น: " .. playerName)
        return
    end

    if not playerEggValue then
        warn("❌ ไม่พบค่า Egg สำหรับผู้เล่น: " .. playerName)
        return
    end

    local itemInfo = {
        CursedFinger = playerItemsFolder:FindFirstChild("Cursed Finger") and playerItemsFolder["Cursed Finger"]:FindFirstChild("Amount") and playerItemsFolder["Cursed Finger"].Amount.Value or 0,
        DrMeggaPunk = playerItemsFolder:FindFirstChild("Dr. Megga Punk") and playerItemsFolder["Dr. Megga Punk"]:FindFirstChild("Amount") and playerItemsFolder["Dr. Megga Punk"].Amount.Value or 0,
        RangerCrystal = playerItemsFolder:FindFirstChild("Ranger Crystal") and playerItemsFolder["Ranger Crystal"]:FindFirstChild("Amount") and playerItemsFolder["Ranger Crystal"].Amount.Value or 0,
        StatsKey = playerItemsFolder:FindFirstChild("Stats Key") and playerItemsFolder["Stats Key"]:FindFirstChild("Amount") and playerItemsFolder["Stats Key"].Amount.Value or 0,
        TraitReroll = playerItemsFolder:FindFirstChild("Trait Reroll") and playerItemsFolder["Trait Reroll"]:FindFirstChild("Amount") and playerItemsFolder["Trait Reroll"].Amount.Value or 0
    }

    local eggValue = playerEggValue.Value or 0

    print("กำลังส่งข้อมูลไป Discord สำหรับผู้เล่น: " .. playerName)
    sendToDiscord(playerName, itemInfo, eggValue)
end

-- ลูปส่งข้อมูลทุก 60 วินาที (1 นาที)
spawn(function()
    while true do
        if player then
            checkItemsForPlayer(player.Name)
        end
        wait(60)
    end
end)

-- โค้ดป้องกันหลุดและรีจอยถ้ามี Error
GuiService.ErrorMessageChanged:Connect(function(err)
    if err and err ~= "" then
        print("🚨 ตรวจพบ Error: " .. err)
        task.wait(2)
        print("🔄 กำลังพยายามรีจอยเซิร์ฟเวอร์...")
        TeleportService:Teleport(placeId, player)
    else
        print("✅ ไม่มี Error, ทุกอย่างปกติ")
    end
end)
