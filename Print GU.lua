-- รอให้ LocalPlayer โหลดเสร็จ
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") -- รอ PlayerGui โหลดเสร็จ
local playerData = game:GetService("ReplicatedStorage"):WaitForChild("Player_Data"):WaitForChild(player.Name) -- รอ Player_Data โหลดเสร็จ

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

    -- เริ่มอัปเดตทุก 60 วินาที
    task.spawn(function()
        while true do
            updateGUI()
            task.wait(60)
        end
    end)
end

-- ตรวจสอบราคาและซื้อ Dr. Megga Punk
local function checkAndBuyPunk()
    local merchantGui = playerGui:WaitForChild("Merchant")
    local base = merchantGui:WaitForChild("Main"):WaitForChild("Base")
    local scroll = base:WaitForChild("Main"):WaitForChild("ScrollingFrame")
    local punk = scroll:FindFirstChild("Dr. Megga Punk")

    if not punk then
        warn("❌ ไม่พบ 'Dr. Megga Punk' ใน ScrollingFrame")
        return
    end

    local costNumbers = punk:WaitForChild("Buy"):WaitForChild("Cost"):WaitForChild("Numbers")
    local punkCostText = costNumbers.Text or ""
    local cleanedText = punkCostText:gsub("[^%d]", "")
    local punkCost = tonumber(cleanedText)

    print("💰 ค่า Dr. Megga Punk =", punkCost)

    if punkCost and punkCost <= 7000 then
        print("🛒 Dr. Megga Punk ราคาไม่เกิน 7000, กำลังซื้อ 4 ครั้ง...")

        local merchantRemote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server")
            :WaitForChild("Gameplay"):WaitForChild("Merchant")

        local args = {
            [1] = "Dr. Megga Punk",
            [2] = 1
        }

        for i = 1, 4 do
            print("📤 ส่งคำสั่งซื้อรอบที่", i)
            merchantRemote:FireServer(unpack(args))
            task.wait(0.1)
        end
    else
        print("💸 Dr. Megga Punk แพงเกินไป หรือไม่สามารถอ่านราคาได้: " .. tostring(punkCostText))
    end
end

-- เรียกใช้ฟังก์ชัน
setupItemCheckGUI()
checkAndBuyPunk()
