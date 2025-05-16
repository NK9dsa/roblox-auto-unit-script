local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local placeId = game.PlaceId

local url = "https://discord.com/api/webhooks/1372782698233335918/DuiWpxujmHXtVU1zd2pZnTbF9u0KsquHXFOKpjDvTOpUpgze9ex3FuTqWCjqO5X5xwXR"

local function createItemEmbed(playerName, gemValue, goldValue, levelValue, eggValue, itemValue, merchantValue)
    local description = string.format(
        "**⭐ ชื่อในเกม:** ||%s||\n\n" ..
        "💎 Gem %d   🪙 Gold %d\n" ..
        "🎚 Level %d   🥚 Egg %d\n\n" ..
        "🛍️ **Items**\n" ..
        "👉🏻 **Cursed Finger:** %d ชิ้น\n" ..
        "🧑🏻‍⚕️ **Dr. Megga Punk:** %d ชิ้น\n" ..
        "🔮 **Ranger Crystal:** %d ชิ้น\n" ..
        "📊 **Stats Key:** %d ชิ้น\n" ..
        "🎲 **Trait Reroll:** %d ชิ้น\n\n" ..
        "🏪 **Merchant**\n" ..
        "💰 **Dr. Megga Punk:** %d Gem (x%d)\n" ..
        "💰 **Cursed Finger:** %d Gem (x%d)\n" ..
        "💰 **Ranger Crystal:** %d Gem (x%d)\n" ..
        "💰 **Stats Key:** %d Gem (x%d)\n" ..
        "💰 **Trait Reroll:** %d Gem (x%d)\n",
        playerName or "Unknown",
        gemValue or 0, goldValue or 0,
        levelValue or 0, eggValue or 0,
        itemValue.CursedFinger or 0,
        itemValue.DrMeggaPunk or 0,
        itemValue.RangerCrystal or 0,
        itemValue.StatsKey or 0,
        itemValue.TraitReroll or 0,
        merchantValue.DrMeggaPunk.Amount or 0, merchantValue.DrMeggaPunk.Quantity or 0,
        merchantValue.CursedFinger.Amount or 0, merchantValue.CursedFinger.Quantity or 0,
        merchantValue.RangerCrystal.Amount or 0, merchantValue.RangerCrystal.Quantity or 0,
        merchantValue.StatsKey.Amount or 0, merchantValue.StatsKey.Quantity or 0,
        merchantValue.TraitReroll.Amount or 0, merchantValue.TraitReroll.Quantity or 0
    )

    return {{
        title = "Check Item ⌛ Easter Anime Rangers X",
        description = description,
        color = 13369344,
        footer = {
            text = "By Kantinan",
            icon_url = "https://img2.pic.in.th/pic/475981006_504564545992490_6167097446539934981_n.md.jpg"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        thumbnail = {url = "https://static.wikitide.net/animerangerxwiki/2/26/ARXLogo.png"},
        image = {url = "https://tr.rbxcdn.com/180DAY-55b32ceb45515e38d3b7d6650a0a2304/768/432/Image/Webp/noFilter"}
    }}
end

local function sendToDiscord(playerName, gemValue, goldValue, levelValue, eggValue, itemValue, merchantValue)
    local payload = {
        content = nil,
        embeds = createItemEmbed(playerName, gemValue, goldValue, levelValue, eggValue, itemValue, merchantValue),
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

local function getMerchantData(playerDataFolder)
    local merchantFolder = playerDataFolder:FindFirstChild("Merchant")
    if not merchantFolder then return {
        DrMeggaPunk = {Amount = 0, Quantity = 0},
        CursedFinger = {Amount = 0, Quantity = 0},
        RangerCrystal = {Amount = 0, Quantity = 0},
        StatsKey = {Amount = 0, Quantity = 0},
        TraitReroll = {Amount = 0, Quantity = 0}
    } end

    local function getMerchantInfo(itemName)
        local item = merchantFolder:FindFirstChild(itemName)
        local amount = item and item:FindFirstChild("CurrencyAmount") and item.CurrencyAmount.Value or 0
        local quantity = item and item:FindFirstChild("Quantity") and item.Quantity.Value or 0
        return {Amount = amount, Quantity = quantity}
    end

    return {
        DrMeggaPunk = getMerchantInfo("Dr. Megga Punk"),
        CursedFinger = getMerchantInfo("Cursed Finger"),
        RangerCrystal = getMerchantInfo("Ranger Crystal"),
        StatsKey = getMerchantInfo("Stats Key"),
        TraitReroll = getMerchantInfo("Trait Reroll")
    }
end

local function checkItemsForPlayer(playerName)
    local playerDataFolder = game:GetService("ReplicatedStorage"):WaitForChild("Player_Data"):FindFirstChild(playerName)
    if not playerDataFolder then
        warn("❌ ไม่พบ Player_Data สำหรับผู้เล่น: " .. playerName)
        return
    end

    local playerItemsFolder = playerDataFolder:FindFirstChild("Items")
    local playerData = playerDataFolder:FindFirstChild("Data")
    if not playerItemsFolder or not playerData then
        warn("❌ ข้อมูลไม่ครบถ้วน")
        return
    end

    local function getAmount(itemName)
        local item = playerItemsFolder:FindFirstChild(itemName)
        if item and item:FindFirstChild("Amount") then
            return item.Amount.Value
        else
            return 0
        end
    end

    local itemInfo = {
        CursedFinger = getAmount("Cursed Finger"),
        DrMeggaPunk = getAmount("Dr. Megga Punk"),
        RangerCrystal = getAmount("Ranger Crystal"),
        StatsKey = getAmount("Stats Key"),
        TraitReroll = getAmount("Trait Reroll")
    }

    local gemValue = playerData:FindFirstChild("Gem") and playerData.Gem.Value or 0
    local goldValue = playerData:FindFirstChild("Gold") and playerData.Gold.Value or 0
    local levelValue = playerData:FindFirstChild("Level") and playerData.Level.Value or 0
    local eggValue = playerData:FindFirstChild("Egg") and playerData.Egg.Value or 0

    local merchantInfo = getMerchantData(playerDataFolder)

    print("📤 กำลังส่งข้อมูลไป Discord สำหรับผู้เล่น: " .. playerName)
    sendToDiscord(playerName, gemValue, goldValue, levelValue, eggValue, itemInfo, merchantInfo)
end

task.spawn(function()
    while true do
        checkItemsForPlayer(player.Name)
        task.wait(60)
    end
end)

GuiService.ErrorMessageChanged:Connect(function(err)
    if err and err ~= "" then
        print("🚨 ตรวจพบ Error: " .. err)
        task.wait(2)
        print("🔄 กำลังพยายามรีจอยเซิร์ฟเวอร์...")
        TeleportService:Teleport(placeId, player)
    end
end)
