task.spawn(function()
    local function upgradeUnit(unit, times)
        for i = 1, times do
            game.ReplicatedStorage.Remote.Server.Units.Upgrade:FireServer(unit)
            task.wait(0.001)
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

            local gogetaReady = gogetaCost.Value >= 5000
            local aceReady = aceCost.Value >= 2000

            if gogetaReady and aceReady then
                upgradeUnit(ace, 1)

                local deployOrder = {"Gogeta", "Saber:Evo", "Ace"}
                for _, unitName in ipairs(deployOrder) do
                    local unit = unitsFolder:FindFirstChild(unitName) or unitsFolder:FindFirstChild(unitName:gsub(":", ""))
                    if unit then
                        game.ReplicatedStorage.Remote.Server.Units.Deployment:FireServer(unit)
                        print("✅ ปล่อยยูนิต: " .. unitName)
                        task.wait(0.3)
                    else
                        warn("⚠️ ไม่พบยูนิตใน UnitsFolder: " .. unitName)
                    end
                end
            else
                if not gogetaReady then
                    upgradeUnit(gogeta, 3)
                    print("🔄 อัปเกรด Gogeta...")
                end
                if not aceReady then
                    upgradeUnit(ace, 1)
                    print("🔄 อัปเกรด Ace (ยังไม่ถึง 2000)...")
                end
                print("⏳ ยังไม่ถึงเงื่อนไขการปล่อยยูนิต กำลังอัปเกรด...")
            end
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
