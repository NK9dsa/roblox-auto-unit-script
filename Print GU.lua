wait(10)
-- LocalScript ที่ StarterPlayerScripts
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local placeId = game.PlaceId

game:GetService("GuiService").ErrorMessageChanged:Connect(function(err)
    if err and err ~= "" then
        print("🚨 ตรวจพบ Error: " .. err)
        task.wait(2)
        print("🔄 กำลังพยายามรีจอยเซิร์ฟเวอร์...")
        TeleportService:Teleport(placeId, player)
    else
        print("✅ ไม่มี Error, ทุกอย่างปกติ")
    end
end)

print("ป้องกันการหลุดแล้ว")

local playerGui = player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerData = ReplicatedStorage:WaitForChild("Player_Data"):WaitForChild(player.Name)

-- GUI แสดงไอเทม
local function setupItemCheckGUI()
    local existingGui = playerGui:FindFirstChild("ItemCheckGui")
    if existingGui then existingGui:Destroy() end

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
    textLabel.Font = Enum.Font.Cartoon
    textLabel.Text = "กำลังโหลดข้อมูล..."
    textLabel.FontFace.Weight = Enum.FontWeight.Bold
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

    task.spawn(function()
        while true do
            updateGUI()
            task.wait(1)
        end
    end)

    local function createInfoLabel(yPosition)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 0.1, 0)
        label.Position = UDim2.new(0.5, 0, yPosition, 0)
        label.AnchorPoint = Vector2.new(0.5, 0)
        label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.Font = Enum.Font.Cartoon
        label.FontFace.Weight = Enum.FontWeight.Bold
        label.Text = "กำลังโหลด..."
        label.Parent = screenGui
        return label
    end

    local punkPriceLabel = createInfoLabel(0)
    local rerollLabel = createInfoLabel(0.1)

    return punkPriceLabel, rerollLabel
end

-- ตรวจสอบและซื้อไอเทม
local function checkAndBuyItem(itemName, maxPrice, label)
    local gemValue = playerData:WaitForChild("Data"):WaitForChild("Gem").Value
    if gemValue == 37500 then
        print("⛔ หยุดซื้อเพราะ Gem เท่ากับ 37500")
        label.Text = "⛔ หยุดซื้อ " .. itemName .. " เพราะ Gem เท่ากับ 37500"
        return
    end

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

-- เรียกใช้งาน
local punkPriceLabel, rerollLabel = setupItemCheckGUI()
checkAndBuyItem("Dr. Megga Punk", 8500, punkPriceLabel)
checkAndBuyItem("Trait Reroll", 800, rerollLabel)
