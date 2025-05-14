wait(10)
-- 📦 Services
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local placeId = game.PlaceId

-- ⛑️ ป้องกันหลุด และรีจอยหากพบ Error
GuiService.ErrorMessageChanged:Connect(function(err)
    if err and err ~= "" then
        print("🚨 ตรวจพบ Error: " .. err)

        -- ตรวจสอบข้อความที่อาจหมายถึง Error 267
        if string.find(err, "kicked") or string.find(err, "Kick") then
            print("❌ ผู้เล่นถูกเตะออกจากเกม (Error 267) ไม่พยายามรีจอย")
            return
        end

        -- รอ 2 วินาทีแล้วพยายามรีจอย
        task.wait(2)
        print("🔄 กำลังพยายามรีจอยเซิร์เวอร์...")
        TeleportService:Teleport(placeId, player)
    else
        print("✅ ไม่มี Error, ทุกอย่างปกติ")
    end
end)


print("📌 ระบบป้องกันหลุดทำงานแล้ว")

-- 🏋️ Anti-AFK
local VirtualUser = game:service("VirtualUser")
player.Idled:connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- 🔁 Backup click ทุก 5 นาที
task.spawn(function()
    while true do
        wait(300)
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- 📊 GUI แสดง Egg + ไอเทมทั้งหมดแบบรวมในกล่องเดียว
local playerData = ReplicatedStorage:WaitForChild("Player_Data"):WaitForChild(player.Name)

-- 🕒 ตัวแปรใช้คำนวณ Egg ต่อชั่วโมง
local startTime = os.clock()
local startEggCount = 0

local function setupCompactStatusGUI()
    local existing = playerGui:FindFirstChild("CompactStatusGui")
    if existing then existing:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "CompactStatusGui"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    local label = Instance.new("TextLabel")
    label.Name = "StatusLabel"
    label.Size = UDim2.new(0, 180, 0, 150)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 0.3
    label.TextScaled = true
    label.Font = Enum.Font.Cartoon
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Text = "📦 กำลังโหลดข้อมูล..."
    label.Parent = gui

    local items = {
        "Cursed Finger",
        "Stats Key",
        "Ranger Crystal",
        "Trait Reroll",
        "Dr. Megga Punk"
    }

    local playerItems = playerData:WaitForChild("Items")

    local function checkAndUpdateItems()
        local lines = {}
        table.insert(lines, "👤 " .. player.Name)

        local success, eggValue = pcall(function()
            return playerData:WaitForChild("Data"):WaitForChild("Egg").Value
        end)

        if success then
            if startEggCount == 0 then
                startEggCount = eggValue
            end
            local elapsedTime = os.clock() - startTime
            local eggDiff = eggValue - startEggCount
            local eggsPerHour = math.floor((eggDiff / elapsedTime) * 3600)
            table.insert(lines, "🥚 Egg: " .. eggValue .. " (≈ " .. eggsPerHour .. "/ชม.)")
        else
            table.insert(lines, "🥚 Egg: ❌")
        end

        for _, itemName in ipairs(items) do
            local item = playerItems:FindFirstChild(itemName)
            if item and item:FindFirstChild("Amount") then
                table.insert(lines, "📦 " .. itemName .. ": " .. item.Amount.Value)
            else
                table.insert(lines, "📦 " .. itemName .. ": -")
            end
        end

        label.Text = table.concat(lines, "\n")
    end

    local function createItemCheckLabel(yPosition, itemName)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 180, 0, 30)
        label.Position = UDim2.new(0, 10, 0, yPosition)
        label.AnchorPoint = Vector2.new(0, 0)
        label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.BackgroundTransparency = 0.3
        label.TextScaled = true
        label.Font = Enum.Font.Cartoon
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = "กำลังตรวจสอบ " .. itemName .. "..."
        label.Parent = gui
        return label
    end

    local punkLabel = createItemCheckLabel(160, "Dr. Megga Punk")
    local rerollLabel = createItemCheckLabel(200, "Trait Reroll")

    local function checkAndBuyItem(itemName, maxPrice, label)
        local gemValue = playerData:WaitForChild("Data"):WaitForChild("Gem").Value
        if gemValue == 37500 then
            label.Text = "⛔️ หยุดซื้อ " .. itemName .. " เพราะ Gem = 37500"
            return
        end

        local merchantGui = playerGui:WaitForChild("Merchant")
        local base = merchantGui:WaitForChild("Main"):WaitForChild("Base")
        local scroll = base:WaitForChild("Main"):WaitForChild("ScrollingFrame")
        local item = scroll:FindFirstChild(itemName)

        if not item then
            label.Text = "❌ " .. itemName .. " ไม่ขายในเวลานี้"
            return
        end

        local costNumbers = item:WaitForChild("Buy"):WaitForChild("Cost"):WaitForChild("Numbers")
        local itemCostText = costNumbers.Text or ""
        local cleanedText = itemCostText:gsub("[^%d]", "")
        local itemCost = tonumber(cleanedText)

        if itemCost then
            label.Text = "💰 " .. itemName .. ": " .. itemCost .. " Gem"
        else
            label.Text = "💸 ไม่สามารถอ่านราคา " .. itemName
            return
        end

        if itemCost <= maxPrice then
            local merchantRemote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server")
                :WaitForChild("Gameplay"):WaitForChild("Merchant")

            local args = {
                [1] = itemName,
                [2] = 1
            }

            for i = 1, 4 do
                merchantRemote:FireServer(unpack(args))
                task.wait(0.1)
            end
        else
            label.Text = "💸 " .. itemName .. " แพงเกินไป: " .. itemCost .. " Gem"
        end
    end

    checkAndBuyItem("Dr. Megga Punk", 5500, punkLabel)
    checkAndBuyItem("Trait Reroll", 1, rerollLabel)

    checkAndUpdateItems()

    task.spawn(function()
        while true do
            wait(1)
            checkAndUpdateItems()
        end
    end)
end

-- ▶️ เริ่มต้น GUI และแสดงผล
setupCompactStatusGUI()

