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
local playerItems = replicatedStorage.Player_Data[playerName].Items

while true do
    print("---- เช็คไอเทมของ " .. playerName .. " ----")
    for _, itemName in ipairs(items) do
        local item = playerItems[itemName]
        if item and item:FindFirstChild("Amount") then
            print(itemName .. ": " .. item.Amount.Value)
        else
            print(itemName .. ": ไม่พบข้อมูลหรือไม่มี Amount")
        end
    end
    print("-----------------------------\n")
    task.wait(60) -- รอ 60 วินาทีก่อนลูปรอบถัดไป
end