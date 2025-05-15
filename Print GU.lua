wait(10)
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- URL ของ Webhook
local url = "https://discord.com/api/webhooks/1369517947772473355/hfXw_5A0X4u7ZXJapgBmJZTp94dDjNqgze39XExEgNPmriwGG2eoOwhXY7Ty5qS_fDFH"

-- ตัวแปรเก็บเวลาเริ่มต้นและจำนวนที่เก็บไว้
local startTime = tick()  -- เวลาที่เริ่มทำงาน (เริ่มนับเวลา)
local eggStartValue = 0  -- ค่าเริ่มต้นของจำนวน Egg

-- ตัวแปรเก็บข้อมูลของไอเทมก่อนหน้า
local previousItemValues = {}

-- ฟังก์ชันสร้าง Embed
local function createItemEmbed(playerName, itemValue, eggValue)
    return {{
        title = "Check Item ⌛ Easter Anime Rangers X",  -- ใช้ชื่อเกมแทนชื่อผู้เล่นใน title
        color = 13369344,
        fields = {
            -- เพิ่มฟิลด์ชื่อผู้เล่น
            {name = "**⭐ : ชื่อในเกม**", value = "**" .. playerName .. "**"},
            {name = "**👉🏻 : Cursed Finger**", value = "**" .. tostring(itemValue.CursedFinger or 0) .. "** ชิ้น"},
            {name = "**🧑🏻‍⚕️ : Dr. Megga Punk**", value = "**" .. tostring(itemValue.DrMeggaPunk or 0) .. "** ชิ้น"},
            {name = "**🔮 : Ranger Crystal**", value = "**" .. tostring(itemValue.RangerCrystal or 0) .. "** ชิ้น"},
            {name = "**📊 : Stats Key**", value = "**" .. tostring(itemValue.StatsKey or 0) .. "** ชิ้น"},
            {name = "**🎲 : Trait Reroll**", value = "**" .. tostring(itemValue.TraitReroll or 0) .. "** ชิ้น"},
            {name = "**🥚 : Egg**", value = "**" .. tostring(eggValue or 0) .. "** ชิ้น"}
        },
        footer = {
            text = "By Kantinan",
            icon_url = "https://scontent.fbkk17-1.fna.fbcdn.net/v/t39.30808-6/475981006_504564545992490_6167097446539934981_n.jpg?stp=cp6_dst-jpg_tt6&_nc_cat=109&ccb=1-7&_nc_sid=a5f93a&_nc_eui2=AeHuukcGpQpj4XE6MBQQ0r3Nv9RNGZXPQTy_1E0Zlc9BPOnBHgFknkvfEHS89dJlVN2oXCQw6AY_2AUE3Se97cpN&_nc_ohc=UAg9nywGDuoQ7kNvwE_aDd-&_nc_oc=AdkzHcGmX861r-vYAIJrKp5Hf-FKsiGV8WNd7wo3zyIrfUBVPyZl1WnkzzRr3onNyNE&_nc_zt=23&_nc_ht=scontent.fbkk17-1.fna&_nc_gid=h4GL0vLpIHXjY2I2GkZf3Q&oh=00_AfK_3qJJGCKu-TYg75zH1c4xDwNQHETnI1iA_FC8sYXx9g&oe=682B1594"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        image = {
            url = "https://tr.rbxcdn.com/180DAY-55b32ceb45515e38d3b7d6650a0a2304/768/432/Image/Webp/noFilter"
        },
        thumbnail = {
            url = "https://static.wikitide.net/animerangerxwiki/2/26/ARXLogo.png"
        }
    }}
end

-- ฟังก์ชันส่งข้อมูลไป Discord
local function sendToDiscord(playerName, itemValue, eggValue)
    local payload = {
        content = nil,
        embeds = createItemEmbed(playerName, itemValue, eggValue),
        username = "Kantinan Hub",  -- ชื่อของบอท
        avatar_url = "https://scontent.fbkk17-1.fna.fbcdn.net/v/t39.30808-6/475981006_504564545992490_6167097446539934981_n.jpg?stp=cp6_dst-jpg_tt6&_nc_cat=109&ccb=1-7&_nc_sid=a5f93a&_nc_eui2=AeHuukcGpQpj4XE6MBQQ0r3Nv9RNGZXPQTy_1E0Zlc9BPOnBHgFknkvfEHS89dJlVN2oXCQw6AY_2AUE3Se97cpN&_nc_ohc=UAg9nywGDuoQ7kNvwE_aDd-&_nc_oc=AdkzHcGmX861r-vYAIJrKp5Hf-FKsiGV8WNd7wo3zyIrfUBVPyZl1WnkzzRr3onNyNE&_nc_zt=23&_nc_ht=scontent.fbkk17-1.fna&_nc_gid=h4GL0vLpIHXjY2I2GkZf3Q&oh=00_AfK_3qJJGCKu-TYg75zH1c4xDwNQHETnI1iA_FC8sYXx9g&oe=682B1594",  -- ไอคอนของบอท
        attachments = {}
    }

    local body = HttpService:JSONEncode(payload)
    local headers = {["Content-Type"] = "application/json"}

    local requestFunc = http_request or request or HttpPost
    local success, err = pcall(function()
        requestFunc({
            Url = url,
            Method = "POST",
            Headers = headers,
            Body = body
        })
    end)

    if not success then
        warn("❌ ไม่สามารถส่งข้อมูลไปยัง Discord: " .. tostring(err))
    end
end

-- ฟังก์ชันเช็คข้อมูลไอเทมจาก ReplicatedStorage
local function checkItems()
    local playerName = "REMM_XD" -- ชื่อผู้เล่นที่ต้องการเช็ค
    local playerItemsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Player_Data"):WaitForChild(playerName):WaitForChild("Items")
    local playerEggValue = game:GetService("ReplicatedStorage"):WaitForChild("Player_Data"):WaitForChild(playerName):WaitForChild("Data"):WaitForChild("Egg")
    
    -- เช็คว่าได้รับข้อมูลเกี่ยวกับ Egg และ Items
    if not playerItemsFolder then
        print("❌ ไม่พบ Items folder สำหรับผู้เล่น: " .. playerName)
        return
    end
    
    if not playerEggValue then
        print("❌ ไม่พบค่า Egg สำหรับผู้เล่น: " .. playerName)
        return
    end

    -- เช็คค่าไอเทมทั้งหมดจาก Items
    local itemInfo = {
        CursedFinger = playerItemsFolder:FindFirstChild("Cursed Finger") and playerItemsFolder["Cursed Finger"]:FindFirstChild("Amount") and playerItemsFolder["Cursed Finger"].Amount.Value or 0,
        DrMeggaPunk = playerItemsFolder:FindFirstChild("Dr. Megga Punk") and playerItemsFolder["Dr. Megga Punk"]:FindFirstChild("Amount") and playerItemsFolder["Dr. Megga Punk"].Amount.Value or 0,
        RangerCrystal = playerItemsFolder:FindFirstChild("Ranger Crystal") and playerItemsFolder["Ranger Crystal"]:FindFirstChild("Amount") and playerItemsFolder["Ranger Crystal"].Amount.Value or 0,
        StatsKey = playerItemsFolder:FindFirstChild("Stats Key") and playerItemsFolder["Stats Key"]:FindFirstChild("Amount") and playerItemsFolder["Stats Key"].Amount.Value or 0,
        TraitReroll = playerItemsFolder:FindFirstChild("Trait Reroll") and playerItemsFolder["Trait Reroll"]:FindFirstChild("Amount") and playerItemsFolder["Trait Reroll"].Amount.Value or 0
    }

    -- ค่า Egg
    local eggValue = playerEggValue.Value or 0

    -- เช็คว่าไอเทมมีการเปลี่ยนแปลงหรือไม่
    if previousItemValues.CursedFinger ~= itemInfo.CursedFinger or
       previousItemValues.DrMeggaPunk ~= itemInfo.DrMeggaPunk or
       previousItemValues.RangerCrystal ~= itemInfo.RangerCrystal or
       previousItemValues.StatsKey ~= itemInfo.StatsKey or
       previousItemValues.TraitReroll ~= itemInfo.TraitReroll then

        -- ส่งข้อมูลไปที่ Discord
        sendToDiscord(playerName, itemInfo, eggValue)

        -- อัปเดตค่าของไอเทมที่เก็บไว้
        previousItemValues = itemInfo
    end
end

-- เรียกใช้งานฟังก์ชันเช็คไอเทม
checkItems()


-- 📦 Services
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local placeId = game.PlaceId

-- ⛑️ ป้องกันหลุด และรีจอยหากพบ Error
GuiService.ErrorMessageChanged:Connect(function(err)
    if err and err ~= "" then
        print("🚨 ตรวจพบ Error: " .. err)

        -- ตรวจสอบข้อความที่อาจหมายถึง Error 267
        if string.find(err, "kicked") or string.find(err, "Kick") then
            print("❌ ผู้เล่นถูกเตะออกจากเกม (Error 267) ไม่พยายามรีจอย")
            return
        end

        -- รอ 2 วินาทีแล้วพยายามรีจอย
        task.wait(2)
        print("🔄 กำลังพยายามรีจอยเซิร์เวอร์...")
        TeleportService:Teleport(placeId, player)
    else
        print("✅ ไม่มี Error, ทุกอย่างปกติ")
    end
end)


print("📌 ระบบป้องกันหลุดทำงานแล้ว")

-- 🏋️ Anti-AFK
local VirtualUser = game:service("VirtualUser")
player.Idled:connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- 🔁 Backup click ทุก 5 นาที
task.spawn(function()
    while true do
        wait(300)
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- 📊 GUI แสดง Egg + ไอเทมทั้งหมดแบบรวมในกล่องเดียว
local playerData = ReplicatedStorage:WaitForChild("Player_Data"):WaitForChild(player.Name)

-- 🕒 ตัวแปรใช้คำนวณ Egg ต่อชั่วโมง
local startTime = os.clock()
local startEggCount = 0

local function setupCompactStatusGUI()
    local existing = playerGui:FindFirstChild("CompactStatusGui")
    if existing then existing:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "CompactStatusGui"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    local label = Instance.new("TextLabel")
    label.Name = "StatusLabel"
    label.Size = UDim2.new(0, 180, 0, 150)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 0.3
    label.TextScaled = true
    label.Font = Enum.Font.Cartoon
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Text = "📦 กำลังโหลดข้อมูล..."
    label.Parent = gui

    local items = {
        "Cursed Finger",
        "Stats Key",
        "Ranger Crystal",
        "Trait Reroll",
        "Dr. Megga Punk"
    }

    local playerItems = playerData:WaitForChild("Items")

    local function checkAndUpdateItems()
        local lines = {}
        table.insert(lines, "👤 " .. player.Name)

        local success, eggValue = pcall(function()
            return playerData:WaitForChild("Data"):WaitForChild("Egg").Value
        end)

        if success then
            if startEggCount == 0 then
                startEggCount = eggValue
            end
            local elapsedTime = os.clock() - startTime
            local eggDiff = eggValue - startEggCount
            local eggsPerHour = math.floor((eggDiff / elapsedTime) * 3600)
            table.insert(lines, "🥚 Egg: " .. eggValue .. " (≈ " .. eggsPerHour .. "/ชม.)")
        else
            table.insert(lines, "🥚 Egg: ❌")
        end

        for _, itemName in ipairs(items) do
            local item = playerItems:FindFirstChild(itemName)
            if item and item:FindFirstChild("Amount") then
                table.insert(lines, "📦 " .. itemName .. ": " .. item.Amount.Value)
            else
                table.insert(lines, "📦 " .. itemName .. ": -")
            end
        end

        label.Text = table.concat(lines, "\n")
    end

    local function createItemCheckLabel(yPosition, itemName)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 180, 0, 30)
        label.Position = UDim2.new(0, 10, 0, yPosition)
        label.AnchorPoint = Vector2.new(0, 0)
        label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.BackgroundTransparency = 0.3
        label.TextScaled = true
        label.Font = Enum.Font.Cartoon
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = "กำลังตรวจสอบ " .. itemName .. "..."
        label.Parent = gui
        return label
    end

    local punkLabel = createItemCheckLabel(160, "Dr. Megga Punk")
    local rerollLabel = createItemCheckLabel(200, "Trait Reroll")

    local function checkAndBuyItem(itemName, maxPrice, label)
        local gemValue = playerData:WaitForChild("Data"):WaitForChild("Gem").Value
        if gemValue == 37500 then
            label.Text = "⛔️ หยุดซื้อ " .. itemName .. " เพราะ Gem = 37500"
            return
        end

        local merchantGui = playerGui:WaitForChild("Merchant")
        local base = merchantGui:WaitForChild("Main"):WaitForChild("Base")
        local scroll = base:WaitForChild("Main"):WaitForChild("ScrollingFrame")
        local item = scroll:FindFirstChild(itemName)

        if not item then
            label.Text = "❌ " .. itemName .. " ไม่ขายในเวลานี้"
            return
        end

        local costNumbers = item:WaitForChild("Buy"):WaitForChild("Cost"):WaitForChild("Numbers")
        local itemCostText = costNumbers.Text or ""
        local cleanedText = itemCostText:gsub("[^%d]", "")
        local itemCost = tonumber(cleanedText)

        if itemCost then
            label.Text = "💰 " .. itemName .. ": " .. itemCost .. " Gem"
        else
            label.Text = "💸 ไม่สามารถอ่านราคา " .. itemName
            return
        end

        if itemCost <= maxPrice then
            local merchantRemote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server")
                :WaitForChild("Gameplay"):WaitForChild("Merchant")

            local args = {
                [1] = itemName,
                [2] = 1
            }

            for i = 1, 4 do
                merchantRemote:FireServer(unpack(args))
                task.wait(0.1)
            end
        else
            label.Text = "💸 " .. itemName .. " แพงเกินไป: " .. itemCost .. " Gem"
        end
    end

    checkAndBuyItem("Dr. Megga Punk", 1, punkLabel)
    checkAndBuyItem("Trait Reroll", 1, rerollLabel)

    checkAndUpdateItems()

    task.spawn(function()
        while true do
            wait(1)
            checkAndUpdateItems()
        end
    end)
end

-- ▶️ เริ่มต้น GUI และแสดงผล
setupCompactStatusGUI()

