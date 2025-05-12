task.spawn(function()
    local function upgradeUnit(unit, times)
        for i = 1, times do
            game.ReplicatedStorage.Remote.Server.Units.Upgrade:FireServer(unit)
            task.wait(0.001)
        end
    end

    local function deployUnit(unitName, unitsFolder)
        local unit = unitsFolder:FindFirstChild(unitName) or unitsFolder:FindFirstChild(unitName:gsub(":", ""))
        if unit then
            game.ReplicatedStorage.Remote.Server.Units.Deployment:FireServer(unit)
            print("✅ ปล่อยยูนิต: " .. unitName)
        else
            warn("⚠️ ไม่พบยูนิตใน UnitsFolder: " .. unitName)
        end
    end

    wait(1)
    getgenv().key = {23165,60422,19160,81028,55939,42326}
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Xenon-Trash/Loader/main/Loader.lua'))()

    while true do
        pcall(function()
            local player = game.Players.LocalPlayer
            local unitsFolder = player:FindFirstChild("UnitsFolder")
            if not unitsFolder then return end

            local gogeta = unitsFolder:FindFirstChild("Gogeta")
            local saber = unitsFolder:FindFirstChild("Saber:Evo") or unitsFolder:FindFirstChild("SaberEvo")
            local ace = unitsFolder:FindFirstChild("Ace")

            if not (gogeta and saber and ace) then return end

            local gogetaCost = gogeta:FindFirstChild("Upgrade_Folder") and gogeta.Upgrade_Folder:FindFirstChild("Upgrade_Cost")
            local aceCost = ace:FindFirstChild("Upgrade_Folder") and ace.Upgrade_Folder:FindFirstChild("Upgrade_Cost")

            if not (gogetaCost and aceCost) then return end

            -- ✅ ถ้า Gogeta ยังไม่ถึง 5000 ให้อัปเกรด 3 ครั้ง แล้วปล่อยเลย
            if gogetaCost.Value < 5000 then
                print("🔄 อัปเกรด Gogeta...")
                upgradeUnit(gogeta, 3)
            end
            deployUnit("Gogeta", unitsFolder)

            -- ✅ Ace อัปเกรดเรื่อย ๆ จนเกิน 2000 แล้วค่อยปล่อย
            while ace.Upgrade_Folder.Upgrade_Cost.Value <= 2000 do
                print("🔄 อัปเกรด Ace...")
                upgradeUnit(ace, 1)
                task.wait(0.05)
            end
            deployUnit("Ace", unitsFolder)

            -- ✅ ปล่อย Saber โดยไม่ต้องอัปเกรด
            deployUnit("Saber:Evo", unitsFolder)

        end)

        task.wait(0.25)
    end
end)

-- 💤 Anti-AFK
local VirtualUser = game:service("VirtualUser")
game:service("Players").LocalPlayer.Idled:connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

while true do
    wait(300)
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end
