wait(10)
-- LocalScript ที่ StarterPlayerScripts
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local placeId = game.PlaceId

game:GetService("GuiService").ErrorMessageChanged:Connect(function(err)
    if err and err ~= "" then
        print("🚨 ตรวจพบ Error: " .. err)
        
        -- รอเล็กน้อยก่อนทำ Teleport
        task.wait(2)
        
        print("🔄 กำลังพยายามรีจอยเซิร์ฟเวอร์...")
        TeleportService:Teleport(placeId, player)
    else
        print("✅ ไม่มี Error, ทุกอย่างปกติ")
    end
end)

print("ป้องกันการหลุดแล้ว")
-- รอให้ LocalPlayer โหลดเสร็จ
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") -- รอ PlayerGui โหลดเสร็จ
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerData = ReplicatedStorage:WaitForChild("Player_Data"):WaitForChild(player.Name) -- รอ Player_Data โหลดเสร็จ

-- เช็คและแสดง GUI ข้อมูลไอเทม
local function setupItemCheckGUI()
    -- ลบ GUI เดิมถ้ามี
    local existingGui = playerGui:FindFirstChild("ItemCheckGui")
    if existingGui then
        existingGui:Destroy()
    end

    -- สร้าง GUI ใหม่
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ItemCheckGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.5, 0, 0.6, 0)
    textLabel.Position = UDim2.new(0.25, 0, 0.2, 0)
    textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSans
    textLabel.Text = "กำลังโหลดข้อมูล..."
    textLabel.Parent = screenGui

    local items = {
        "Cursed Finger",
        "Dr. Megga Punk",
        "Trait Reroll",
        "Stats Key",
        "Ranger Crystal",
        "Perfect Stats Key"
    }

    local playerItems = playerData:WaitForChild("Items")

    local function updateGUI()
        local output = "---- เช็คไอเทมของ " .. player.Name .. " ----\n"
        for _, itemName in ipairs(items) do
            local item = playerItems:FindFirstChild(itemName)
            if item and item:FindFirstChild("Amount") then
                output = output .. itemName .. ": " .. item.Amount.Value .. "\n"
            else
                output = output .. itemName .. ": ไม่พบข้อมูลหรือไม่มี Amount\n"
            end
        end
        output = output .. "-----------------------------"
        textLabel.Text = output
    end

    -- เริ่มอัปเดตทุก 1 วินาที
    task.spawn(function()
        while true do
            updateGUI()
            task.wait(1)
        end
    end)

    -- สร้าง TextLabel สำหรับแสดงราคา Dr. Megga Punk
    local punkPriceLabel = Instance.new("TextLabel")
    punkPriceLabel.Size = UDim2.new(0.5, 0, 0.1, 0)
    punkPriceLabel.Position = UDim2.new(0.5, 0, 0, 0)
    punkPriceLabel.AnchorPoint = Vector2.new(0.5, 0)
    punkPriceLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    punkPriceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    punkPriceLabel.TextScaled = true
    punkPriceLabel.Font = Enum.Font.SourceSans
    punkPriceLabel.Text = "กำลังโหลดราคา Dr. Megga Punk..."
    punkPriceLabel.Parent = screenGui

    -- สร้าง TextLabel สำหรับ Trait Reroll
    local rerollLabel = Instance.new("TextLabel")
    rerollLabel.Size = UDim2.new(0.5, 0, 0.1, 0)
    rerollLabel.Position = UDim2.new(0.5, 0, 0.1, 0)
    rerollLabel.AnchorPoint = Vector2.new(0.5, 0)
    rerollLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    rerollLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    rerollLabel.TextScaled = true
    rerollLabel.Font = Enum.Font.SourceSans
    rerollLabel.Text = "กำลังโหลดราคา Trait Reroll..."
    rerollLabel.Parent = screenGui

    return punkPriceLabel, rerollLabel
end

-- ตรวจสอบและซื้อไอเทมตามชื่อและราคาสูงสุด
local function checkAndBuyItem(itemName, maxPrice, label)
    local merchantGui = playerGui:WaitForChild("Merchant")
    local base = merchantGui:WaitForChild("Main"):WaitForChild("Base")
    local scroll = base:WaitForChild("Main"):WaitForChild("ScrollingFrame")
    local item = scroll:FindFirstChild(itemName)

    if not item then
        label.Text = "❌ " .. itemName .. " ไม่ขายในเวลานี้"
        print("❌ ไม่พบ '" .. itemName .. "' ใน ScrollingFrame")
        return
    end

    local costNumbers = item:WaitForChild("Buy"):WaitForChild("Cost"):WaitForChild("Numbers")
    local itemCostText = costNumbers.Text or ""
    local cleanedText = itemCostText:gsub("[^%d]", "")
    local itemCost = tonumber(cleanedText)

    if itemCost then
        label.Text = "💰 " .. itemName .. ": " .. itemCost .. " Gem"
        print("💰 ค่า " .. itemName .. " =", itemCost)
    else
        label.Text = "💸 ไม่สามารถอ่านราคา " .. itemName
        return
    end

    if itemCost <= maxPrice then
        print("🛒 " .. itemName .. " ราคาไม่เกิน " .. maxPrice .. ", กำลังซื้อ 4 ครั้ง...")

        local merchantRemote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server")
            :WaitForChild("Gameplay"):WaitForChild("Merchant")

        local args = {
            [1] = itemName,
            [2] = 1
        }

        for i = 1, 4 do
            print("📤 ส่งคำสั่งซื้อ " .. itemName .. " รอบที่", i)
            merchantRemote:FireServer(unpack(args))
            task.wait(0.1)
        end
    else
        print("💸 " .. itemName .. " แพงเกินไป: " .. itemCost)
        label.Text = "💸 " .. itemName .. " แพงเกินไป: " .. itemCost .. " Gem"
    end
end

-- เรียกใช้ฟังก์ชัน
local punkPriceLabel, rerollLabel = setupItemCheckGUI()
checkAndBuyItem("Dr. Megga Punk", 6500, punkPriceLabel)
checkAndBuyItem("Trait Reroll", 850, rerollLabel)
