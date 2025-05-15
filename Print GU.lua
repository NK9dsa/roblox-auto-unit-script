local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")

local url = "https://discord.com/api/webhooks/xxxxxxxxxxxxxxxxxxxxxxxxxxxx" -- ใส่ webhook ของคุณ

local player = Players.LocalPlayer or Players:GetPlayers()[1]
local placeId = game.PlaceId

-- 🔁 รีจอยเมื่อเจอ Error
GuiService.ErrorMessageChanged:Connect(function(err)
	if err and err ~= "" then
		print("🚨 ตรวจพบ Error: " .. err)
		task.wait(2)
		print("🔄 รีจอยเซิร์ฟเวอร์...")
		TeleportService:Teleport(placeId, player)
	end
end)

-- 🌐 Discord Embed
local function createItemEmbed(playerName, itemValue)
	return {{
		title = "Check Item ⌛ Easter Anime Rangers X",
		color = 13369344,
		fields = {
			{name = "**⭐ : ชื่อในเกม**", value = "**" .. playerName .. "**"},
			{name = "**👉🏻 : Cursed Finger**", value = "**" .. tostring(itemValue.CursedFinger or 0) .. "** ชิ้น"},
			{name = "**🧑🏻‍⚕️ : Dr. Megga Punk**", value = "**" .. tostring(itemValue.DrMeggaPunk or 0) .. "** ชิ้น"},
			{name = "**🔮 : Ranger Crystal**", value = "**" .. tostring(itemValue.RangerCrystal or 0) .. "** ชิ้น"},
			{name = "**📊 : Stats Key**", value = "**" .. tostring(itemValue.StatsKey or 0) .. "** ชิ้น"},
			{name = "**🎲 : Trait Reroll**", value = "**" .. tostring(itemValue.TraitReroll or 0) .. "** ชิ้น"},
			{name = "**🥚 : Egg**", value = "**" .. tostring(itemValue.Egg or 0) .. "** ชิ้น"},
		},
		footer = {
			text = "By Kantinan",
			icon_url = "https://i.imgur.com/YOUR_FOOTER_ICON.jpg" -- เปลี่ยนเป็นลิงก์ภาพถาวร
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

local function sendToDiscord(playerName, itemValue)
	local payload = {
		content = nil,
		embeds = createItemEmbed(playerName, itemValue),
		username = "Kantinan Hub",
		avatar_url = "https://i.imgur.com/YOUR_AVATAR.jpg", -- เปลี่ยนเป็นลิงก์ภาพถาวร
	}

	local body = HttpService:JSONEncode(payload)
	local headers = {["Content-Type"] = "application/json"}

	local requestFunc = http_request or request or HttpPost or (syn and syn.request)

	if not requestFunc then
		warn("❌ ไม่มีฟังก์ชันส่ง HTTP Request ในสภาพแวดล้อมนี้")
		return
	end

	local success, response = pcall(function()
		return requestFunc({
			Url = url,
			Method = "POST",
			Headers = headers,
			Body = body
		})
	end)

	if success then
		print("✅ ส่งข้อมูลไป Discord สำเร็จ")
	else
		warn("❌ ส่งข้อมูลล้มเหลว: " .. tostring(response))
	end
end

-- 🔍 อ่านค่าจาก Player_Data
local function getPlayerItemData(playerName)
	local data = ReplicatedStorage:WaitForChild("Player_Data"):FindFirstChild(playerName)
	if not data then return nil end

	local items = data:FindFirstChild("Items")
	local egg = data:FindFirstChild("Data") and data.Data:FindFirstChild("Egg")

	if not items or not egg then return nil end

	return {
		CursedFinger = items:FindFirstChild("Cursed Finger") and items["Cursed Finger"]:FindFirstChild("Amount") and items["Cursed Finger"].Amount.Value or 0,
		DrMeggaPunk = items:FindFirstChild("Dr. Megga Punk") and items["Dr. Megga Punk"]:FindFirstChild("Amount") and items["Dr. Megga Punk"].Amount.Value or 0,
		RangerCrystal = items:FindFirstChild("Ranger Crystal") and items["Ranger Crystal"]:FindFirstChild("Amount") and items["Ranger Crystal"].Amount.Value or 0,
		StatsKey = items:FindFirstChild("Stats Key") and items["Stats Key"]:FindFirstChild("Amount") and items["Stats Key"].Amount.Value or 0,
		TraitReroll = items:FindFirstChild("Trait Reroll") and items["Trait Reroll"]:FindFirstChild("Amount") and items["Trait Reroll"].Amount.Value or 0,
		Egg = egg.Value or 0
	}
end

-- 🧠 เปรียบเทียบค่าก่อนหน้า
local previousValues = {}

local function shouldSendUpdate(playerName, currentData)
	local previous = previousValues[playerName]

	if not previous then
		previousValues[playerName] = currentData
		return false
	end

	for key, value in pairs(currentData) do
		if value > (previous[key] or 0) then
			previousValues[playerName] = currentData
			return true
		end
	end

	return false
end

-- 📡 Listener
local function setupListeners(playerName)
	local data = ReplicatedStorage:WaitForChild("Player_Data"):FindFirstChild(playerName)
	if not data then return end

	local items = data:FindFirstChild("Items")
	local egg = data:FindFirstChild("Data") and data.Data:FindFirstChild("Egg")

	if not items or not egg then return end

	local function onValueChanged()
		local currentData = getPlayerItemData(playerName)
		if currentData and shouldSendUpdate(playerName, currentData) then
			print("🆕 มีไอเทมเพิ่มขึ้นของผู้เล่น: " .. playerName)
			sendToDiscord(playerName, currentData)
		else
			print("⏹️ ไม่มีไอเทมเพิ่มขึ้น")
		end
	end

	for _, item in pairs(items:GetChildren()) do
		local amount = item:FindFirstChild("Amount")
		if amount and amount:IsA("NumberValue") then
			amount.Changed:Connect(onValueChanged)
		end
	end

	egg.Changed:Connect(onValueChanged)
end

-- 🚀 เริ่มต้น
if player then
	setupListeners(player.Name)
	local initial = getPlayerItemData(player.Name)
	if initial then
		previousValues[player.Name] = initial -- เก็บค่าเริ่มต้น
	end
else
	warn("❌ ไม่พบผู้เล่น")
end
