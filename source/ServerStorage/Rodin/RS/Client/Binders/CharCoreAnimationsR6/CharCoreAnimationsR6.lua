local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local Data = Mod:find({"Data", "Data"})
local CoreAnimationsData = Data.Animations.CoreAnimationsR6
local CoreConfig = CoreAnimationsData.config
local TableUtils = Mod:find({"Table", "Utils"})
local Functional = Mod:find({"Functional"})
local InstanceUtils = Mod:find({"InstanceUtils", "Utils"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})

local AnimationsData = Data.Animations.Animations
local CoreAnimationsFolders = AnimationsData.CoreR6

local localPlayer = Players.LocalPlayer
local binderCharParts = SharedSherlock:find({"Binders", "getBinder"}, {tag="CharParts"})

local RootF = script:FindFirstAncestor("CharCoreAnimationsR6")
local ComponentsF = RootF:WaitForChild("Components")

local Components = {

}

local CharCoreAnimationsR6 = {}
CharCoreAnimationsR6.__index = CharCoreAnimationsR6
CharCoreAnimationsR6.className = "CharCoreAnimationsR6"
CharCoreAnimationsR6.TAG_NAME = CharCoreAnimationsR6.className

function CharCoreAnimationsR6.new(char)
    -- --
    -- if RunService:IsStudio() then return end
    -- --
    if not CharUtils.isLocalChar(char) then return end
    local self = {
        char = char,
        _maid = Maid.new(),
        lastTick = os.clock(),
        isBinded = true,

        pose = "Standing",

        emoteNames = {},

        jumpAnimTime = 0,

        currentAnimName = "",
        currentAnimInstance = nil,
        currentAnimTrack = nil,
        currentAnimKeyframeHandler = nil,
        currentAnimSpeed = 1.0,
        animTable = {},

        toolAnim = "None",
        toolAnimName = "",
        toolAnimInstance = nil,
        toolAnimTrack = nil,
        toolAnimTime = 0,
        currentToolAnimKeyframeHandler = nil,
    }
    setmetatable(self, CharCoreAnimationsR6)

    if not self:getFields() then return end
    self:preloadCoreAnimations()
    self:clearCoreAnimations()
    self:createAnimationsFolder()
    self:setInitialPoseToAnims()
    self:createSignals()
    self:configureAllAnimationSet()
    self:handleChatDance()
    self:setHumanoidEvents()

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

local coreTracks = {}

function CharCoreAnimationsR6:preloadCoreAnimations()
    for pose, animationsData in pairs(CoreAnimationsData.defaultCoreAnimations) do
        for _, data in ipairs(animationsData) do
            local animation = Instance.new("Animation")
            animation.AnimationId = data.id
            table.insert(self.coreTracks, self:LoadAnimation(animation))
        end
    end
    local animations = {
        AnimationsData.NoWeapon.Run,
        AnimationsData.Weapons.Sword.Run,
        AnimationsData.Weapons.DoubleSword.Run,
    }
    for i, animation in ipairs(animations) do
        table.insert(coreTracks, self:LoadAnimation(animation))
    end
end

function CharCoreAnimationsR6:initComponents()
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

function CharCoreAnimationsR6:getPoseData(pose)
    local animationsData = self.poseToAnims[pose]
    local poseStyle = self.poseStyle[pose]
    return {
        animationsData = animationsData,
        poseStyle = poseStyle,
    }
end

function CharCoreAnimationsR6:getPoseAnimSignal(pose)
    return self[("%sUpdateSE"):format(pose)]
end

function CharCoreAnimationsR6:setPoseAnimations(pose, poseStyle, animationsData, kwargs)
    local poseAnims = self.animationsFolder[pose]
    InstanceUtils.clearChildrenWhichAre(poseAnims, "Animation")

    for _, track in ipairs(self.coreTracks) do
		track:Stop(0)
		track:Destroy()
	end

    -- Need defer else new anim doesn't play
    task.defer(function()
        self:playAnimation(self.currentAnimName, 0.1)
    end)

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

    self.poseToAnims[pose] = animationsData
    self.poseStyle[pose] = poseStyle

    self[("%sUpdateSE"):format(pose)]:Fire({
        animationsData = animationsData,
        poseStyle = poseStyle,
        kwargs = kwargs,
    })
end

function CharCoreAnimationsR6:removePoseAnimation(pose, animationId, kwargs)
    local poseAnims = self.animationsFolder[pose]
    InstanceUtils.getChildrenConditional(poseAnims, function(child)
        return child.AnimationId == animationId
    end)
end

function CharCoreAnimationsR6:setInitialPoseToAnims()
    self.poseToAnims = TableUtils.deepCopy(CoreAnimationsData.defaultCoreAnimations)
    self.poseStyle = {}
    for pose in pairs(self.poseToAnims) do
        self.poseStyle[pose] = "Default"
    end
