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

    -- 🔁 ตัวแปรสำหรับลูปอัปเกรดหลัง Ace == 3500
    local upgradeIndex = 1
    local upgradeCycle = {"Ace", "Saber", "Gogeta"}

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
            local aceCost = ace:FindFirstChild("Upgrade_Folder") and ace.Upgrade_Folder:FindFirstChild("Upgrade_Cost")

            if not (gogetaCost and aceCost) then return end

            -- ✅ เงื่อนไข Gogeta
            if gogetaCost.Value < 5000 then
                print("🔄 อัปเกรด Gogeta...")
                upgradeUnit(gogeta, 3)
            elseif gogetaCost.Value >= 5000 then
                print("🚀 ปล่อย Gogeta (Upgrade_Cost >= 5000)")
                deployUnit("Gogeta", unitsFolder)
            end

            -- ✅ เงื่อนไข Ace
            if aceCost.Value < 3500 then
                print("🔁 อัปเกรด Ace ต่อเนื่อง... (" .. aceCost.Value .. ")")
                upgradeUnit(ace, 1)

            elseif aceCost.Value == 3500 then
                print("🔁 Ace เต็มแล้ว ลำดับอัปเกรดวน Ace → Saber → Gogeta")

                local unitToUpgrade = upgradeCycle[upgradeIndex]

                if unitToUpgrade == "Ace" and aceCost.Value < 99999 then
                    print("🔼 อัปเกรด Ace (วนรอบ)")
                    upgradeUnit(ace, 1)
                elseif unitToUpgrade == "Saber" and saberCost and saberCost.Value < 99999 then
                    print("🔼 อัปเกรด Saber (วนรอบ)")
                    upgradeUnit(saber, 1)
                elseif unitToUpgrade == "Gogeta" and gogetaCost.Value < 99999 then
                    print("🔼 อัปเกรด Gogeta (วนรอบ)")
                    upgradeUnit(gogeta, 1)
                else
                    print("⚠️ ยูนิตที่ควรอัปเกรดยังเต็มอยู่ ข้ามรอบนี้")
                end

                -- วนไปยูนิตถัดไป
                upgradeIndex = upgradeIndex + 1
                if upgradeIndex > #upgradeCycle then
                    upgradeIndex = 1
                end
            end

            -- ✅ ปล่อย Ace ถ้าเกิน 2000
            if aceCost.Value > 2000 then
                deployUnit("Ace", unitsFolder)
            end

            -- ✅ ปล่อย Saber ตลอดเวลา
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
