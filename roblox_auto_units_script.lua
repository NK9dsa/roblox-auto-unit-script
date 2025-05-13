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
            local saberCost = saber:FindFirstChild("Upgrade_Folder") and saber.Upgrade_Folder:FindFirstChild("Upgrade_Cost")
            local aceCost = ace:FindFirstChild("Upgrade_Folder") and ace.Upgrade_Folder:FindFirstChild("Upgrade_Cost")

            if not (gogetaCost and aceCost) then return end

            -- ✅ ถ้า Gogeta ยังไม่ถึง 5000 ให้อัปเกรด 3 ครั้ง
            if gogetaCost.Value < 5000 then
                print("🔄 อัปเกรด Gogeta...")
                upgradeUnit(gogeta, 3)
            end
            deployUnit("Gogeta", unitsFolder)

            -- ✅ ถ้า Ace ยังไม่ถึง 3500 ให้อัปเกรด
            if aceCost.Value < 3500 then
                print("🔁 อัปเกรด Ace ต่อเนื่อง... (" .. aceCost.Value .. ")")
                upgradeUnit(ace, 1)

            -- ✅ ถ้า Ace เท่ากับ 3500 ให้อัปเกรดยูนิตอื่นแทน
            elseif aceCost.Value == 3500 then
                print("🔁 Ace เต็มแล้ว ลองอัปเกรด Gogeta → Saber → Ace")

                if gogetaCost.Value < 99999 then
                    print("🔼 อัปเกรด Gogeta เพิ่มเติม")
                    upgradeUnit(gogeta, 1)
                elseif saberCost and saberCost.Value < 99999 then
                    print("🔼 อัปเกรด Saber เพิ่มเติม")
                    upgradeUnit(saber, 1)
                elseif aceCost.Value < 99999 then
                    print("🔼 อัปเกรด Ace ต่อ (หลัง 3500)")
                    upgradeUnit(ace, 1)
                end
            end

            -- ✅ ปล่อย Ace ถ้าเกิน 2000
            if aceCost.Value > 2000 then
                deployUnit("Ace", unitsFolder)
            end

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
