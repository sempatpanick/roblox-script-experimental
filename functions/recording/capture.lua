local function captureAvatarProfileForCharacter(character, getCharacterHumanoidAndRoot)
	local profile = {
		capturedAtUtc = os.date("!%Y-%m-%dT%H:%M:%SZ"),
	}
	local humanoid, rootPart = getCharacterHumanoidAndRoot(character)
	if humanoid then
		profile.rigType = tostring(humanoid.RigType)
		profile.hipHeight = tonumber(string.format("%.3f", humanoid.HipHeight))
		profile.walkSpeed = tonumber(string.format("%.3f", humanoid.WalkSpeed))
		profile.jumpPower = tonumber(string.format("%.3f", humanoid.JumpPower))
		profile.jumpHeight = tonumber(string.format("%.3f", humanoid.JumpHeight))
		local bodyHeightScaleObj = humanoid:FindFirstChild("BodyHeightScale")
		local bodyWidthScaleObj = humanoid:FindFirstChild("BodyWidthScale")
		local bodyDepthScaleObj = humanoid:FindFirstChild("BodyDepthScale")
		local bodyTypeScaleObj = humanoid:FindFirstChild("BodyTypeScale")
		local headScaleObj = humanoid:FindFirstChild("HeadScale")
		if bodyHeightScaleObj and bodyHeightScaleObj:IsA("NumberValue") then
			profile.bodyHeightScale = tonumber(string.format("%.3f", bodyHeightScaleObj.Value))
		end
		if bodyWidthScaleObj and bodyWidthScaleObj:IsA("NumberValue") then
			profile.bodyWidthScale = tonumber(string.format("%.3f", bodyWidthScaleObj.Value))
		end
		if bodyDepthScaleObj and bodyDepthScaleObj:IsA("NumberValue") then
			profile.bodyDepthScale = tonumber(string.format("%.3f", bodyDepthScaleObj.Value))
		end
		if bodyTypeScaleObj and bodyTypeScaleObj:IsA("NumberValue") then
			profile.bodyTypeScale = tonumber(string.format("%.3f", bodyTypeScaleObj.Value))
		end
		if headScaleObj and headScaleObj:IsA("NumberValue") then
			profile.headScale = tonumber(string.format("%.3f", headScaleObj.Value))
		end
	end
	if rootPart then
		profile.rootPartSize = {
			x = tonumber(string.format("%.3f", rootPart.Size.X)),
			y = tonumber(string.format("%.3f", rootPart.Size.Y)),
			z = tonumber(string.format("%.3f", rootPart.Size.Z)),
		}
	end
	local rootSizeY = (rootPart and rootPart.Size and rootPart.Size.Y) or 0
	local hipHeight = (humanoid and humanoid.HipHeight) or 0
	profile.rootToFeetHeight = tonumber(string.format("%.3f", (rootSizeY * 0.5) + hipHeight))
	return profile
end

local function buildMovementSampleData(humanoid, rootPart)
	local moveDir = humanoid.MoveDirection
	local pos = rootPart.Position
	local vel = rootPart.AssemblyLinearVelocity
	local look = rootPart.CFrame.LookVector
	local grounded = humanoid.FloorMaterial ~= Enum.Material.Air
	return {
		moveDirection = {
			x = tonumber(string.format("%.3f", moveDir.X)),
			y = tonumber(string.format("%.3f", moveDir.Y)),
			z = tonumber(string.format("%.3f", moveDir.Z)),
		},
		position = {
			x = tonumber(string.format("%.3f", pos.X)),
			y = tonumber(string.format("%.3f", pos.Y)),
			z = tonumber(string.format("%.3f", pos.Z)),
		},
		velocity = {
			x = tonumber(string.format("%.3f", vel.X)),
			y = tonumber(string.format("%.3f", vel.Y)),
			z = tonumber(string.format("%.3f", vel.Z)),
		},
		lookDirection = {
			x = tonumber(string.format("%.3f", look.X)),
			y = tonumber(string.format("%.3f", look.Y)),
			z = tonumber(string.format("%.3f", look.Z)),
		},
		isGrounded = grounded,
		walkSpeed = tonumber(string.format("%.3f", humanoid.WalkSpeed)),
		jumpPower = tonumber(string.format("%.3f", humanoid.JumpPower)),
		jumpHeight = tonumber(string.format("%.3f", humanoid.JumpHeight)),
	}
end

local function buildMovementSampleSignature(data)
	return string.format(
		"%.2f|%.2f|%.2f|%.3f|%.3f|%.3f|%.3f|%.3f|%.3f|%.2f|%.2f|%.2f|%s",
		data.moveDirection.x,
		data.moveDirection.y,
		data.moveDirection.z,
		data.position.x,
		data.position.y,
		data.position.z,
		data.velocity.x,
		data.velocity.y,
		data.velocity.z,
		data.lookDirection.x,
		data.lookDirection.y,
		data.lookDirection.z,
		data.isGrounded and "1" or "0"
	)
end

local function getRecordingSampleInterval(hz, minHz, maxHz, defaultHz)
	hz = tonumber(hz) or defaultHz or 30
	minHz = minHz or 10
	maxHz = maxHz or 60
	hz = math.clamp(hz, minHz, maxHz)
	return 1 / hz
end

return {
	captureAvatarProfileForCharacter = captureAvatarProfileForCharacter,
	buildMovementSampleData = buildMovementSampleData,
	buildMovementSampleSignature = buildMovementSampleSignature,
	getRecordingSampleInterval = getRecordingSampleInterval,
}
