-- 🧩 SERVICES
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")

-- 🧑 PLAYER
local player = Players.LocalPlayer
local playerName = player.Name
local placeId = game.PlaceId
local fileName = playerName .. ".txt"

-- 🕒 FORMAT TIME
local function formatTime(seconds)
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60
	return string.format("%02d:%02d:%02d", h, m, s)
end

-- 📄 CREATE DEFAULT FILE
local function createDefaultFile(totalPlayTime)
	local defaultContent = string.format(
[[เวลาเริ่มฟามคือ %d
ฟามไป 00:00:00
สิ้นสุดงานที่ 24:00:00
https://discord.com/api/webhooks/your_webhook_here
]], totalPlayTime)
	writefile(fileName, defaultContent)
end

-- 📂 READ FILE
local function readFarmFile()
	if not isfile(fileName) then return nil, nil, "N/A" end
	local content = readfile(fileName)
	local lines = {}
	for line in content:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end
	local startTimeLine = lines[1] or "เวลาเริ่มฟามคือ 0"
	local endWorkLine = lines[3] or "สิ้นสุดงานที่ N/A"
	local webhookUrl = lines[4] or nil
	local startTime = tonumber(startTimeLine:match("%d+")) or 0
	local endWorkTime = endWorkLine:match("%d+:%d+:%d+") or "N/A"
	return startTime, webhookUrl, endWorkTime
end

-- 📬 SEND EMBED
local function sendToDiscordEmbed(data, webhook, endWorkTime)
	if not webhook or webhook == "" then warn("❌ ไม่มี Webhook URL") return end
	local farmDisplay = data.FarmTime .. " / " .. (endWorkTime or "N/A")

	local payload = {
		username = "TORAKI SHOP",
		avatar_url = "https://media.discordapp.net/attachments/1150536492687556700/1177337077289980025/toraki.gif",
		content = nil,
		embeds = {{
			title = "Check Items",
			color = 16711680,
			fields = {
				{name = "⭐ : ชื่อในเกม", value = "||" .. (data.PlayerName or "N/A") .. "||", inline = false},
				{name = "⌛ : ฟาร์มไปแล้ว", value = farmDisplay, inline = false},
				{name = "<:75pxGem:1375439282277453867>", value = data.Gem, inline = true},
				{name = "<:Gold:1362221819683409950>", value = data.Gold, inline = true},
				{name = "<:75pxTrait_Reroll:1375439273423011850>", value = data.TraitReroll, inline = true},
				{name = "<:75pxRanger_Crystal:1375439279026602076>", value = data.RangerCrystal, inline = true},
				{name = "<:Dr_Megga_Punk:1375438636480467026>", value = data.DrMeggaPunk, inline = true},
				{name = "<:75pxCursed_Finger:1375450781934948352>", value = data.CursedFinger, inline = true},
				{name = "<:75pxGhoul_City_Portal_I:1375439287255957584> I", value = data.GhoulCityPortalI, inline = true},
				{name = "<:75pxGhoul_City_Portal_I:1375439287255957584> II", value = data.GhoulCityPortalII, inline = true},
				{name = "<:75pxGhoul_City_Portal_I:1375439287255957584> III", value = data.GhoulCityPortalIII, inline = true}
			},
			author = {name = "[🩸 UPDATE 1] Anime Rangers X"},
			footer = {icon_url = "https://media.discordapp.net/attachments/1150536492687556700/1177337077289980025/toraki.gif"},
			image = {url = "https://tr.rbxcdn.com/180DAY-ca8de067b9ea25af3b3d5485d16dcbcc/500/280/Image/Jpeg/noFilter"},
			timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
		}}
	}

	local headers = {["Content-Type"] = "application/json"}
	local json = HttpService:JSONEncode(payload)
	local request = http_request or request or (syn and syn.request)

	if request then
		local success, err = pcall(function()
			request({Url = webhook, Method = "POST", Headers = headers, Body = json})
		end)
		if success then print("✅ ส่ง Embed ไป Discord เรียบร้อย") else warn("❌ ส่ง Embed ล้มเหลว: " .. tostring(err)) end
	else
		warn("❌ ไม่พบฟังก์ชันส่ง HTTP Request")
	end
end

-- ▶️ ทำงานหลัก 1 รอบ
local function runOnce()
	local folder = ReplicatedStorage:WaitForChild("Player_Data"):FindFirstChild(playerName)
	if not folder then warn("❌ ไม่พบ Player_Data สำหรับผู้เล่น") return end
	local data = folder:FindFirstChild("Data")
	local items = folder:FindFirstChild("Items")
	local profile = folder:FindFirstChild("Profile")
	if not data or not items or not profile or not profile:FindFirstChild("TotalPlayTime") then
		warn("❌ ไม่พบข้อมูลสำคัญ") return
	end

	local totalPlayTime = profile.TotalPlayTime.Value
	if not isfile(fileName) then createDefaultFile(totalPlayTime) end

	local startTime, webhookUrl, endWorkTime = readFarmFile()
	if not startTime then warn("❌ ไม่พบเวลาเริ่มฟาร์ม") return end

	local farmedSeconds = math.max(0, totalPlayTime - startTime)
	local formattedFarmTime = formatTime(farmedSeconds)

	local function getItemAmount(name)
		local item = items:FindFirstChild(name)
		return (item and item:FindFirstChild("Amount")) and tostring(item.Amount.Value) or "N/A"
	end

	local dataToSend = {
		PlayerName = playerName,
		FarmTime = formattedFarmTime,
		Gem = data:FindFirstChild("Gem") and tostring(data.Gem.Value) or "N/A",
		Gold = data:FindFirstChild("Gold") and tostring(data.Gold.Value) or "N/A",
		TraitReroll = getItemAmount("Trait Reroll"),
		RangerCrystal = getItemAmount("Ranger Crystal"),
		DrMeggaPunk = getItemAmount("Dr. Megga Punk"),
		CursedFinger = getItemAmount("Cursed Finger"),
		GhoulCityPortalI = getItemAmount("Ghoul City Portal I"),
		GhoulCityPortalII = getItemAmount("Ghoul City Portal II"),
		GhoulCityPortalIII = getItemAmount("Ghoul City Portal III"),
	}

	sendToDiscordEmbed(dataToSend, webhookUrl, endWorkTime)
end

-- 🔁 ลูปส่งข้อมูลทุก 60 วิ
task.spawn(function()
	while true do
		local success, err = pcall(runOnce)
		if not success then warn("❌ Error: " .. tostring(err)) end
		task.wait(60)
	end
end)

-- 🚨 ตรวจจับ Error แล้วพาเข้าเกมใหม่
GuiService.ErrorMessageChanged:Connect(function(err)
	if err and err ~= "" then
		print("🚨 ตรวจพบ Error: " .. err)
		task.wait(2)
		print("🔄 กำลังพยายามรีจอยเซิร์ฟเวอร์...")
		TeleportService:Teleport(placeId, player)
	end
end)
