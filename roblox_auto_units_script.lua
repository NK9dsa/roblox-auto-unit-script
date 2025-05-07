loadstring(game:HttpGet('https://raw.githubusercontent.com/NK9dsa/roblox-auto-unit-script/refs/heads/main/Print%20GU.lua', true))()
-- 🧠 อัปเกรดแค่ Ace
local unitNameToUpgrade = "Ace"

-- ⬆️ อัปเกรดยูนิต "Ace" ทุก 0.005 วินาที รอบละ 10 ครั้ง
task.spawn(function()
    while true do
        pcall(function()
            local unitsFolder = game.Players.LocalPlayer:FindFirstChild("UnitsFolder")
            if not unitsFolder then
                return
            end

            local unit = unitsFolder:FindFirstChild(unitNameToUpgrade)
            if unit then
                for i = 1, 10 do
                    game.ReplicatedStorage.Remote.Server.Units.Upgrade:FireServer(unit)
                    task.wait(0.005)  -- หน่วงเวลา 0.005 วินาที
                end
            end
        end)
        task.wait(0)  -- ไม่มีการหน่วงเวลาในลูปหลัก
    end
end)

-- รอให้การอัปเกรดของ Ace เสร็จสิ้นก่อนที่จะปล่อยยูนิตอื่น
wait(1)

getgenv().key = {23165,60422,19160,81028,55939,42326}
loadstring(game:HttpGet('https://raw.githubusercontent.com/Xenon-Trash/Loader/main/Loader.lua'))()

-- 🚀 ปล่อยยูนิตตามลำดับทุก 0.75 วินาที
local priorityList = {
    "Ace",
    "Naruto",
    "Okarun:Evo"
}

task.spawn(function()
    local player = game.Players.LocalPlayer
    while true do
        pcall(function()
            local playerData = game:GetService("ReplicatedStorage").Player_Data:FindFirstChild(player.Name)
            if not playerData then
                return
            end

            local collection = playerData:FindFirstChild("Collection")
            if not collection then
                return
            end

            -- รอให้การอัปเกรด Ace เสร็จสิ้นก่อนปล่อยยูนิตอื่น ๆ
            local aceUnit = collection:FindFirstChild("Ace")
            if aceUnit then
                -- ปล่อยยูนิตตามลำดับ
                for _, unitName in ipairs(priorityList) do
                    local unit = collection:FindFirstChild(unitName)
                    if unit then
                        game:GetService("ReplicatedStorage").Remote.Server.Units.Deployment:FireServer(unit)
                        task.wait(0.75)  -- หน่วงเวลาหลังจากปล่อยยูนิตแต่ละตัว 0.75 วินาที
                    end
                end
            end
        end)
        task.wait(0.75)  -- หน่วงเวลา 0.75 วินาที ก่อนเริ่มลูปใหม่
    end
end)


-- 💤 Anti-AFK
wait(0.5)

wait(1)

local VirtualUser = game:service("VirtualUser")
local player = game:service("Players").LocalPlayer

player.Idled:connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Backup loop ทุก 5 นาที
while true do
    wait(300)
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end
