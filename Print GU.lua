local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local placeId = game.PlaceId

-- ป้องกันหลุด และรีจอย
GuiService.ErrorMessageChanged:Connect(function(err)
    if err and err ~= "" then
        print("🚨 ตรวจพบ Error: " .. err)
        task.wait(2)
        print("🔄 กำลังพยายามรีจอยเซิร์ฟเวอร์...")
        TeleportService:Teleport(placeId, player)
    end
end)

-- Discord Webhook
local url = "https://discord.com/api/webhooks/xxxxxxxxx/xxxxxxxx" -- แก้ URL จริงตรงนี้
local imageUrl = "https://img2.pic.in.th/pic/475981006_504564545992490_6167097446539934981_n.md.jpg"

local previousValues = {}

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
            icon_url = imageUrl
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

local function sendToDiscord(playerName, itemValue, eggValue)
    local payload = {
        content = nil,
        embeds = createItemEmbed(playerName, itemValue, eggValue),
        username = "Kantinan Hub",
        avatar_url = imageUrl
    }

    local body = HttpService:JSONEncode(payload)
    local headers = {["Content-Type"] = "application/json"}
    local requestFunc = http_request or request or HttpPost or (syn and syn.request)

    if not requestFunc then
        warn("❌ ไม่มีฟังก์ชันส่ง HTTP Request")
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

    if success then
        print("✅ ส่งข้อมูลไป Discord สำเร็จ")
    else
        warn("❌ ล้มเหลว: " .. tostring(response))
    end
end

local function getPlayerItemData(playerName)
    local folder = ReplicatedStorage:WaitForChild("Player_Data"):FindFirstChild(playerName)
    if not folder then return nil end

    local items = folder:FindFirstChild("Items")
    local egg = folder:FindFirstChild("Data") and folder.Data:FindFirstChild("Egg")

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

local function setupListeners(playerName)
    local folder = ReplicatedStorage:WaitForChild("Player_Data"):FindFirstChild(playerName)
    if not folder then return end

    local items = folder:FindFirstChild("Items")
    local egg = folder:FindFirstChild("Data") and folder.Data:FindFirstChild("Egg")

    if not items or not egg then return end

    -- เก็บค่าก่อนหน้า
    previousValues[playerName] = getPlayerItemData(playerName)

    local function onChange()
        local currentData = getPlayerItemData(playerName)
        local lastData = previousValues[playerName]

        if currentData and lastData then
            for key, newVal in pairs(currentData) do
                if newVal > (lastData[key] or 0) then
                    previousValues[playerName] = currentData
                    sendToDiscord(playerName, currentData, currentData.Egg)
                    break
                end
            end
        end
    end

    -- ฟังการเปลี่ยนแปลงของ Amount ทุกชิ้น
    for _, item in pairs(items:GetChildren()) do
        local amt = item:FindFirstChild("Amount")
        if amt and amt:IsA("NumberValue") then
            amt.Changed:Connect(onChange)
        end
    end

    egg.Changed:Connect(onChange)
end

-- เริ่มต้น
local localPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

if localPlayer then
    setupListeners(localPlayer.Name)

    local init = getPlayerItemData(localPlayer.Name)
    if init then
        previousValues[localPlayer.Name] = init
    end
else
    warn("❌ ไม่พบผู้เล่น")
end
