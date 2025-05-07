wait(10)

local playerName = "Cotech3883"
local items = {
    "Cursed Finger",
    "Dr. Megga Punk",
    "Trait Reroll",
    "Stats Key",
    "Ranger Crystal",
    "Perfect Stats Key"
}

local replicatedStorage = game:GetService("ReplicatedStorage")
local playerItems = replicatedStorage:WaitForChild("Player_Data"):WaitForChild(playerName):WaitForChild("Items")

-- สร้าง GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ItemCheckGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(0.5, 0, 0.6, 0)
textLabel.Position = UDim2.new(0.25, 0, 0.2, 0)
textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextScaled = true
textLabel.Font = Enum.Font.SourceSans
textLabel.Text = "กำลังโหลดข้อมูล..."
textLabel.Parent = screenGui

-- ฟังก์ชันอัปเดตข้อมูล
local function updateGUI()
    local output = "---- เช็คไอเทมของ " .. playerName .. " ----\n"
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

-- ลูปอัปเดตทุก 60 วินาที
while true do
    updateGUI()
    task.wait(60)
end
