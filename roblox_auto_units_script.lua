task.spawn(function()
    local function upgradeUnit(unit, times)
        for i = 1, times do
            game.ReplicatedStorage.Remote.Server.Units.Upgrade:FireServer(unit)
            task.wait(0.001) -- เร็วขึ้น
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
            local saberCost = saber:FindFirstChild("Upgrade_Folder") and saber.Upgrade_Folder:FindFirstChild("Upgrade_Cost")

            if not (gogetaCost and saberCost) then return end

            local gogetaReady = gogetaCost.Value >= 5000
            local saberReady = saberCost.Value >= 3500

            if gogetaReady and saberReady then
                upgradeUnit(ace, 1)

                local deployOrder = {"Gogeta", "Saber:Evo", "Ace"}
                for _, unitName in ipairs(deployOrder) do
                    local unit = unitsFolder:FindFirstChild(unitName) or unitsFolder:FindFirstChild(unitName:gsub(":", ""))
                    if unit then
                        game.ReplicatedStorage.Remote.Server.Units.Deployment:FireServer(unit)
                        print("✅ ปล่อยยูนิต: " .. unitName)
                        task.wait(0.3) -- เร็วขึ้นจาก 0.75
                    else
                        warn("⚠️ ไม่พบยูนิตใน UnitsFolder: " .. unitName)
                    end
                end
            else
                if not gogetaReady then upgradeUnit(gogeta, 3) end
                if not saberReady then upgradeUnit(saber, 1) end
                print("⏳ ยังไม่ถึงเงื่อนไขการปล่อยยูนิต กำลังอัปเกรด...")
            end
        end)

        task.wait(0.25) -- ลูปหลักเร็วขึ้น
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
