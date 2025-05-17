local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local placeId = game.PlaceId

local url = "https://discord.com/api/webhooks/1372782698233335918/DuiWpxujmHXtVU1zd2pZnTbF9u0KsquHXFOKpjDvTOpUpgze9ex3FuTqWCjqO5X5xwXR"

local function createItemEmbed(playerName, gemValue, goldValue, levelValue, rccellValue, itemValue, merchantValue, portal1, portal2, portal3)
    local description = string.format(
        "**⭐ ชื่อในเกม:** ||%s||\n\n" ..
        "💎 Gem %d   🪙 Gold %d\n" ..
        "🎚 Level %d   🧪 RC Cells %d\n\n" ..
        "🛍️ **Items**\n" ..
        "👉🏻 **Cursed Finger:** %d ชิ้น\n" ..
        "🧑🏻‍⚕️ **Dr. Megga Punk:** %d ชิ้น\n" ..
        "🔮 **Ranger Crystal:** %d ชิ้น\n" ..
        "📊 **Stats Key:** %d ชิ้น\n" ..
        "🎲 **Trait Reroll:** %d ชิ้น\n\n" ..
        "🌌 **Ghoul Portals**\n" ..
        "📍 **Portal I:** %d ชิ้น\n" ..
        "📍 **Portal II:** %d ชิ้น\n" ..
        "📍 **Portal III:** %d ชิ้น\n\n" ..
        "🏪 **Merchant**\n" ..
        "💰 **Dr. Megga Punk:** %d Gem (x%d)\n" ..
        "💰 **Cursed Finger:** %d Gem (x%d)\n" ..
        "💰 **Ranger Crystal:** %d Gem (x%d)\n" ..
        "💰 **Stats Key:** %d Gem (x%d)\n" ..
        "💰 **Trait Reroll:** %d Gem (x%d)\n",
        playerName or "Unknown",
        gemValue or 0, goldValue or 0,
        levelValue or 0, rccellValue or 0,
        itemValue.CursedFinger or 0,
        itemValue.DrMeggaPunk or 0,
        itemValue.RangerCrystal or 0,
        itemValue.StatsKey or 0,
        itemValue.TraitReroll or 0,
        portal1 or 0, portal2 or 0, portal3 or 0,
        merchantValue.DrMeggaPunk.Amount or 0, merchantValue.DrMeggaPunk.Quantity or 0,
        merchantValue.CursedFinger.Amount or 0, merchantValue.CursedFinger.Quantity or 0,
        merchantValue.RangerCrystal.Amount or 0, merchantValue.RangerCrystal.Quantity or 0,
        merchantValue.StatsKey.Amount or 0, merchantValue.StatsKey.Quantity or 0,
        merchantValue.TraitReroll.Amount or 0, merchantValue.TraitReroll.Quantity or 0
    )

    return {{
        title = "[🩸 UPDATE 1] Anime Rangers X",
        description = description,
        color = 13369344,
        footer = {
            text = "By Kantinan",
            icon_url = "https://img2.pic.in.th/pic/475981006_504564545992490_6167097446539934981_n.md.jpg"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        thumbnail = {
            url = "https://media.discordapp.net/attachments/1332161685196374096/1365402193393356800/image.png"
        },
        image = {
            url = "https://tr.rbxcdn.com/180DAY-0b31ac08cbd92f3d49bb8814f0834315/768/432/Image/Png/noFilter"
        }
    }}
end

local function sendToDiscord(playerName, gemValue, goldValue, levelValue, rccellValue, itemValue, merchantValue, portal1, portal2, portal3)
    local payload = {
        content = nil,
        embeds = createItemEmbed(playerName, gemValue, goldValue, levelValue, rccellValue, itemValue, merchantValue, portal1, portal2, portal3),
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

local function getAmount(itemFolder, itemName)
    local item = itemFolder:FindFirstChild(itemName)
    return (item and item:FindFirstChild("Amount") and item.Amount.Value) or 0
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

    local itemInfo = {
        CursedFinger = getAmount(playerItemsFolder, "Cursed Finger"),
        DrMeggaPunk = getAmount(playerItemsFolder, "Dr. Megga Punk"),
        RangerCrystal = getAmount(playerItemsFolder, "Ranger Crystal"),
        StatsKey = getAmount(playerItemsFolder, "Stats Key"),
        TraitReroll = getAmount(playerItemsFolder, "Trait Reroll")
    }

    local portal1 = getAmount(playerItemsFolder, "Ghoul City Portal I")
    local portal2 = getAmount(playerItemsFolder, "Ghoul City Portal II")
    local portal3 = getAmount(playerItemsFolder, "Ghoul City Portal III")

    local gemValue = playerData:FindFirstChild("Gem") and playerData.Gem.Value or 0
    local goldValue = playerData:FindFirstChild("Gold") and playerData.Gold.Value or 0
    local levelValue = playerData:FindFirstChild("Level") and playerData.Level.Value or 0
    local rccellValue = playerData:FindFirstChild("RCCells") and playerData.RCCells.Value or 0

    local merchantInfo = getMerchantData(playerDataFolder)

    print("📤 กำลังส่งข้อมูลไป Discord สำหรับผู้เล่น: " .. playerName)
    sendToDiscord(playerName, gemValue, goldValue, levelValue, rccellValue, itemInfo, merchantInfo, portal1, portal2, portal3)
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
