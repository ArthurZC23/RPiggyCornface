local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local CoreAnimationsData = Data.Animations.CoreAnimationsR15
local TableUtils = Mod:find({"Table", "Utils"})
local Functional = Mod:find({"Functional"})
local InstanceUtils = Mod:find({"InstanceUtils", "Utils"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local AnimationsData = Data.Animations.Animations
local CoreAnimationsFolders = AnimationsData.CoreR15

local RootF = script:FindFirstAncestor("CharCoreAnimationsR15")
local ComponentsF = RootF:WaitForChild("Components")
local Components = {}

local CharCoreAnimationsR15 = {}
CharCoreAnimationsR15.__index = CharCoreAnimationsR15
CharCoreAnimationsR15.className = "CharCoreAnimationsR15"
CharCoreAnimationsR15.TAG_NAME = CharCoreAnimationsR15.className

function CharCoreAnimationsR15.new(char)
    if not CharUtils.isLocalChar(char) then return end
    local self = {
        char = char,
        _maid = Maid.new(),
        lastTick = os.clock(),
        isBinded = true,

        pose = "Standing",

        jumpAnimTime = 0,

        currentAnimName = "",
        currentAnimInstance = nil,
        currentAnimTrack = nil,
        currentAnimKeyframeHandler = nil,
        currentAnimSpeed = 1.0,
        runAnimTrack = nil,
        runAnimKeyframeHandler = nil,
        animTable = {},
        coreTracks = {},

        toolAnim = "None",
        toolAnimName = "",
        toolAnimInstance = nil,
        toolAnimTrack = nil,
        toolAnimTime = 0,

        currentToolAnimKeyframeHandler = nil,
        AnimationSpeedDampeningObject = 1,
        EMOTE_TRANSITION_TIME = 0.1,

        jumpAnimDuration = 0.31,
        toolTransitionTime = 0.1,
        fallTransitionTime = 0.2,
    }
    setmetatable(self, CharCoreAnimationsR15)

    if not self:getFields() then return end
    self:preloadCoreAnimations()

    self:setParameters()
    self:clearCoreAnimations()
    self:createAnimationsFolder()
    self:setInitialPoseToAnims()
    self:createSignals()
    self:configureAllAnimationSet()
    self:setHumanoidEvents()

    -- initialize to idle
    self:playAnimation("idle", 0.1)
    self.pose = "Standing"

    if not self:initComponents() then return end

    task.spawn(function()
        while self.char.Parent and self.isBinded do
            self:move(os.clock())
            task.wait()
            -- print("Current pose: ", self.pose)
        end
    end)

    return self
end

function CharCoreAnimationsR15:setParameters()
    local userNoUpdateOnLoopSuccess, userNoUpdateOnLoopValue = pcall(function() return UserSettings():IsUserFeatureEnabled("UserNoUpdateOnLoop") end)
    self.userNoUpdateOnLoop = userNoUpdateOnLoopSuccess and userNoUpdateOnLoopValue
    
    local userAnimateScaleRunSuccess, userAnimateScaleRunValue = pcall(function() return UserSettings():IsUserFeatureEnabled("UserAnimateScaleRun") end)
    self.userAnimateScaleRun = userAnimateScaleRunSuccess and userAnimateScaleRunValue
end

function CharCoreAnimationsR15:getRigScale()
	if self.userAnimateScaleRun then
		return self.char:GetScale()
	else
		return 1
	end
end

function CharCoreAnimationsR15:preloadCoreAnimations()
    local coreAnimations = CoreAnimationsData.defaultCoreAnimations
    if self.char:GetAttribute("CoreAnimations") == "Monster" then
        coreAnimations = CoreAnimationsData.monsterCoreAnimations
    end
    for pose, animationsData in pairs(coreAnimations) do
        for _, data in ipairs(animationsData) do
            local animation = Instance.new("Animation")
            animation.AnimationId = data.id
            table.insert(self.coreTracks, self:LoadAnimation(animation))
        end
    end
end

function CharCoreAnimationsR15:initComponents()
    for cName, cClass in pairs(Components) do
        local obj = cClass.new(self)
        if obj then
            self[cName] = self._maid:Add(obj)
        else
            return false
        end
    end
    return true
end

function CharCoreAnimationsR15:getPoseData(pose)
    local animationsData = self.poseToAnims[pose]
    local poseStyle = self.poseStyle[pose]
    return {
        animationsData = animationsData,
        poseStyle = poseStyle,
    }
end

function CharCoreAnimationsR15:getPoseAnimSignal(pose)
    return self[("%sUpdateSE"):format(pose)]
end

function CharCoreAnimationsR15:setPoseAnimations(pose, poseStyle, animationsData, kwargs)
    local poseAnims = self.animationsFolder[pose]
    InstanceUtils.clearChildrenWhichAre(poseAnims, "Animation")

    for i, data in ipairs(animationsData) do
        assert(data.id or data.animation, "Require Animation instance or animationId.")
        local animation
        if data.animation then
            animation = data.animation
        else
            animation = GaiaShared.create("Animation",
                {
                    AnimationId = data.id,
                }
            )
        end
        animation.Name = data.name or ("Animation%s"):format(i)
        local weight = GaiaShared.create("NumberValue",
            {
                Name = "Weight",
                Value = data.weight or 1,
            }
        )
        weight.Parent = animation

        animation.Parent = poseAnims
    end

    for _, track in pairs(self.humanoid:GetPlayingAnimationTracks()) do
        track:Stop(0)
    end

    self.poseToAnims[pose] = animationsData
    self.poseStyle[pose] = poseStyle

    self[("%sUpdateSE"):format(pose)]:Fire({
        animationsData = animationsData,
        poseStyle = poseStyle,
        kwargs = kwargs,
    })
end

function CharCoreAnimationsR15:removePoseAnimation(pose, animationId, kwargs)
    local poseAnims = self.animationsFolder[pose]
    InstanceUtils.getChildrenConditional(poseAnims, function(child)
        return child.AnimationId == animationId
    end)
end

function CharCoreAnimationsR15:setInitialPoseToAnims()
    if self.char:GetAttribute("CoreAnimations") == "Monster" then
        self.poseToAnims = TableUtils.deepCopy(CoreAnimationsData.monsterCoreAnimations)
        self.poseStyle = {}
        for pose in pairs(self.poseToAnims) do
            self.poseStyle[pose] = "Monster"
        end
    else
        self.poseToAnims = TableUtils.deepCopy(CoreAnimationsData.defaultCoreAnimations)
        self.poseStyle = {}
        for pose in pairs(self.poseToAnims) do
            self.poseStyle[pose] = "Default"
        end
    end
end

function CharCoreAnimationsR15:createSignals()
    local eventsNames = Functional.map(TableUtils.getKeys(self.poseToAnims), function(pose)
        return ("%sUpdate"):format(pose)
    end)

    return self._maid:Add(GaiaShared.createBinderSignals(self, self.char, {
        events = eventsNames,
    }))
end

function CharCoreAnimationsR15:clearCoreAnimations()
	for _, track in ipairs(self.coreTracks) do
		track:Stop(0)
		track:Destroy()
	end
end

function CharCoreAnimationsR15:createAnimationsFolder()
    local previous = self.char:FindFirstChild("CoreAnimations")
    if previous then previous:Destroy() end
    local coreAnimations = self.char:GetAttribute("CoreAnimations") or "Default"
    self.animationsFolder = CoreAnimationsFolders[coreAnimations]:Clone()
    self.animationsFolder.Name = "CoreAnimations"
    self.animationsFolder.Parent = self.char
end

function CharCoreAnimationsR15:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            -- Need to wait for animator to avoid animations not replicating.
            local bindersData = {
                {"CharParts", self.char},
                {"CharAnimations", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            if not self.charParts then return end
            self.humanoid = self.charParts.humanoid
            self.animator = self.charParts.animator

            self.HumanoidHipHeight = 2
            if not self.HumanoidHipHeight then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharCoreAnimationsR15:configureAnimationSet(poseName, animationsData)
    -- This deals with animLoading inside the localScript
    -- This info is not static
    -- print("configureAnimationSet")
    local function _resetAnimTable()
        if (self.animTable[poseName] ~= nil) then
            for _, connection in pairs(self.animTable[poseName].connections) do
                connection:Disconnect()
            end
        end
        self.animTable[poseName] = {}
        self.animTable[poseName].count = 0
        self.animTable[poseName].totalWeight = 0
        self.animTable[poseName].connections = {}
    end
    local function _setConfig(config)
        --		print("Loading anims " .. poseName)
        table.insert(self.animTable[poseName].connections, config.ChildAdded:Connect(function(child) self:configureAnimationSet(poseName, animationsData) end))
        table.insert(self.animTable[poseName].connections, config.ChildRemoved:Connect(function(child) self:configureAnimationSet(poseName, animationsData) end))
        local idx = 1
        for _, childPart in pairs(config:GetChildren()) do
            if (childPart:IsA("Animation")) then
                local animation = childPart
                table.insert(self.animTable[poseName].connections, animation.Changed:Connect(function(property) self:configureAnimationSet(poseName, animationsData) end))
                self.animTable[poseName][idx] = {}
                self.animTable[poseName][idx].anim = animation
                -- print(animation:GetFullName(), animation.AnimationId)
                local weightObject = animation:FindFirstChild("Weight")
                if (weightObject == nil) then
                    self.animTable[poseName][idx].weight = 1
                else
                    self.animTable[poseName][idx].weight = weightObject.Value
                end
                self.animTable[poseName].count = self.animTable[poseName].count + 1
                self.animTable[poseName].totalWeight = self.animTable[poseName].totalWeight + self.animTable[poseName][idx].weight
    --			print(poseName .. " [" .. idx .. "] " .. self.animTable[poseName][idx].anim.AnimationId .. " (" .. self.animTable[poseName][idx].weight .. ")")
                idx = idx + 1
            end
        end
    end
    local function _setProto()
        for idx, anim in pairs(animationsData) do
            self.animTable[poseName][idx] = {}
            self.animTable[poseName][idx].anim = Instance.new("Animation")
            self.animTable[poseName][idx].anim.Name = poseName
            self.animTable[poseName][idx].anim.AnimationId = anim.id
            self.animTable[poseName][idx].weight = anim.weight
            self.animTable[poseName].count = self.animTable[poseName].count + 1
            self.animTable[poseName].totalWeight = self.animTable[poseName].totalWeight + anim.weight
--			print(poseName .. " [" .. idx .. "] " .. anim.id .. " (" .. anim.weight .. ")")
        end
    end
    _resetAnimTable()

    -- check for config values
    local config = self.animationsFolder:FindFirstChild(poseName)
    if config then _setConfig(config) end

    -- fallback to defaults
    if (self.animTable[poseName].count <= 0) then _setProto() end

    -- TableUtils.print(self.animTable)
end

function CharCoreAnimationsR15:configureAllAnimationSet()
local function update(child)
    local animationsData = self.poseToAnims[child.Name]
    if not animationsData then return end
    self:configureAnimationSet(child.Name, animationsData)
end

self.animationsFolder.ChildRemoved:Connect(update)
self.animationsFolder.ChildAdded:Connect(update)

for poseName, animationsData in pairs(self.poseToAnims) do
    self:configureAnimationSet(poseName, animationsData)
end
end

local smallButNotZero = 0.0001
function CharCoreAnimationsR15:setRunSpeed(speed)
	local normalizedWalkSpeed = 0.5 -- established empirically using current `913402848` walk animation
	local normalizedRunSpeed  = 1
	local runSpeed = self:rootMotionCompensation(speed)

	local walkAnimationWeight = smallButNotZero
	local runAnimationWeight = smallButNotZero
	local walkAnimationTimewarp = runSpeed/normalizedWalkSpeed
	local runAnimationTimerwarp = runSpeed/normalizedRunSpeed

	if runSpeed <= normalizedWalkSpeed then
		walkAnimationWeight = 1
	elseif runSpeed < normalizedRunSpeed then
		local fadeInRun = (runSpeed - normalizedWalkSpeed)/(normalizedRunSpeed - normalizedWalkSpeed)
		walkAnimationWeight = 1 - fadeInRun
		runAnimationWeight  = fadeInRun
		walkAnimationTimewarp = 1
		runAnimationTimerwarp = 1
	else
		runAnimationWeight = 1
	end
	self.currentAnimTrack:AdjustWeight(walkAnimationWeight)
	self.runAnimTrack:AdjustWeight(runAnimationWeight)
	self.currentAnimTrack:AdjustSpeed(walkAnimationTimewarp)
	self.runAnimTrack:AdjustSpeed(runAnimationTimerwarp)
end

function CharCoreAnimationsR15:setAnimationSpeed(speed)
    -- print("Z 0", self.currentAnimName)
	if self.currentAnimName == "walk" then
        -- print("Z 1")
        self:setRunSpeed(speed)
	else
        -- print("Z 2")
		if speed ~= self.currentAnimSpeed then
            -- print("Z 3")
			self.currentAnimSpeed = speed
			self.currentAnimTrack:AdjustSpeed(self.currentAnimSpeed)
		end
	end
end

function CharCoreAnimationsR15:stopAllAnimations()
	local oldAnim = self.currentAnimName

	self.currentAnimName = ""
	self.currentAnimInstance = nil
	if (self.currentAnimKeyframeHandler ~= nil) then
		self.currentAnimKeyframeHandler:Disconnect()
	end

	if (self.currentAnimTrack ~= nil) then
		self.currentAnimTrack:Stop()
		self.currentAnimTrack:Destroy()
		self.currentAnimTrack = nil
	end
	return oldAnim
end

function CharCoreAnimationsR15:getHeightScale()
    local humanoid = self.charParts.humanoid
	if humanoid then
		if not humanoid.AutomaticScalingEnabled then
			-- When auto scaling is not enabled, the rig scale stands in for
			-- a computed scale.
			return self:getRigScale()
		end
		
		local scale = self.charParts.humanoid.HipHeight / self.HumanoidHipHeight
        scale = 1 + (humanoid.HipHeight - self.HumanoidHipHeight) * self.AnimationSpeedDampeningObject / self.HumanoidHipHeight
		return scale
	end	
	return self:getRigScale()
end

function CharCoreAnimationsR15:rootMotionCompensation(speed)
	local speedScaled = speed * 1.25
	local heightScale = self:getRigScale()
	local runSpeed = speedScaled / heightScale
	return runSpeed
end

function CharCoreAnimationsR15:keyFrameReachedFunc(frameName)
	if (frameName == "End") then
		if self.currentAnimName == "walk" then
			if self.userNoUpdateOnLoop == true then
				if self.runAnimTrack.Looped ~= true then
					self.runAnimTrack.TimePosition = 0.0
				end
				if self.currentAnimTrack.Looped ~= true then
					self.currentAnimTrack.TimePosition = 0.0
				end
			else
				self.runAnimTrack.TimePosition = 0.0
				self.currentAnimTrack.TimePosition = 0.0
			end
		else
			local repeatAnim = self.currentAnimName or "idle"
			local animSpeed = self.currentAnimSpeed
			self:playAnimation(repeatAnim, 0.15)
			self:setAnimationSpeed(animSpeed)
		end
	end
end

function CharCoreAnimationsR15:_sampleAnimation(animName)
    -- TableUtils.print(self.animTable)
    -- print(animName)
    local roll = math.random(1, self.animTable[animName].totalWeight)
    local idx = 1
    while (roll > self.animTable[animName][idx].weight) do
        roll = roll - self.animTable[animName][idx].weight
        idx = idx + 1
    end
    -- print(animName .. " " .. idx .. " [" .. origRoll .. "]")
    local anim = self.animTable[animName][idx].anim
    return anim
end

-- Preload animations
function CharCoreAnimationsR15:playAnimation(animName, transitionTime)
    -- print("playAnimation")
    local newAnimation = self:_sampleAnimation(animName)

    local function _switchAnim(anim)
		if (self.currentAnimTrack ~= nil) then
			self.currentAnimTrack:Stop(transitionTime)
			self.currentAnimTrack:Destroy()
		end

        if (self.runAnimTrack ~= nil) then
			self.runAnimTrack:Stop(transitionTime)
			self.runAnimTrack:Destroy()
			if self.userNoUpdateOnLoop == true then
				self.runAnimTrack = nil
			end
		end

		self.currentAnimSpeed = 1.0
		-- load it to the humanoid; get AnimationTrack
		self.currentAnimTrack = self:LoadAnimation(anim)
		self.currentAnimTrack.Priority = Enum.AnimationPriority.Core

		-- play the animation
		self.currentAnimTrack:Play(transitionTime)
		self.currentAnimName = animName
		self.currentAnimInstance = anim

		-- set up keyframe name triggers
		if (self.currentAnimKeyframeHandler ~= nil) then
			self.currentAnimKeyframeHandler:Disconnect()
		end
		self.currentAnimKeyframeHandler = self.currentAnimTrack.KeyframeReached:Connect(
            function (frameName)
                self:keyFrameReachedFunc(frameName)
            end
        )

        if animName == "walk" then
			local runAnimName = "run"
            local newRunAnimation = self:_sampleAnimation(runAnimName)

			self.runAnimTrack = self:LoadAnimation(newRunAnimation)
			self.runAnimTrack.Priority = Enum.AnimationPriority.Core
			self.runAnimTrack:Play(transitionTime)
			
			if (self.runAnimKeyframeHandler ~= nil) then
				self.runAnimKeyframeHandler:Disconnect()
			end
			self.runAnimKeyframeHandler = self.runAnimTrack.KeyframeReached:Connect(
                function (frameName)
                    self:keyFrameReachedFunc(frameName)
                end
            )
		end

    end

	if (newAnimation ~= self.currentAnimInstance) then
        _switchAnim(newAnimation)
	end
end

function CharCoreAnimationsR15:toolKeyFrameReachedFunc(frameName)
	if (frameName == "End") then
--		print("Keyframe : ".. frameName)	
		self:playToolAnimation(self.toolAnimName, 0.0, self.humanoid)
	end
end

function CharCoreAnimationsR15:LoadAnimation(animation)
    return self.charAnimations:LoadAnimation(animation)
end

function CharCoreAnimationsR15:playToolAnimation(animName, transitionTime, priority)
    local newAnimation = self:_sampleAnimation(animName)

    local function _switchAnim(anim)
        if (self.toolAnimTrack ~= nil) then
            self.toolAnimTrack:Stop()
            self.toolAnimTrack:Destroy()
            transitionTime = 0
        end

        -- load it to the humanoid; get AnimationTrack
        self.toolAnimTrack = self:LoadAnimation(anim)
        if priority then
            self.toolAnimTrack.Priority = priority
        end

        -- play the animation
        self.toolAnimTrack:Play(transitionTime)
        self.toolAnimName = animName
        self.toolAnimInstance = anim

        self.currentToolAnimKeyframeHandler = self.toolAnimTrack.KeyframeReached:Connect(function()
            self.toolKeyFrameReachedFunc()
        end)
    end

    if (self.toolAnimInstance ~= newAnimation) then
        _switchAnim(newAnimation)
    end
end

function CharCoreAnimationsR15:stopToolAnimations()
	local oldAnim = self.toolAnimName

	if (self.currentToolAnimKeyframeHandler ~= nil) then
		self.currentToolAnimKeyframeHandler:Disconnect()
	end

	self.toolAnimName = ""
	self.toolAnimInstance = nil
	if (self.toolAnimTrack ~= nil) then
		self.toolAnimTrack:Stop()
		self.toolAnimTrack:Destroy()
		self.toolAnimTrack = nil
	end

	return oldAnim
end

function CharCoreAnimationsR15:onRunning(speed)
    -- Value is too big. Monster walks with idle animation.
	-- local heightScale = if self.userAnimateScaleRun then self:getHeightScale() else 1

    local heightScale = 1
	local humanoid = self.humanoid
	local movedDuringEmote = humanoid.MoveDirection == Vector3.new(0, 0, 0)
    -- Value is too big. Monster walks with idle animation.
	-- local speedThreshold = movedDuringEmote and (humanoid.WalkSpeed / heightScale) or 0.75
    local speedThreshold = 0.75
	if speed > speedThreshold * heightScale then
		local scale = 16.0
		self:playAnimation("walk", 0.2)
        local charRunAnimationFactor = self.char:GetAttribute("charRunAnimationFactor") or 1
		self:setAnimationSpeed((charRunAnimationFactor * speed) / scale)
		self.pose = "Running"
	else
		-- if emoteNames[currentAnim] == nil and not currentlyPlayingEmote then
			self:playAnimation("idle", 0.2)
			self.pose = "Standing"
		-- end
	end
end

function CharCoreAnimationsR15:onDied()
	self.pose = "Dead"
end

function CharCoreAnimationsR15:onJumping()
	self:playAnimation("jump", 0.1)
	self.jumpAnimTime = self.jumpAnimDuration
	self.pose = "Jumping"
end

function CharCoreAnimationsR15:onClimbing(speed)
	if self.userAnimateScaleRun then
		speed /= self:getHeightScale()
	end
	local scale = 5.0
	self:playAnimation("climb", 0.1)
	self:setAnimationSpeed(speed / scale)
	self.pose = "Climbing"
end

function CharCoreAnimationsR15:onGettingUp()
	self.pose = "GettingUp"
end

function CharCoreAnimationsR15:onFreeFall()
	if (self.jumpAnimTime <= 0) then
		self:playAnimation("fall", self.fallTransitionTime)
	end
	self.pose = "FreeFall"
end

function CharCoreAnimationsR15:onFallingDown()
	self.pose = "FallingDown"
end

function CharCoreAnimationsR15:onSeated()
	self.pose = "Seated"
end

function CharCoreAnimationsR15:onPlatformStanding()
	self.pose = "PlatformStanding"
end

function CharCoreAnimationsR15:onSwimming(speed)
	if self.userAnimateScaleRun then
		speed /= self:getHeightScale()
	end
	if speed > 1.00 then
		local scale = 10.0
		self:playAnimation("swim", 0.4)
		self:setAnimationSpeed(speed / scale)
		self.pose = "Swimming"
	else
		self:playAnimation("swimidle", 0.4)
		self.pose = "Standing"
	end
end

function CharCoreAnimationsR15:getTool()
    return self.char:FindFirstChildOfClass("Tool")
end

function CharCoreAnimationsR15:getToolAnim(tool)
    local animStringValue = tool:FindFirstChild("toolanim")
    if not animStringValue then return end
    if animStringValue:IsA("StringValue") then return animStringValue end
end

function CharCoreAnimationsR15:animateTool()
	if (self.toolAnim == "None") then
		self:playToolAnimation("toolnone", self.toolTransitionTime, Enum.AnimationPriority.Idle)
		return
	end

	if (self.toolAnim == "Slash") then
		self:playToolAnimation("toolslash", 0, Enum.AnimationPriority.Action)
		return
	end

	if (self.toolAnim == "Lunge") then
		self:playToolAnimation("toollunge", 0, Enum.AnimationPriority.Action)
		return
	end
end

function CharCoreAnimationsR15:move(timestamp)
  	local deltaTime = os.clock() - self.lastTick
  	self.lastTick = timestamp

    -- Count down on jumoAnimTime
  	if (self.jumpAnimTime > 0) then
  		self.jumpAnimTime = self.jumpAnimTime - deltaTime
  	end

	if (self.pose == "FreeFall" and self.jumpAnimTime <= 0) then
		self:playAnimation("fall", self.fallTransitionTime)
	elseif (self.pose == "Seated") then
		self:playAnimation("sit", 0.5)
		return
	elseif (self.pose == "Running") then
		self:playAnimation("walk", 0.2)

    -- # Why there is Seated here?
	elseif (self.pose == "Dead" or self.pose == "GettingUp" or self.pose == "FallingDown" or self.pose == "Seated" or self.pose == "PlatformStanding") then
		self:stopAllAnimations()
	end

	-- Tool Animation handling
	-- local tool = self:getTool()
	-- if tool and tool:FindFirstChild("Handle") then

    --     -- -- This is the DRAW animation!
    --     --local animStringValueObject = self:getToolAnim(tool)
	-- 	-- if animStringValueObject then
	-- 	-- 	self.toolAnim = animStringValueObject.Value
	-- 	-- 	-- message recieved, delete StringValue
	-- 	-- 	animStringValueObject.Parent = nil
	-- 	-- 	self.toolAnimTime = self.lastTick + .3
	-- 	-- end

	-- 	if self.lastTick > self.toolAnimTime  then
	-- 		self.toolAnimTime = 0
	-- 		self.toolAnim = "None"
	-- 	end

	-- 	self:animateTool()
	-- else
	-- 	self:stopToolAnimations()
	-- 	self.toolAnim = "None"
	-- 	self.toolAnimInstance = nil
	-- 	self.toolAnimTime = 0
	-- end
end

function CharCoreAnimationsR15:setHumanoidEvents()
    self._maid:Add(self.humanoid.Died:Connect(function()
        -- print("onDied") 
        self:onDied() end))
    self._maid:Add(self.humanoid.Running:Connect(function(speed)
        -- print("onRunning") 
        self:onRunning(speed) end))
    self._maid:Add(self.humanoid.Jumping:Connect(function()
        -- print("onJumping") 
        self:onJumping() end))
    self._maid:Add(self.humanoid.Climbing:Connect(function(speed)
        -- print("onClimbing") 
        self:onClimbing(speed) end))
    self._maid:Add(self.humanoid.GettingUp:Connect(function()
        -- print("onGettingUp") 
        self:onGettingUp() end))
    self._maid:Add(self.humanoid.FreeFalling:Connect(function()
        -- print("onFreeFall") 
        self:onFreeFall() end))
    self._maid:Add(self.humanoid.FallingDown:Connect(function()
        -- print("onFallingDown") 
        self:onFallingDown() end))
    self._maid:Add(self.humanoid.Seated:Connect(function()
        -- print("onSeated") 
        self:onSeated() end))
    self._maid:Add(self.humanoid.PlatformStanding:Connect(function()
        -- print("PlatformStanding") 
        self:onPlatformStanding() end))
    self._maid:Add(self.humanoid.Swimming:Connect(function(speed)
        -- print("onSwimming") 
        self:onSwimming(speed) end))
end

function CharCoreAnimationsR15:Destroy()
    self._maid:Destroy()
    self.isBinded = false
    self:clearCoreAnimations()
end

return CharCoreAnimationsR15