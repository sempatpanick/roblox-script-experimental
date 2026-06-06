local function getPlaceProductInfo(marketplaceService, placeId, cache)
	cache = cache or {}
	if cache.value == false then
		return nil
	end
	if cache.value then
		return cache.value
	end
	local ok, info = pcall(function()
		return marketplaceService:GetProductInfo(placeId)
	end)
	if ok and type(info) == "table" then
		cache.value = info
		return info
	end
	cache.value = false
	return nil
end

local function buildServerInfoText(productInfo, gameSnapshot)
	gameSnapshot = gameSnapshot or {}
	local lines = {}

	local gameName = "..."
	if productInfo and productInfo.Name then
		gameName = productInfo.Name
	end
	table.insert(lines, "Game: " .. gameName)
	table.insert(lines, "Place ID: " .. tostring(gameSnapshot.placeId))
	table.insert(lines, "Universe ID: " .. tostring(gameSnapshot.gameId))

	if productInfo and productInfo.Creator then
		local creator = productInfo.Creator
		local creatorLabel = creator.Name or tostring(creator.CreatorTargetId or "?")
		if creator.CreatorType == Enum.CreatorType.Group then
			creatorLabel = creatorLabel .. " (Group)"
		elseif creator.CreatorType == Enum.CreatorType.User then
			creatorLabel = creatorLabel .. " (User)"
		end
		table.insert(lines, "Creator: " .. creatorLabel)
	else
		table.insert(lines, "Creator ID: " .. tostring(gameSnapshot.creatorId))
	end

	if productInfo and productInfo.Created then
		table.insert(lines, "Created: " .. tostring(productInfo.Created))
	end
	if productInfo and productInfo.Updated then
		table.insert(lines, "Updated: " .. tostring(productInfo.Updated))
	end

	table.insert(lines, "")
	table.insert(
		lines,
		"Job ID: " .. ((gameSnapshot.jobId and gameSnapshot.jobId ~= "") and gameSnapshot.jobId or "-")
	)

	local serverType = "Public"
	if gameSnapshot.privateServerId ~= "" then
		serverType = "Private"
	elseif gameSnapshot.vipServerOwnerId ~= 0 then
		serverType = "VIP (Reserved)"
	end
	table.insert(lines, "Server type: " .. serverType)
	if gameSnapshot.privateServerId ~= "" then
		table.insert(lines, "Private server ID: " .. gameSnapshot.privateServerId)
	end
	if gameSnapshot.vipServerOwnerId ~= 0 then
		table.insert(lines, "VIP owner ID: " .. tostring(gameSnapshot.vipServerOwnerId))
	end

	return table.concat(lines, "\n")
end

local function buildServerLiveText(players, localPlayer)
	local lines = {}
	local playerCount = #players:GetPlayers()
	local maxPlayers = players.MaxPlayers
	if maxPlayers > 0 then
		table.insert(lines, string.format("Players: %d / %d", playerCount, maxPlayers))
	else
		table.insert(lines, "Players: " .. tostring(playerCount))
	end

	if localPlayer then
		local okPing, ping = pcall(function()
			return localPlayer:GetNetworkPing()
		end)
		if okPing and ping then
			table.insert(lines, string.format("Ping: %.0f ms", ping * 1000))
		else
			table.insert(lines, "Ping: -")
		end
	else
		table.insert(lines, "Ping: -")
	end

	return table.concat(lines, "\n")
end

return {
	getPlaceProductInfo = getPlaceProductInfo,
	buildServerInfoText = buildServerInfoText,
	buildServerLiveText = buildServerLiveText,
}