end

function CharCoreAnimationsR6:createSignals()
    local eventsNames = Functional.map(TableUtils.getKeys(self.poseToAnims), function(pose)
        return ("%sUpdate"):format(pose)
    end)

    return self._maid:Add(GaiaShared.createBinderSignals(self, self.char, {
        events = eventsNames,
    }))
end

function CharCoreAnimationsR6:clearCoreAnimations()
	for _, track in ipairs(coreTracks) do
		track:Stop(0)
		track:Destroy()
	end
end

function CharCoreAnimationsR6:createAnimationsFolder()
    local previous = self.char:FindFirstChild("CoreAnimations")
    if previous then previous:Destroy() end
    local coreAnimations = self.char:GetAttribute("CoreAnimations") or "Default"
    self.animationsFolder = CoreAnimationsFolders[coreAnimations]:Clone()
    self.animationsFolder.Name = "CoreAnimations"
    self.animationsFolder.Parent = self.char
end

function CharCoreAnimationsR6:handleChatDance()
    self.dances = CoreAnimationsData.emotes.dances
    self.emoteNames = CoreAnimationsData.emotes.emoteNames
    self._maid:Add(localPlayer.Chatted:Connect(function(msg)
        local emote = ""
        if msg == "/e dance" then
            emote = self.dances[math.random(1, #self.dances)]
        elseif (string.sub(msg, 1, 3) == "/e ") then
            emote = string.sub(msg, 4)
        elseif (string.sub(msg, 1, 7) == "/emote ") then
            emote = string.sub(msg, 8)
        end
        if (self.pose == "Standing" and self.emoteNames[emote] ~= nil) then
            self:playAnimation(emote, 0.1)
        end
    end))
end

function CharCoreAnimationsR6:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            -- Need to wait for animator to avoid animations not replicating.
            self.charParts = binderCharParts:getObj(self.char)
            if not self.charParts then return end
            self.humanoid = self.charParts.humanoid
            self.animator = self.charParts.animator

            local charId = self.char:GetAttribute("uid")
            self.charEvents = ComposedKey.getFirstDescendant(ReplicatedStorage, {"CharsEvents", charId})
            if not self.charEvents then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharCoreAnimationsR6:configureAnimationSet(poseName, animationsData)
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

function CharCoreAnimationsR6:configureAllAnimationSet()
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

function CharCoreAnimationsR6:setAnimationSpeed(speed)
    if speed == self.currentAnimSpeed then return end
    self.currentAnimSpeed = speed
    self.currentAnimTrack:AdjustSpeed(self.currentAnimSpeed)
end

function CharCoreAnimationsR6:stopAllAnimations()
	local oldAnim = self.currentAnimName

	-- return to idle if finishing an emote
	if (self.emoteNames[oldAnim] == false) then
		oldAnim = "idle"
	end

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

function CharCoreAnimationsR6:keyFrameReachedFunc(frameName)
	if (frameName == "End") then
		local repeatAnim = self.currentAnimName
		-- return to idle if finishing an emote
		if (self.emoteNames[repeatAnim] == false) then
			repeatAnim = "idle"
		end

		local animSpeed = self.currentAnimSpeed
		self:playAnimation(repeatAnim, 0.0)
		self:setAnimationSpeed(animSpeed)
	end
end

function CharCoreAnimationsR6:_sampleAnimation(animName)
    -- TableUtils.print(self.animTable)
    -- print(animName)
    local roll = math.random(1, self.animTable[animName].totalWeight)
    local origRoll = roll
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
function CharCoreAnimationsR6:playAnimation(animName, transitionTime)
    local newAnimation = self:_sampleAnimation(animName)

    local function _switchAnim(anim)
		if (self.currentAnimTrack ~= nil) then
			self.currentAnimTrack:Stop(transitionTime)
			self.currentAnimTrack:Destroy()
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

    end

	if (newAnimation ~= self.currentAnimInstance) then
        _switchAnim(newAnimation)
	end
end

function CharCoreAnimationsR6:toolKeyFrameReachedFunc(frameName)
	if (frameName == "End") then
--		print("Keyframe : ".. frameName)	
		self:playToolAnimation(self.toolAnimName, 0.0, self.humanoid)
	end
end

function CharCoreAnimationsR6:LoadAnimation(animation)
    return self.charAnimations:LoadAnimation(animation)
end

function CharCoreAnimationsR6:playToolAnimation(animName, transitionTime, priority)

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

function CharCoreAnimationsR6:stopToolAnimations()
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

function CharCoreAnimationsR6:onRunning(speed)
	if speed > 0.01 then
        -- Problem here. Replication bug in studio with multiple players.
		self:playAnimation("walk", 0.1)
		if self.currentAnimInstance and self.currentAnimInstance.AnimationId == "http://www.roblox.com/asset/?id=180426354" then
			self:setAnimationSpeed(speed / 14.5)
		end
		self.pose = "Running"
        --
	else
		if self.emoteNames[self.currentAnimName] == nil then
			self:playAnimation("idle", 0.1)
			self.pose = "Standing"
		end
	end
end

function CharCoreAnimationsR6:onDied()
	self.pose = "Dead"
end

function CharCoreAnimationsR6:onJumping()
	self:playAnimation("jump", 0.1)
	self.jumpAnimTime = CoreConfig.jumpAnimDuration
	self.pose = "Jumping"
end

function CharCoreAnimationsR6:onClimbing(speed)
	self:playAnimation("climb", 0.1)
	self:setAnimationSpeed(speed / 12.0)
	self.pose = "Climbing"
end

function CharCoreAnimationsR6:onGettingUp()
	self.pose = "GettingUp"
end

function CharCoreAnimationsR6:onFreeFall()
	if (self.jumpAnimTime <= 0) then
		self:playAnimation("fall", CoreConfig.fallTransitionTime)
	end
	self.pose = "FreeFall"
end

function CharCoreAnimationsR6:onFallingDown()
	self.pose = "FallingDown"
end

function CharCoreAnimationsR6:onSeated()
	self.pose = "Seated"
end

function CharCoreAnimationsR6:onPlatformStanding()
	self.pose = "PlatformStanding"
end

function CharCoreAnimationsR6:onSwimming(speed)
	if speed > 0 then
		self.pose = "Running"
	else
		self.pose = "Standing"
	end
end

function CharCoreAnimationsR6:getTool()
    return self.char:FindFirstChildOfClass("Tool")
end

function CharCoreAnimationsR6:getToolAnim(tool)
    local animStringValue = tool:FindFirstChild("toolanim")
    if not animStringValue then return end
    if animStringValue:IsA("StringValue") then return animStringValue end
end

function CharCoreAnimationsR6:animateTool()
	if (self.toolAnim == "None") then
		self:playToolAnimation("toolnone", CoreConfig.toolTransitionTime, Enum.AnimationPriority.Idle)
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

function CharCoreAnimationsR6:move(timestamp)
	local amplitude = 1
	local frequency = 1
  	local deltaTime = os.clock() - self.lastTick
  	self.lastTick = timestamp

	local climbFudge = 0
	local setAngles = false

    -- Count down on jumoAnimTime
  	if (self.jumpAnimTime > 0) then
  		self.jumpAnimTime = self.jumpAnimTime - deltaTime
  	end

	if (self.pose == "FreeFall" and self.jumpAnimTime <= 0) then
		self:playAnimation("fall", CoreConfig.fallTransitionTime)
	elseif (self.pose == "Seated") then
		self:playAnimation("sit", 0.5)
		return
	elseif (self.pose == "Running") then
		self:playAnimation("walk", 0.1)

    -- # Why there is Seated here?
	elseif (self.pose == "Dead" or self.pose == "GettingUp" or self.pose == "FallingDown" or self.pose == "Seated" or self.pose == "PlatformStanding") then
		self:stopAllAnimations()
		amplitude = 0.1
		frequency = 1
		setAngles = true
	end
	if (setAngles) then
		local desiredAngle = amplitude * math.sin(timestamp * frequency)

		self.charParts.joints.rightShoulder:SetDesiredAngle(desiredAngle + climbFudge)
		self.charParts.joints.leftShoulder:SetDesiredAngle(desiredAngle - climbFudge)
		self.charParts.joints.rightHip:SetDesiredAngle(-desiredAngle)
		self.charParts.joints.leftHip:SetDesiredAngle(-desiredAngle)
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

function CharCoreAnimationsR6:setHumanoidEvents()
    self._maid:Add(self.humanoid.Died:Connect(function() self:onDied() end))
    self._maid:Add(self.humanoid.Running:Connect(function(speed) self:onRunning(speed) end))
    self._maid:Add(self.humanoid.Jumping:Connect(function() self:onJumping() end))
    self._maid:Add(self.humanoid.Climbing:Connect(function(speed) self:onClimbing(speed) end))
    self._maid:Add(self.humanoid.GettingUp:Connect(function() self:onGettingUp() end))
    self._maid:Add(self.humanoid.FreeFalling:Connect(function() self:onFreeFall() end))
    self._maid:Add(self.humanoid.FallingDown:Connect(function() self:onFallingDown() end))
    self._maid:Add(self.humanoid.Seated:Connect(function() self:onSeated() end))
    self._maid:Add(self.humanoid.PlatformStanding:Connect(function() self:onPlatformStanding() end))
    self._maid:Add(self.humanoid.Swimming:Connect(function(speed) self:onSwimming(speed) end))
end

function CharCoreAnimationsR6:Destroy()
    self._maid:Destroy()
    self.isBinded = false
    self:clearCoreAnimations()
end

return CharCoreAnimationsR6