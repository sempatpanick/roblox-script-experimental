local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SUMMIT_DELAY_SECONDS = 15

local function createAutoSummit(opts)
	opts = opts or {}
	local campList = opts.campList
	local runCampRoute = opts.runCampRoute
	local checkpoint = opts.checkpoint
	local notify = opts.notify or function() end

	local enabled = false
	local restartFromDeath = false
	local activeTweenRef = { tween = nil }
	local deathCheckConn = nil
	local summitQty = ""

	local function cancelActiveTween()
		if activeTweenRef.tween then
			activeTweenRef.tween:Cancel()
			activeTweenRef.tween = nil
		end
	end

	local function onDeath()
		restartFromDeath = true
		cancelActiveTween()
	end

	local function connectCharacterDied(character)
		if not character then
			return
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end
		humanoid.Died:Connect(onDeath)
		humanoid.HealthChanged:Connect(function(health)
			if health <= 0 then
				onDeath()
			end
		end)
	end

	local lp = Players.LocalPlayer
	if lp.Character then
		connectCharacterDied(lp.Character)
	end
	lp.CharacterAdded:Connect(connectCharacterDied)

	local function getRootPart(timeoutSec)
		local pl = Players.LocalPlayer
		local char = pl.Character
		if not char then
			char = pl.CharacterAdded:Wait()
		end
		return char:WaitForChild("HumanoidRootPart", timeoutSec or 15)
	end

	local function cleanupDeathCheck()
		if deathCheckConn then
			deathCheckConn:Disconnect()
			deathCheckConn = nil
		end
	end

	local function stop()
		enabled = false
		cancelActiveTween()
		cleanupDeathCheck()
	end

	local function start(qtyStr, onQtyUpdated)
		stop()
		enabled = true
		restartFromDeath = false
		summitQty = qtyStr or ""

		if deathCheckConn then
			deathCheckConn:Disconnect()
		end
		deathCheckConn = RunService.Heartbeat:Connect(function()
			if not enabled then
				return
			end
			local char = lp.Character
			if not char then
				return
			end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health <= 0 then
				onDeath()
			end
		end)

		local rootPart = getRootPart()
		if not rootPart then
			notify("Auto Summit", "Character not loaded", "x")
			stop()
			return
		end

		task.spawn(function()
			local qtyNum = tonumber(summitQty and summitQty:gsub("%s+", "") or "")
			local runCount = 0
			local remaining = qtyNum
			local skipNextCpResumeNotify = false

			repeat
				if not enabled then
					break
				end
				rootPart = getRootPart()
				if not rootPart then
					local pl = Players.LocalPlayer
					local char = pl.Character
					if char then
						char:WaitForChild("HumanoidRootPart", 10)
					else
						char = pl.CharacterAdded:Wait()
						char:WaitForChild("HumanoidRootPart", 10)
					end
					task.wait(1)
					rootPart = getRootPart()
					if not rootPart then
						notify("Auto Summit", "Could not get character after respawn", "x")
						break
					end
				end

				local routeCompleted = true
				local cpNow = checkpoint.getCheckpointProgressFromPlayer(lp)
				local firstLegIndex, cpClamped = checkpoint.getFirstCampListIndexFromProgress(cpNow)
				local skippedLegs = firstLegIndex == nil
				if skippedLegs then
					skipNextCpResumeNotify = false
				elseif not skipNextCpResumeNotify then
					notify(
						"Auto Summit",
						("Progress #%d (%s) — continuing from %s…"):format(
							cpClamped,
							checkpoint.routeLabelForProgress(cpClamped),
							campList[firstLegIndex].name
						)
					)
				else
					skipNextCpResumeNotify = false
				end

				if not skippedLegs then
					for ci = firstLegIndex, #campList do
						if not enabled or restartFromDeath then
							routeCompleted = false
							break
						end
						rootPart = getRootPart()
						if not rootPart then
							routeCompleted = false
							break
						end
						local camp = campList[ci]
						notify("Auto Summit", "Moving to " .. camp.name .. "...")
						runCampRoute(camp, rootPart, camp.defaultDuration or 5, function()
							return not enabled or restartFromDeath
						end, activeTweenRef)
						if restartFromDeath then
							routeCompleted = false
							break
						end
					end
				end

				if restartFromDeath then
					notify("Auto Summit", "Character died — waiting for respawn…")
					local pl = Players.LocalPlayer
					local char = pl.Character
					if not char then
						char = pl.CharacterAdded:Wait()
					else
						local hum = char:FindFirstChildOfClass("Humanoid")
						if hum and hum.Health <= 0 then
							char = pl.CharacterAdded:Wait()
						end
					end
					if char then
						char:WaitForChild("HumanoidRootPart", 15)
						task.wait(0.5)
					end
					for _ = 1, 15 do
						if pl:FindFirstChild("leaderstats") or pl:FindFirstChild("Expedition Data") then
							break
						end
						task.wait(0.1)
					end
					task.wait(0.35)
					local cpRespawn = checkpoint.getCheckpointProgressFromPlayer(pl)
					local firstRespawn, cpRespawnClamped = checkpoint.getFirstCampListIndexFromProgress(cpRespawn)
					if opts.onCheckpointUpdate then
						task.defer(opts.onCheckpointUpdate)
					end
					restartFromDeath = false
					skipNextCpResumeNotify = true
					if firstRespawn == nil then
						notify(
							"Auto Summit",
							("Respawned — progress #%d (%s). Next: count run / summit step (no route legs)."):format(
								cpRespawnClamped,
								checkpoint.routeLabelForProgress(cpRespawnClamped)
							)
						)
					else
						notify(
							"Auto Summit",
							("Respawned — progress #%d (%s); resuming from %s."):format(
								cpRespawnClamped,
								checkpoint.routeLabelForProgress(cpRespawnClamped),
								campList[firstRespawn].name
							)
						)
					end
				elseif routeCompleted and enabled then
					if skippedLegs then
						notify(
							"Auto Summit",
							("Already past route legs (progress #%d) — run %d."):format(cpClamped, runCount + 1)
						)
					else
						notify("Auto Summit", "Reached summit! (Run " .. (runCount + 1) .. ")")
					end
					runCount = runCount + 1
					if remaining then
						remaining = remaining - 1
						summitQty = tostring(remaining)
						if onQtyUpdated then
							task.defer(function()
								onQtyUpdated(summitQty)
							end)
						end
					end
					if enabled and (not qtyNum or remaining > 0) then
						task.wait(SUMMIT_DELAY_SECONDS / 3)
						local Event = ReplicatedStorage.Events.CharacterHandler
						Event:FireServer("Died")
						task.wait(SUMMIT_DELAY_SECONDS)
					end
				end
			until not enabled or (qtyNum and remaining <= 0)

			cleanupDeathCheck()
			if enabled and qtyNum and remaining <= 0 then
				notify("Auto Summit", "All camps completed (" .. runCount .. " run(s))")
			elseif not enabled then
				notify("Auto Summit", "Stopped", "x")
			end
			enabled = false
		end)
	end

	return {
		start = start,
		stop = stop,
		isEnabled = function()
			return enabled
		end,
		setQty = function(value)
			summitQty = value or ""
		end,
	}
end

return {
	createAutoSummit = createAutoSummit,
	SUMMIT_DELAY_SECONDS = SUMMIT_DELAY_SECONDS,
}
