local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerName = player.Name
local fileName = playerName .. ".txt"

local function formatTime(seconds)
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60
	return string.format("%02d:%02d:%02d", h, m, s)
end

local function createDefaultFile(totalPlayTime)
	local defaultContent = string.format(
[[เวลาเริ่มฟามคือ %d
ฟามไป 00:00:00
สิ้นสุดงานที่ 24:00:00
https://discord.com/api/webhooks/your_webhook_here
]], totalPlayTime)
	writefile(fileName, defaultContent)
end

local function readFarmFile()
	if not isfile(fileName) then
		return nil, nil, "N/A"
	end

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

local function sendToDiscordEmbed(data, webhook, endWorkTime)
	if not webhook or webhook == "" then
		warn("❌ ไม่มี Webhook URL")
		return
	end

	local farmDisplay = data.FarmTime
	if endWorkTime ~= "N/A" then
		farmDisplay = farmDisplay .. " / " .. endWorkTime
	else
		farmDisplay = farmDisplay .. " / N/A"
	end

	local payload = {
		username = "TORAKI SHOP",
		avatar_url = "https://media.discordapp.net/attachments/1150536492687556700/1177337077289980025/toraki.gif",
		content = nil,
		embeds = {
			{
				title = "Check Items",
				color = 16711680,
				fields = {
					{name = "⭐ : ชื่อในเกม", value = "||" .. (data.PlayerName or "N/A") .. "||", inline = false},
					{name = "⌛ : ฟาร์มไปแล้ว", value = farmDisplay, inline = false},

					{name = "<:75pxGem:1375439282277453867>", value = tostring(data.Gem or "N/A"), inline = true},
					{name = "<:Gold:1362221819683409950>", value = tostring(data.Gold or "N/A"), inline = true},
					{name = "<:75pxTrait_Reroll:1375439273423011850>", value = tostring(data.TraitReroll or "N/A"), inline = true},

					{name = "<:75pxRanger_Crystal:1375439279026602076>", value = tostring(data.RangerCrystal or "N/A"), inline = true},
					{name = "<:Dr_Megga_Punk:1375438636480467026>", value = tostring(data.DrMeggaPunk or "N/A"), inline = true},
					{name = "<:75pxCursed_Finger:1375450781934948352>", value = tostring(data.CursedFinger or "N/A"), inline = true},

					{name = "<:75pxGhoul_City_Portal_I:1375439287255957584> I", value = tostring(data.GhoulCityPortalI or "N/A"), inline = true},
					{name = "<:75pxGhoul_City_Portal_I:1375439287255957584> II", value = tostring(data.GhoulCityPortalII or "N/A"), inline = true},
					{name = "<:75pxGhoul_City_Portal_I:1375439287255957584> III", value = tostring(data.GhoulCityPortalIII or "N/A"), inline = true},
				},
				author = {
					name = "[🩸 UPDATE 1] Anime Rangers X"
				},
				footer = {
					icon_url = "https://media.discordapp.net/attachments/1150536492687556700/1177337077289980025/toraki.gif"
				},
				image = {
					url = "https://tr.rbxcdn.com/180DAY-ca8de067b9ea25af3b3d5485d16dcbcc/500/280/Image/Jpeg/noFilter"
				},
				timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
			}
		}
	}

	local headers = {["Content-Type"] = "application/json"}
	local dataJson = HttpService:JSONEncode(payload)
	local request = http_request or request or (syn and syn.request)

	if request then
		local success, err = pcall(function()
			request({
				Url = webhook,
				Method = "POST",
				Headers = headers,
				Body = dataJson
			})
		end)
		if success then
			print("✅ ส่ง Embed ไป Discord เรียบร้อย")
		else
			warn("❌ ส่ง Embed ล้มเหลว: " .. tostring(err))
		end
	else
		warn("❌ ไม่พบฟังก์ชันส่ง HTTP Request")
	end
end

local function runOnce()
	local playerDataFolder = ReplicatedStorage:WaitForChild("Player_Data"):FindFirstChild(playerName)
	if not playerDataFolder then
		warn("❌ ไม่พบ Player_Data สำหรับผู้เล่น " .. playerName)
		return
	end

	local data = playerDataFolder:FindFirstChild("Data")
	local items = playerDataFolder:FindFirstChild("Items")

	if not data or not items then
		warn("❌ ไม่พบ Data หรือ Items ใน Player_Data")
		return
	end

	local profile = playerDataFolder:FindFirstChild("Profile")
	if not profile or not profile:FindFirstChild("TotalPlayTime") then
		warn("❌ ไม่พบ Profile หรือ TotalPlayTime")
		return
	end

	local totalPlayTime = profile.TotalPlayTime.Value

	if not isfile(fileName) then
		createDefaultFile(totalPlayTime)
	end

	local startTime, webhookUrl, endWorkTime = readFarmFile()
	if not startTime then
		warn("❌ ไม่พบข้อมูลเวลาเริ่มฟาร์ม")
		return
	end

	local farmedSeconds = totalPlayTime - startTime
	if farmedSeconds < 0 then farmedSeconds = 0 end
	local formattedFarmTime = formatTime(farmedSeconds)

	local function getItemAmount(itemName)
		local item = items:FindFirstChild(itemName)
		if item and item:FindFirstChild("Amount") then
			return tostring(item.Amount.Value)
		else
			return "N/A"
		end
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

-- 🔁 เริ่มลูปส่งข้อมูลทุก 60 วินาที
while true do
	local success, err = pcall(function()
		runOnce()
	end)

	if not success then
		warn("❌ เกิดข้อผิดพลาดในรอบการทำงาน: " .. tostring(err))
	end

	task.wait(60) -- รอ 60 วินาที
end
