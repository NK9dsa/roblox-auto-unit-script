local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local WebhookURL = "https://discord.com/api/webhooks/1229028220598728754/jC4Q0brOJRUa5tF1nU3Q7H5cNM0H3FeCXYIBgaqlMIzMd30HRzDfC-MYJJNqTcz6THOU" -- เปลี่ยนเป็น Webhook ของคุณ

local importantItems = {
    CursedFinger = "☠️ Cursed Finger",
    DrMeggaPunk = "🧪 Dr. Megga Punk",
    RangerCrystal = "🏹 Ranger Crystal",
    StatsKey = "🗝️ Stats Key",
    TraitReroll = "♻️ Trait Reroll"
}

local previousItemValues = {
    CursedFinger = -1,
    DrMeggaPunk = -1,
    RangerCrystal = -1,
    StatsKey = -1,
    TraitReroll = -1
}

-- ฟังก์ชันส่งข้อความไป Discord
local function sendWebhookMessage(itemName, currentValue)
    local data = {
        ["content"] = string.format("📦 พบไอเท็มสำคัญ: **%s** จำนวน **%s** ชิ้น", itemName, currentValue)
    }
    local jsonData = HttpService:JSONEncode(data)
    HttpService:PostAsync(WebhookURL, jsonData, Enum.HttpContentType.ApplicationJson)
end

-- ฟังก์ชันตรวจสอบการเปลี่ยนแปลงไอเท็ม
local function checkItems()
    local merchantGui = player.PlayerGui:FindFirstChild("Merchant")
    if not merchantGui or not merchantGui:FindFirstChild("Main") then return end

    for itemKey, displayName in pairs(importantItems) do
        local itemValueObject = merchantGui.Main:FindFirstChild(itemKey)
        if itemValueObject and itemValueObject:IsA("TextLabel") then
            local currentValue = tonumber(itemValueObject.Text)
            if currentValue and currentValue ~= previousItemValues[itemKey] then
                previousItemValues[itemKey] = currentValue
                sendWebhookMessage(displayName, currentValue)
            end
        end
    end
end

-- ฟังก์ชันซื้อของ
local function checkAndBuyItem(itemName)
    local merchantGui = player.PlayerGui:FindFirstChild("Merchant")
    if not merchantGui or not merchantGui:FindFirstChild("Main") then return end

    local item = merchantGui.Main.ScrollingFrame:FindFirstChild(itemName)
    if item and item:FindFirstChild("Buy") then
        local buyButton = item.Buy
        if buyButton:IsA("ImageButton") and buyButton.Visible and buyButton.AutoButtonColor then
            buyButton:Activate()
            sendWebhookMessage(itemName, "ซื้อแล้ว")
        end
    end
end

-- GUI แสดงสถานะ
local function setupCompactStatusGUI()
    local screenGui = Instance.new("ScreenGui", player.PlayerGui)
    screenGui.Name = "CompactStatusGUI"

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 300, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = "⌛ กำลังโหลดข้อมูล..."

    -- อัปเดตข้อความทุก 10 วินาที
    task.spawn(function()
        while true do
            local merchantGui = player.PlayerGui:FindFirstChild("Merchant")
            if not merchantGui or not merchantGui:FindFirstChild("Main") then
                label.Text = "❌ GUI ยังไม่โหลด"
            else
                local message = "📦 รายการ:\n"
                for itemKey, displayName in pairs(importantItems) do
                    local itemValueObject = merchantGui.Main:FindFirstChild(itemKey)
                    local countText = itemValueObject and itemValueObject.Text or "?"
                    message = message .. string.format("%s: %s\n", displayName, countText)
                end
                label.Text = message
            end
            task.wait(10)
        end
    end)
end

-- ✅ รอให้ Player_Data พร้อมก่อนเริ่ม GUI
local playerData
repeat
    task.wait()
    pcall(function()
        playerData = ReplicatedStorage:WaitForChild("Player_Data"):FindFirstChild(player.Name)
    end)
until playerData

-- ✅ เริ่ม GUI
setupCompactStatusGUI()

-- ✅ ตรวจสอบไอเท็มแบบ loop
task.spawn(function()
    while true do
        pcall(function()
            checkItems()
        end)
        task.wait(5)
    end
end)
