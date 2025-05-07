-- 🧠 ลิสต์ยูนิตตามลำดับความสำคัญ
local priorityList = {
    "Ace",
    "Naruto",
    -- ➕ เพิ่มยูนิตตามต้องการ
}

-- ⬆️ อัปเกรดยูนิตทุก 1 วินาที รอบละ 10 ครั้งต่อยูนิต ด้วยดีเลย์ 0.01 วินาที
local function upgradeUnits()
    task.spawn(function()
        while true do
            pcall(function()
                local unitsFolder = game.Players.LocalPlayer:FindFirstChild("UnitsFolder")
                if not unitsFolder then
                    return
                end

                for _, unitName in ipairs(priorityList) do
                    local unit = unitsFolder:FindFirstChild(unitName)
                    if unit then
                        for i = 1, 10 do
                            game.ReplicatedStorage.Remote.Server.Units.Upgrade:FireServer(unit)
                            task.wait(0.01)
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

-- 🚀 ปล่อยยูนิตตามลำดับทุก 0.75 วินาที
local function deployUnits()
    task.spawn(function()
        local player = game.Players.LocalPlayer
        while true do
            pcall(function()
                local playerData = game:GetService("ReplicatedStorage").Player_Data:FindFirstChild(player.Name)
                if not playerData then return end

                local collection = playerData:FindFirstChild("Collection")
                if not collection then return end

                for _, unitName in ipairs(priorityList) do
                    local unit = collection:FindFirstChild(unitName)
                    if unit then
                        game:GetService("ReplicatedStorage").Remote.Server.Units.Deployment:FireServer(unit)
                        task.wait(0.01)
                    end
                end
            end)
            task.wait(0.75)
        end
    end)
end

-- 💤 Anti-AFK
local function antiAFK()
    local VirtualUser = game:service("VirtualUser")
    local player = game:service("Players").LocalPlayer
    player.Idled:connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

    while true do
        wait(300)
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end

-- 📦 แสดงรายการไอเท็ม
local function monitorItems()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local items = ReplicatedStorage:WaitForChild("Player_Data"):WaitForChild(game.Players.LocalPlayer.Name):WaitForChild("Items")

    local itemList = {
        "Dr. Megga Punk",
        "Ranger Crystal",
        "Stats Key",
        "Trait Reroll",
        "Perfect Stats Key",
        "Cursed Finger"
    }

    local function printItemAmounts()
        print("📦 อัปเดตค่าของไอเท็ม:")
        for _, itemName in ipairs(itemList) do
            local item = items:FindFirstChild(itemName)
            if item then
                local amount = item:FindFirstChild("Amount")
                if amount and amount:IsA("ValueBase") then
                    print(itemName .. ": " .. tostring(amount.Value))
                else
                    print(itemName .. ": ⚠️ ไม่พบ Amount หรือไม่ใช่ ValueBase")
                end
            else
                print(itemName .. ": ❌ ไม่พบไอเท็มใน Items")
            end
        end
    end

    while true do
        printItemAmounts()
        wait(5)
    end
end

-- 🔑 โหลดคีย์และสคริปต์เสริม
getgenv().key = {23165,60422,19160,81028,55939,42326}
loadstring(game:HttpGet('https://raw.githubusercontent.com/Xenon-Trash/Loader/main/Loader.lua'))()

-- ▶️ เรียกใช้งาน
upgradeUnits()
deployUnits()
antiAFK()
monitorItems()
